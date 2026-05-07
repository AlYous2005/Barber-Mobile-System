import 'package:flutter/material.dart';

import '../../models/barber_model.dart';
import '../../models/booking_model.dart';
import '../../models/service_model.dart';
import '../../repositories/barber_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/service_repository.dart';
import '../../services/auth_session.dart';
import '../../utils/booking_date_helpers.dart';
import '../../models/booking_date_choice.dart';
import '../../models/selected_booking_service.dart';
import '../../models/service_target.dart';

class CustomerBookingController extends ChangeNotifier {
  CustomerBookingController({
    BarberModel? preselectedBarber,
    BarberRepository barberRepository = const BarberRepository(),
    ServiceRepository serviceRepository = const ServiceRepository(),
    BookingRepository bookingRepository = const BookingRepository(),
  }) : _barberRepository = barberRepository,
       _serviceRepository = serviceRepository,
       _bookingRepository = bookingRepository {
    if (preselectedBarber != null) {
      selectedBarber = preselectedBarber;
      step = 1;
    }
  }

  final BarberRepository _barberRepository;
  final ServiceRepository _serviceRepository;
  final BookingRepository _bookingRepository;

  int step = 0;
  bool isLoadingData = true;
  String? dataErrorMessage;
  bool isCreatingBooking = false;

  List<BarberModel> availableBarbers = [];
  List<ServiceModel> availableServices = [];

  BarberModel? selectedBarber;
  List<SelectedBookingService> selectedServices = [];
  BookingDateChoice dateChoice = BookingDateChoice.today;
  DateTime? customDate;
  String? selectedTime;

  int get selectedTotalPrice {
    return selectedServices.fold(0, (sum, selected) => sum + selected.price);
  }

  int get selectedTotalDuration {
    return selectedServices.fold(
      0,
      (sum, selected) => sum + selected.durationMinutes,
    );
  }

  ServiceModel get combinedSelectedService {
    return ServiceModel(
      id: selectedServices.map((selected) => selected.uniqueKey).join('-'),
      name: selectedServices
          .map((selected) => selected.displayName)
          .join(' - '),
      durationMinutes: selectedTotalDuration,
      price: selectedTotalPrice,
    );
  }

  bool get canGoNext {
    switch (step) {
      case 0:
        return selectedBarber != null;
      case 1:
        return selectedServices.isNotEmpty;
      case 2:
        if (dateChoice == BookingDateChoice.custom && customDate == null) {
          return false;
        }
        return true;
      case 3:
        return selectedTime != null;
      case 4:
        return true;
      default:
        return false;
    }
  }

  String get stepTitle {
    switch (step) {
      case 0:
        return 'اختر الحلاق';
      case 1:
        return 'اختر الخدمة';
      case 2:
        return 'اختر التاريخ';
      case 3:
        return 'الأوقات المتاحة';
      case 4:
        return 'تأكيد الحجز';
      default:
        return '';
    }
  }

  Future<void> loadBookingData() async {
    isLoadingData = true;
    dataErrorMessage = null;
    notifyListeners();

    try {
      final barbers = await _barberRepository.getAvailableBarbers();

      availableBarbers = barbers;

      if (selectedBarber != null) {
        final services = await _serviceRepository.getAvailableServices(
          barberId: selectedBarber!.id,
        );

        availableServices = services;
      } else {
        availableServices = [];
      }

      isLoadingData = false;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      dataErrorMessage = 'تعذر تحميل بيانات الحجز، حاول مرة أخرى';
      isLoadingData = false;
      notifyListeners();
    }
  }

  bool isServiceSelected(ServiceModel service, ServiceTarget target) {
    return selectedServices.any((item) {
      return item.service.id == service.id && item.target == target;
    });
  }

  void toggleService(ServiceModel service, ServiceTarget target) {
    final bool alreadySelected = isServiceSelected(service, target);

    if (alreadySelected) {
      selectedServices = selectedServices.where((item) {
        return !(item.service.id == service.id && item.target == target);
      }).toList();
    } else {
      selectedServices = [
        ...selectedServices,
        SelectedBookingService(service: service, target: target),
      ];
    }

    selectedTime = null;
    notifyListeners();
  }

  Future<void> selectBarber(BarberModel barber) async {
    selectedBarber = barber;
    selectedServices = [];
    selectedTime = null;
    isLoadingData = true;
    dataErrorMessage = null;
    notifyListeners();

    try {
      final services = await _serviceRepository.getAvailableServices(
        barberId: barber.id,
      );

      availableServices = services;
      isLoadingData = false;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController services load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      dataErrorMessage = 'تعذر تحميل خدمات الحلاق، حاول مرة أخرى';
      isLoadingData = false;
      notifyListeners();
    }
  }

  void clearSelectedBarber() {
    selectedBarber = null;
    selectedServices = [];
    selectedTime = null;
    notifyListeners();
  }

  void goNext() {
    if (!canGoNext) return;

    if (step < 4) {
      step += 1;
      notifyListeners();
    }
  }

  void goBack() {
    if (step <= 0) return;

    step -= 1;
    notifyListeners();
  }

  void changeDateChoice(BookingDateChoice choice) {
    dateChoice = choice;
    selectedTime = null;

    if (choice != BookingDateChoice.custom) {
      customDate = null;
    }

    notifyListeners();
  }

  void changeCustomDate(DateTime date) {
    customDate = date;
    dateChoice = BookingDateChoice.custom;
    selectedTime = null;
    notifyListeners();
  }

  void selectTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  Future<BookingModel> confirmBooking() async {
    if (selectedBarber == null ||
        selectedServices.isEmpty ||
        selectedTime == null) {
      throw const CustomerBookingControllerException(
        'الرجاء إكمال بيانات الحجز أولًا',
      );
    }

    isCreatingBooking = true;
    notifyListeners();

    try {
      final barber = selectedBarber!;
      final service = combinedSelectedService;
      final resolved = resolveBookingDate(dateChoice, customDate);
      final dateLabel = resolveDateDisplayLabel(dateChoice, resolved);
      final time = selectedTime!;

      final booking = BookingModel(
        barber: barber,
        service: service,
        date: resolved,
        timeLabel: time,
        price: service.price,
        dateDisplayLabel: dateLabel,
      );

      final currentUser = AuthSession.currentUser;

      final String customerDisplayName = (currentUser?.displayName ?? '')
          .trim();

      final resolvedCustomerName = customerDisplayName.isNotEmpty
          ? customerDisplayName
          : 'زبون جديد';

      final createdBooking = await _bookingRepository.createBooking(
        booking: booking,
        selectedServices: selectedServices,
        customerId: currentUser?.username ?? 'guest_customer',
        customerName: resolvedCustomerName,
      );

      isCreatingBooking = false;
      notifyListeners();

      return createdBooking;
    } catch (error) {
      isCreatingBooking = false;
      notifyListeners();

      if (error is CustomerBookingControllerException) {
        rethrow;
      }

      throw const CustomerBookingControllerException(
        'تعذر إنشاء الحجز، حاول مرة أخرى',
      );
    }
  }
}

class CustomerBookingControllerException implements Exception {
  const CustomerBookingControllerException(this.message);

  final String message;

  @override
  String toString() => message;
}
