import 'package:flutter/material.dart';

import '../../features/barber/profile/barber_profile.dart';
import '../../features/barber/schedule/schedule.dart';
import '../../features/bookings/bookings.dart';
import '../../features/barber/services_management/services_management.dart';
import '../../services/auth_session.dart';
import '../../features/locations/locations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_config.dart';

enum CustomerBarberChoiceTab { availableBarbers, searchBarber, requests }

class CustomerBookingController extends ChangeNotifier {
  CustomerBookingController({
    BarberModel? preselectedBarber,
    BarberRepository barberRepository = const BarberRepository(),
    ServiceRepository serviceRepository = const ServiceRepository(),
    LocationRepository locationRepository = const LocationRepository(),
    BookingRepository bookingRepository = const BookingRepository(),
    BarberWorkingHoursRepository workingHoursRepository =
        const BarberWorkingHoursRepository(),
    BarberAvailabilityRepository availabilityRepository =
        const BarberAvailabilityRepository(),
  }) : _barberRepository = barberRepository,
       _serviceRepository = serviceRepository,
       _locationRepository = locationRepository,
       _bookingRepository = bookingRepository,
       _workingHoursRepository = workingHoursRepository,
       _availabilityRepository = availabilityRepository {
    if (preselectedBarber != null) {
      selectedBarber = preselectedBarber;
      step = 1;
    }
  }

  final BarberRepository _barberRepository;
  final ServiceRepository _serviceRepository;
  final LocationRepository _locationRepository;
  final BookingRepository _bookingRepository;
  final BarberWorkingHoursRepository _workingHoursRepository;
  final BarberAvailabilityRepository _availabilityRepository;
  String get currentCustomerAuthId {
    return SupabaseConfig.client.auth.currentUser?.id ?? '';
  }

  int step = 0;
  CustomerBarberChoiceTab activeBarberChoiceTab =
      CustomerBarberChoiceTab.availableBarbers;

  final TextEditingController barberSearchController = TextEditingController();

  List<GovernorateModel> governorates = <GovernorateModel>[];
  List<AreaModel> searchAreas = <AreaModel>[];

  String? selectedSearchGovernorateId;
  String? selectedSearchAreaId;

  bool isLoadingSearchGovernorates = false;
  bool isLoadingSearchAreas = false;
  bool isSearchingBarbers = false;
  bool isSendingAccessRequest = false;
  bool isLoadingCustomerRequests = false;

  String? barberSearchMessage;
  String? barberSearchErrorMessage;
  String? accessRequestSuccessMessage;

  List<BarberModel> searchedBarbers = <BarberModel>[];
  List<CustomerBarberAccessRequestModel> customerAccessRequests =
      <CustomerBarberAccessRequestModel>[];

  Map<String, CustomerBarberAccessSearchInfo> searchedBarberAccessInfoById =
      <String, CustomerBarberAccessSearchInfo>{};

  RealtimeChannel? _customerAccessRealtimeChannel;
  RealtimeChannel? _selectedBarberServicesRealtimeChannel;
  RealtimeChannel? _selectedBarberProfileRealtimeChannel;

  String? _servicesRealtimeBarberId;
  String? _profileRealtimeBarberId;

  bool _isRefreshingCustomerAccess = false;
  bool _isRefreshingServices = false;
  bool _isRefreshingSelectedBarberProfile = false;

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
  List<DateTime> availableTimeSlots = [];
  bool isLoadingAvailableTimes = false;
  String? availableTimesMessage;

  /// Populated when [selectedBarber.bookingWindowEnabled] is true.
  List<DateTime> allowedBookingDates = <DateTime>[];

  bool get useConstrainedBookingDates {
    return selectedBarber?.bookingWindowEnabled == true &&
        allowedBookingDates.isNotEmpty;
  }

  int get selectedTotalPrice {
    return selectedServices.fold(0, (sum, selected) => sum + selected.price);
  }

  int get selectedTotalDuration {
    return selectedServices.fold(
      0,
      (sum, selected) => sum + selected.durationMinutes,
    );
  }

  List<String> get availableTimeLabels {
    return availableTimeSlots.map(formatArabicClockWithPeriod).toList();
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
        if (useConstrainedBookingDates) {
          final DateTime resolved = resolveBookingDate(dateChoice, customDate);
          if (!_allowedListContains(resolved)) {
            return false;
          }
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

  void changeBarberChoiceTab(CustomerBarberChoiceTab tab) {
    activeBarberChoiceTab = tab;
    barberSearchErrorMessage = null;
    barberSearchMessage = null;
    accessRequestSuccessMessage = null;
    notifyListeners();

    if (tab == CustomerBarberChoiceTab.searchBarber) {
      loadSearchGovernorates();
    }

    if (tab == CustomerBarberChoiceTab.requests) {
      loadCustomerAccessRequests();
    }
  }

  Future<void> loadSearchGovernorates() async {
    if (governorates.isNotEmpty || isLoadingSearchGovernorates) {
      return;
    }

    isLoadingSearchGovernorates = true;
    notifyListeners();

    try {
      governorates = await _locationRepository.getActiveGovernorates();
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController governorates load error: $error');
      debugPrintStack(stackTrace: stackTrace);
      barberSearchErrorMessage = 'تعذر تحميل المحافظات';
    } finally {
      isLoadingSearchGovernorates = false;
      notifyListeners();
    }
  }

  Future<void> changeSearchGovernorate(String? governorateId) async {
    selectedSearchGovernorateId = governorateId;
    selectedSearchAreaId = null;
    searchAreas = <AreaModel>[];
    barberSearchErrorMessage = null;
    notifyListeners();

    final String cleanGovernorateId = governorateId?.trim() ?? '';

    if (cleanGovernorateId.isEmpty) {
      return;
    }

    isLoadingSearchAreas = true;
    notifyListeners();

    try {
      searchAreas = await _locationRepository.getActiveAreasByGovernorate(
        governorateId: cleanGovernorateId,
      );
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController areas load error: $error');
      debugPrintStack(stackTrace: stackTrace);
      barberSearchErrorMessage = 'تعذر تحميل المناطق';
    } finally {
      isLoadingSearchAreas = false;
      notifyListeners();
    }
  }

  void changeSearchArea(String? areaId) {
    selectedSearchAreaId = areaId;
    barberSearchErrorMessage = null;
    notifyListeners();
  }

  Future<void> searchBarbersForAccessRequest() async {
    final String query = barberSearchController.text.trim();
    final String? customerAreaId = AuthSession.currentUser?.areaId?.trim();

    if (query.isEmpty &&
        (selectedSearchAreaId == null || selectedSearchAreaId!.isEmpty)) {
      barberSearchErrorMessage =
          'اكتب اسم الحلاق أو رقم هاتفه، أو اختر المحافظة والمنطقة للبحث';
      barberSearchMessage = null;
      searchedBarbers = <BarberModel>[];
      notifyListeners();
      return;
    }

    isSearchingBarbers = true;
    barberSearchErrorMessage = null;
    barberSearchMessage = null;
    accessRequestSuccessMessage = null;
    searchedBarbers = <BarberModel>[];
    searchedBarberAccessInfoById = <String, CustomerBarberAccessSearchInfo>{};
    notifyListeners();

    try {
      searchedBarbers = await _barberRepository.searchBarbersForAccessRequest(
        query: query,
        governorateId: selectedSearchGovernorateId,
        areaId: selectedSearchAreaId,
        currentCustomerAreaId: customerAreaId,
      );

      searchedBarberAccessInfoById = await _barberRepository
          .getAccessSearchInfoForBarbers(
            customerId: currentCustomerAuthId,
            barberIds: searchedBarbers.map((barber) => barber.id).toList(),
          );

      if (searchedBarbers.isEmpty) {
        barberSearchMessage =
            'لم يتم العثور على حلاقين مطابقين خارج منطقتك الحالية';
      }
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController barber search error: $error');
      debugPrintStack(stackTrace: stackTrace);
      barberSearchErrorMessage = 'تعذر البحث عن الحلاقين';
    } finally {
      isSearchingBarbers = false;
      notifyListeners();
    }
  }

  Future<void> sendAccessRequestToBarber(BarberModel barber) async {
    if (isSendingAccessRequest) {
      return;
    }

    final String customerId = currentCustomerAuthId;

    if (customerId.isEmpty) {
      barberSearchErrorMessage = 'لا يوجد حساب زبون مرتبط حاليًا';
      notifyListeners();
      return;
    }

    final CustomerBarberAccessSearchInfo? accessInfo =
        searchedBarberAccessInfoById[barber.id];

    if (accessInfo != null && !accessInfo.canSendRequest) {
      barberSearchErrorMessage = accessInfo.message;
      notifyListeners();
      return;
    }

    isSendingAccessRequest = true;
    barberSearchErrorMessage = null;
    accessRequestSuccessMessage = null;
    notifyListeners();

    try {
      await _barberRepository.sendCustomerAccessRequest(
        barberId: barber.id,
        customerId: customerId,
      );

      searchedBarberAccessInfoById[barber.id] =
          const CustomerBarberAccessSearchInfo(
            state: CustomerBarberAccessSearchState.pendingRequest,
          );

      accessRequestSuccessMessage =
          'تم إرسال طلب صلاحية الحجز إلى ${barber.name}';

      await loadCustomerAccessRequests();
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController send request error: $error');
      debugPrintStack(stackTrace: stackTrace);
      barberSearchErrorMessage =
          'تعذر إرسال الطلب. إذا كان لديك طلب معلق لنفس الحلاق، انتظر رد الحلاق.';
    } finally {
      isSendingAccessRequest = false;
      notifyListeners();
    }
  }

  Future<void> loadCustomerAccessRequests() async {
    final String customerId = currentCustomerAuthId;

    if (customerId.isEmpty) {
      customerAccessRequests = <CustomerBarberAccessRequestModel>[];
      notifyListeners();
      return;
    }

    isLoadingCustomerRequests = true;
    notifyListeners();

    try {
      customerAccessRequests = await _barberRepository
          .getCustomerAccessRequests(customerId: customerId);
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController requests load error: $error');
      debugPrintStack(stackTrace: stackTrace);
      barberSearchErrorMessage = 'تعذر تحميل طلباتك';
    } finally {
      isLoadingCustomerRequests = false;
      notifyListeners();
    }
  }

  void startCustomerAccessRealtime() {
    final String customerId = currentCustomerAuthId;

    if (customerId.isEmpty) {
      return;
    }

    if (_customerAccessRealtimeChannel != null) {
      return;
    }

    _customerAccessRealtimeChannel = SupabaseConfig.client
        .channel('customer_access_updates_$customerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'barber_customer_links',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: customerId,
          ),
          callback: (_) {
            refreshCustomerAccessDataFromRealtime();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'barber_customer_requests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'customer_id',
            value: customerId,
          ),
          callback: (_) {
            refreshCustomerAccessDataFromRealtime();
          },
        )
        .subscribe();
  }

  Future<void> refreshCustomerAccessDataFromRealtime() async {
    if (_isRefreshingCustomerAccess) {
      return;
    }

    final String customerId = currentCustomerAuthId;
    final String? customerAreaId = AuthSession.currentUser?.areaId?.trim();

    if (customerId.isEmpty ||
        customerAreaId == null ||
        customerAreaId.isEmpty) {
      return;
    }

    _isRefreshingCustomerAccess = true;

    try {
      final List<BarberModel> refreshedBarbers = await _barberRepository
          .getAvailableBarbersForCustomer(
            customerId: customerId,
            customerAreaId: customerAreaId,
          );

      availableBarbers = refreshedBarbers;

      final BarberModel? currentSelectedBarber = selectedBarber;

      if (currentSelectedBarber != null) {
        final bool stillAvailable = refreshedBarbers.any(
          (barber) => barber.id == currentSelectedBarber.id,
        );

        if (!stillAvailable) {
          stopSelectedBarberServicesRealtime();
          stopSelectedBarberProfileRealtime();

          selectedBarber = null;
          selectedServices = <SelectedBookingService>[];
          selectedTime = null;
          availableTimeSlots = <DateTime>[];
          availableTimesMessage = null;
          allowedBookingDates = <DateTime>[];

          if (step > 0) {
            step = 0;
          }

          dataErrorMessage =
              'تم تحديث صلاحيات الحجز، هذا الحلاق لم يعد متاحًا لك حاليًا.';
        }
      }

      await loadCustomerAccessRequests();

      if (searchedBarbers.isNotEmpty) {
        searchedBarberAccessInfoById = await _barberRepository
            .getAccessSearchInfoForBarbers(
              customerId: customerId,
              barberIds: searchedBarbers.map((barber) => barber.id).toList(),
            );
      }

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController realtime refresh error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isRefreshingCustomerAccess = false;
    }
  }

  void startSelectedBarberServicesRealtime(String barberId) {
    final String cleanBarberId = barberId.trim();

    if (cleanBarberId.isEmpty) {
      return;
    }

    if (_servicesRealtimeBarberId == cleanBarberId &&
        _selectedBarberServicesRealtimeChannel != null) {
      return;
    }

    final RealtimeChannel? oldChannel = _selectedBarberServicesRealtimeChannel;

    if (oldChannel != null) {
      SupabaseConfig.client.removeChannel(oldChannel);
    }

    _servicesRealtimeBarberId = cleanBarberId;

    _selectedBarberServicesRealtimeChannel = SupabaseConfig.client
        .channel('customer_selected_barber_services_$cleanBarberId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'barber_services',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'barber_id',
            value: cleanBarberId,
          ),
          callback: (_) {
            refreshSelectedBarberServicesFromRealtime();
          },
        )
        .subscribe();
  }

  Future<void> refreshSelectedBarberServicesFromRealtime() async {
    if (_isRefreshingServices) {
      return;
    }

    final BarberModel? barber = selectedBarber;

    if (barber == null) {
      return;
    }

    _isRefreshingServices = true;

    try {
      final List<ServiceModel> refreshedServices = await _serviceRepository
          .getAvailableServices(barberId: barber.id);

      final Map<String, ServiceModel> refreshedById = <String, ServiceModel>{
        for (final ServiceModel service in refreshedServices)
          service.id: service,
      };

      final List<SelectedBookingService> refreshedSelectedServices =
          <SelectedBookingService>[];

      for (final SelectedBookingService selected in selectedServices) {
        final ServiceModel? refreshedService =
            refreshedById[selected.service.id];

        if (refreshedService == null) {
          continue;
        }

        refreshedSelectedServices.add(
          SelectedBookingService(
            service: refreshedService,
            target: selected.target,
          ),
        );
      }

      availableServices = refreshedServices;
      selectedServices = refreshedSelectedServices;

      selectedTime = null;
      availableTimeSlots = <DateTime>[];
      availableTimesMessage = null;

      if (step == 1) {
        dataErrorMessage = null;
      }

      notifyListeners();
      _refreshAvailableSlotsIfVisible();
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController services realtime error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isRefreshingServices = false;
    }
  }

  void stopSelectedBarberServicesRealtime() {
    final RealtimeChannel? channel = _selectedBarberServicesRealtimeChannel;

    if (channel != null) {
      SupabaseConfig.client.removeChannel(channel);
    }

    _selectedBarberServicesRealtimeChannel = null;
    _servicesRealtimeBarberId = null;
  }

  void startSelectedBarberProfileRealtime(String barberId) {
    final String cleanBarberId = barberId.trim();

    if (cleanBarberId.isEmpty) {
      return;
    }

    if (_profileRealtimeBarberId == cleanBarberId &&
        _selectedBarberProfileRealtimeChannel != null) {
      return;
    }

    final RealtimeChannel? oldChannel = _selectedBarberProfileRealtimeChannel;

    if (oldChannel != null) {
      SupabaseConfig.client.removeChannel(oldChannel);
    }

    _profileRealtimeBarberId = cleanBarberId;

    _selectedBarberProfileRealtimeChannel = SupabaseConfig.client
        .channel('customer_selected_barber_profile_$cleanBarberId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'barbers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: cleanBarberId,
          ),
          callback: (_) {
            refreshSelectedBarberProfileFromRealtime();
          },
        )
        .subscribe();
  }

  Future<void> refreshSelectedBarberProfileFromRealtime() async {
    if (_isRefreshingSelectedBarberProfile) {
      return;
    }

    final BarberModel? currentBarber = selectedBarber;
    final String customerId = currentCustomerAuthId;
    final String? customerAreaId = AuthSession.currentUser?.areaId?.trim();

    if (currentBarber == null ||
        customerId.isEmpty ||
        customerAreaId == null ||
        customerAreaId.isEmpty) {
      return;
    }

    _isRefreshingSelectedBarberProfile = true;

    try {
      final List<BarberModel> refreshedBarbers = await _barberRepository
          .getAvailableBarbersForCustomer(
            customerId: customerId,
            customerAreaId: customerAreaId,
          );

      availableBarbers = refreshedBarbers;

      BarberModel? refreshedSelectedBarber;

      for (final BarberModel barber in refreshedBarbers) {
        if (barber.id == currentBarber.id) {
          refreshedSelectedBarber = barber;
          break;
        }
      }

      if (refreshedSelectedBarber == null) {
        stopSelectedBarberServicesRealtime();
        stopSelectedBarberProfileRealtime();

        selectedBarber = null;
        selectedServices = <SelectedBookingService>[];
        selectedTime = null;
        availableTimeSlots = <DateTime>[];
        availableTimesMessage = null;
        allowedBookingDates = <DateTime>[];

        if (step > 0) {
          step = 0;
        }

        dataErrorMessage =
            'تم تحديث إعدادات الحلاق، هذا الحلاق لم يعد متاحًا لك حاليًا.';

        notifyListeners();
        return;
      }

      selectedBarber = refreshedSelectedBarber;
      _syncBookingWindowFromSelectedBarber();

      selectedTime = null;
      availableTimeSlots = <DateTime>[];
      availableTimesMessage = null;

      notifyListeners();
      _refreshAvailableSlotsIfVisible();
    } catch (error, stackTrace) {
      debugPrint(
        'CustomerBookingController barber profile realtime error: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isRefreshingSelectedBarberProfile = false;
    }
  }

  void stopSelectedBarberProfileRealtime() {
    final RealtimeChannel? channel = _selectedBarberProfileRealtimeChannel;

    if (channel != null) {
      SupabaseConfig.client.removeChannel(channel);
    }

    _selectedBarberProfileRealtimeChannel = null;
    _profileRealtimeBarberId = null;
  }

  Future<void> loadBookingData() async {
    isLoadingData = true;
    dataErrorMessage = null;
    notifyListeners();

    try {
      final String? customerAreaId = AuthSession.currentUser?.areaId?.trim();

      if (customerAreaId == null || customerAreaId.isEmpty) {
        availableBarbers = <BarberModel>[];
        availableServices = <ServiceModel>[];
        allowedBookingDates = <DateTime>[];
        selectedBarber = null;
        dataErrorMessage = 'يرجى تحديد منطقتك لعرض الحلاقين المتاحين لك';
        isLoadingData = false;
        notifyListeners();
        return;
      }

      final String customerId = currentCustomerAuthId;

      if (customerId.isEmpty) {
        availableBarbers = <BarberModel>[];
        availableServices = <ServiceModel>[];
        allowedBookingDates = <DateTime>[];
        selectedBarber = null;
        dataErrorMessage = 'لا يوجد حساب زبون مرتبط حاليًا';
        isLoadingData = false;
        notifyListeners();
        return;
      }

      final barbers = await _barberRepository.getAvailableBarbersForCustomer(
        customerId: customerId,
        customerAreaId: customerAreaId,
      );

      availableBarbers = barbers;

      await loadCustomerAccessRequests();
      startCustomerAccessRealtime();

      if (selectedBarber != null) {
        final int barberIndex = barbers.indexWhere(
          (BarberModel b) => b.id == selectedBarber!.id,
        );
        if (barberIndex >= 0) {
          selectedBarber = barbers[barberIndex];
        }

        final services = await _serviceRepository.getAvailableServices(
          barberId: selectedBarber!.id,
        );

        availableServices = services;
        _syncBookingWindowFromSelectedBarber();
        startSelectedBarberServicesRealtime(selectedBarber!.id);
        startSelectedBarberProfileRealtime(selectedBarber!.id);
      } else {
        availableServices = [];
        allowedBookingDates = <DateTime>[];
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
    availableTimeSlots = [];
    availableTimesMessage = null;
    notifyListeners();
    _refreshAvailableSlotsIfVisible();
  }

  Future<void> selectBarber(BarberModel barber) async {
    selectedBarber = barber;
    selectedServices = [];
    selectedTime = null;
    availableTimeSlots = [];
    availableTimesMessage = null;
    isLoadingData = true;
    dataErrorMessage = null;
    notifyListeners();

    try {
      final services = await _serviceRepository.getAvailableServices(
        barberId: barber.id,
      );

      availableServices = services;
      _syncBookingWindowFromSelectedBarber();
      startSelectedBarberServicesRealtime(barber.id);
      startSelectedBarberProfileRealtime(barber.id);
      isLoadingData = false;
      notifyListeners();
      _refreshAvailableSlotsIfVisible();
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController services load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      dataErrorMessage = 'تعذر تحميل خدمات الحلاق، حاول مرة أخرى';
      isLoadingData = false;
      notifyListeners();
    }
  }

  void clearSelectedBarber() {
    stopSelectedBarberServicesRealtime();
    stopSelectedBarberProfileRealtime();

    selectedBarber = null;
    selectedServices = [];
    selectedTime = null;
    availableTimeSlots = [];
    availableTimesMessage = null;
    allowedBookingDates = <DateTime>[];
    notifyListeners();
  }

  void _syncBookingWindowFromSelectedBarber() {
    final BarberModel? barber = selectedBarber;
    if (barber == null || !barber.bookingWindowEnabled) {
      allowedBookingDates = <DateTime>[];
      return;
    }

    allowedBookingDates = BookingWindowHelper.buildAllowedDates(
      enabled: true,
      type: BookingWindowType.fromStorage(barber.bookingWindowType),
      now: DateTime.now(),
    );

    if (allowedBookingDates.isEmpty) {
      return;
    }

    final DateTime resolved = resolveBookingDate(dateChoice, customDate);
    if (!_allowedListContains(resolved)) {
      selectResolvedBookingDate(allowedBookingDates.first);
    }
  }

  bool _allowedListContains(DateTime date) {
    final DateTime d = startOfDay(date);
    return allowedBookingDates.any((DateTime x) => startOfDay(x) == d);
  }

  void selectResolvedBookingDate(DateTime date) {
    final DateTime d = startOfDay(date);
    final DateTime today = startOfDay(DateTime.now());
    final DateTime tomorrow = today.add(const Duration(days: 1));

    if (d == today) {
      dateChoice = BookingDateChoice.today;
      customDate = null;
    } else if (d == tomorrow) {
      dateChoice = BookingDateChoice.tomorrow;
      customDate = null;
    } else {
      dateChoice = BookingDateChoice.custom;
      customDate = d;
    }

    selectedTime = null;
    availableTimeSlots = [];
    availableTimesMessage = null;
    notifyListeners();
    _refreshAvailableSlotsIfVisible();
  }

  void goNext() {
    if (!canGoNext) return;

    if (step < 4) {
      step += 1;
      notifyListeners();
      if (step == 3) {
        loadAvailableTimeSlots();
      }
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

    availableTimeSlots = [];
    availableTimesMessage = null;
    notifyListeners();
    _refreshAvailableSlotsIfVisible();
  }

  void changeCustomDate(DateTime date) {
    customDate = date;
    dateChoice = BookingDateChoice.custom;
    selectedTime = null;
    availableTimeSlots = [];
    availableTimesMessage = null;
    notifyListeners();
    _refreshAvailableSlotsIfVisible();
  }

  void selectTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  Future<void> loadAvailableTimeSlots() async {
    final BarberModel? barber = selectedBarber;
    if (barber == null) {
      availableTimeSlots = [];
      selectedTime = null;
      availableTimesMessage = 'اختر الحلاق أولًا';
      notifyListeners();
      return;
    }

    if (selectedServices.isEmpty || selectedTotalDuration <= 0) {
      availableTimeSlots = [];
      selectedTime = null;
      availableTimesMessage = 'اختر خدمة واحدة على الأقل لعرض الأوقات المتاحة';
      notifyListeners();
      return;
    }

    final DateTime resolvedDate = resolveBookingDate(dateChoice, customDate);

    isLoadingAvailableTimes = true;
    availableTimeSlots = [];
    selectedTime = null;
    availableTimesMessage = null;
    notifyListeners();

    try {
      final workingDays = await _workingHoursRepository.getWorkingDays(
        barberId: barber.id,
      );
      final closures = await _availabilityRepository.getClosures(
        barberId: barber.id,
      );
      final timeBlocks = await _availabilityRepository.getTimeBlocks(
        barberId: barber.id,
      );
      final appointments = await _bookingRepository
          .getBarberAppointmentsForDate(
            barberId: barber.id,
            date: resolvedDate,
          );

      final slots = ManualAppointmentSlotsHelper.buildAvailableSlots(
        date: resolvedDate,
        totalDurationMinutes: selectedTotalDuration,
        workingDays: workingDays,
        existingAppointments: appointments,
        closures: closures,
        timeBlocks: timeBlocks,
        stepMinutes: 15,
      );

      availableTimeSlots = slots;
      availableTimesMessage = slots.isEmpty
          ? 'لا توجد أوقات متاحة لهذا اليوم'
          : null;
    } catch (error, stackTrace) {
      debugPrint('CustomerBookingController slots load error: $error');
      debugPrintStack(stackTrace: stackTrace);
      availableTimeSlots = [];
      availableTimesMessage = 'تعذر تحميل الأوقات المتاحة';
    } finally {
      isLoadingAvailableTimes = false;
      notifyListeners();
    }
  }

  void _refreshAvailableSlotsIfVisible() {
    if (step == 3) {
      loadAvailableTimeSlots();
    }
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

  @override
  void dispose() {
    barberSearchController.dispose();

    final RealtimeChannel? accessChannel = _customerAccessRealtimeChannel;

    if (accessChannel != null) {
      SupabaseConfig.client.removeChannel(accessChannel);
    }

    final RealtimeChannel? servicesChannel =
        _selectedBarberServicesRealtimeChannel;

    if (servicesChannel != null) {
      SupabaseConfig.client.removeChannel(servicesChannel);
    }

    final RealtimeChannel? profileChannel =
        _selectedBarberProfileRealtimeChannel;

    if (profileChannel != null) {
      SupabaseConfig.client.removeChannel(profileChannel);
    }

    super.dispose();
  }
}

class CustomerBookingControllerException implements Exception {
  const CustomerBookingControllerException(this.message);

  final String message;

  @override
  String toString() => message;
}
