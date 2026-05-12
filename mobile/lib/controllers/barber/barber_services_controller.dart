// State + Validation + Repository Calls

import 'package:flutter/material.dart';

import '../../features/barber/services_management/services_management.dart';
import '../../features/bookings/bookings.dart';

import '../../services/auth_session.dart';
import 'package:image_picker/image_picker.dart';

class BarberServicesController extends ChangeNotifier {
  BarberServicesController({
    ServiceRepository serviceRepository = const ServiceRepository(),
    ServiceImageRepository serviceImageRepository =
        const ServiceImageRepository(),
    BookingRepository bookingRepository = const BookingRepository(),
  }) : _serviceRepository = serviceRepository,
       _serviceImageRepository = serviceImageRepository,
       _bookingRepository = bookingRepository {
    _onAddNameChanged = () {
      addNameError = null;
      notifyListeners();
    };

    _onAddDurationChanged = () {
      addDurationError = null;
      notifyListeners();
    };

    _onAddPriceChanged = () {
      addPriceError = null;
      notifyListeners();
    };

    serviceNameController.addListener(_onAddNameChanged);
    durationController.addListener(_onAddDurationChanged);
    priceController.addListener(_onAddPriceChanged);
  }

  final ServiceRepository _serviceRepository;
  final ServiceImageRepository _serviceImageRepository;
  final BookingRepository _bookingRepository;

  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  late final VoidCallback _onAddNameChanged;
  late final VoidCallback _onAddDurationChanged;
  late final VoidCallback _onAddPriceChanged;

  List<UiService> services = [];
  bool isLoadingServices = true;
  String? servicesErrorMessage;

  String? addNameError;
  String? addDurationError;
  String? addPriceError;
  ServiceTarget selectedAddTarget = ServiceTarget.personal;
  String selectedAddIconKey = ServiceIconOptions.defaultKey;
  String? selectedAddImageUrl;
  bool isUploadingAddImage = false;
  int addNameShake = 0;
  int addDurationShake = 0;
  int addPriceShake = 0;
  String get _currentBarberId {
    return AuthSession.currentUser?.barberId ?? 'b1';
  }

  Future<void> loadBarberServices() async {
    isLoadingServices = true;
    servicesErrorMessage = null;
    notifyListeners();

    try {
      final loadedServices = await _serviceRepository.getBarberServices(
        barberId: _currentBarberId,
      );

      services = loadedServices;
      isLoadingServices = false;
      notifyListeners();
    } catch (_) {
      servicesErrorMessage = 'تعذر تحميل الخدمات، حاول مرة أخرى';
      isLoadingServices = false;
      notifyListeners();
    }
  }

  void increaseDuration() {
    ServiceStepperHelper.increaseMultipleOf5(durationController);
    notifyListeners();
  }

  void decreaseDuration() {
    ServiceStepperHelper.decreaseMultipleOf5(durationController);
    notifyListeners();
  }

  void increasePrice() {
    ServiceStepperHelper.increaseMultipleOf5(priceController);
    notifyListeners();
  }

  void decreasePrice() {
    ServiceStepperHelper.decreaseMultipleOf5(priceController);
    notifyListeners();
  }

  void changeAddTarget(ServiceTarget target) {
    selectedAddTarget = target;
    notifyListeners();
  }

  void changeAddIconKey(String iconKey) {
    selectedAddIconKey = iconKey;
    notifyListeners();
  }

  Future<void> pickAndUploadAddServiceImage() async {
    if (isUploadingAddImage) {
      return;
    }

    isUploadingAddImage = true;
    notifyListeners();

    final String? previousImageUrl = selectedAddImageUrl;

    try {
      final String? uploadedUrl = await pickAndUploadServiceImageUrl();

      if (uploadedUrl == null || uploadedUrl.trim().isEmpty) {
        return;
      }

      selectedAddImageUrl = uploadedUrl.trim();

      if (previousImageUrl != null && previousImageUrl != selectedAddImageUrl) {
        await _serviceImageRepository.deleteServiceImageByPublicUrl(
          previousImageUrl,
        );
      }
    } finally {
      isUploadingAddImage = false;
      notifyListeners();
    }
  }

  Future<String?> pickAndUploadServiceImageUrl() async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 82,
    );

    if (pickedImage == null) {
      return null;
    }

    return _serviceImageRepository.uploadServiceImage(
      barberId: _currentBarberId,
      image: pickedImage,
    );
  }

  Future<void> clearAddServiceImage() async {
    final String? imageUrlToDelete = selectedAddImageUrl;

    selectedAddImageUrl = null;
    notifyListeners();

    await _serviceImageRepository.deleteServiceImageByPublicUrl(
      imageUrlToDelete,
    );
  }

  bool validateAddForm() {
    final String? nameError = ServiceFieldValidation.nameError(
      serviceNameController.text,
    );
    final String? durationError = ServiceFieldValidation.durationError(
      durationController.text,
    );
    final String? priceError = ServiceFieldValidation.priceError(
      priceController.text,
    );

    final bool isValid =
        nameError == null && durationError == null && priceError == null;

    addNameError = nameError;
    addDurationError = durationError;
    addPriceError = priceError;

    if (nameError != null) addNameShake++;
    if (durationError != null) addDurationShake++;
    if (priceError != null) addPriceShake++;

    notifyListeners();

    return isValid;
  }

  Future<void> resetForm() async {
    final String? imageUrlToDelete = selectedAddImageUrl;

    addNameError = null;
    addDurationError = null;
    addPriceError = null;

    serviceNameController.clear();
    durationController.clear();
    priceController.clear();
    selectedAddTarget = ServiceTarget.personal;
    selectedAddIconKey = ServiceIconOptions.defaultKey;
    selectedAddImageUrl = null;
    isUploadingAddImage = false;

    notifyListeners();

    await _serviceImageRepository.deleteServiceImageByPublicUrl(
      imageUrlToDelete,
    );
  }

  Future<void> addService() async {
    final String name = serviceNameController.text.trim();
    final int duration = int.parse(durationController.text.trim());
    final int priceInt = int.parse(priceController.text.trim());

    final newService = UiService(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      durationMinutes: duration,
      price: priceInt.toDouble(),
      target: selectedAddTarget,
      isActive: true,
      serviceImageUrl: selectedAddImageUrl,
      serviceIconKey: selectedAddIconKey,
    );

    final createdService = await _serviceRepository.addBarberService(
      barberId: _currentBarberId,
      service: newService,
    );

    services = [createdService, ...services];

    serviceNameController.clear();
    durationController.clear();
    priceController.clear();
    selectedAddTarget = ServiceTarget.personal;
    selectedAddIconKey = ServiceIconOptions.defaultKey;
    selectedAddImageUrl = null;
    isUploadingAddImage = false;
    notifyListeners();
  }

  Future<void> updateService(UiService updatedService) async {
    final UiService? previousService = _findServiceById(updatedService.id);
    final String? previousImageUrl = _cleanText(
      previousService?.serviceImageUrl,
    );

    final savedService = await _serviceRepository.updateBarberService(
      barberId: _currentBarberId,
      service: updatedService,
    );

    final String? newImageUrl = _cleanText(savedService.serviceImageUrl);

    services = services.map((service) {
      if (service.id == savedService.id) {
        return savedService;
      }

      return service;
    }).toList();

    notifyListeners();

    if (previousImageUrl != null && previousImageUrl != newImageUrl) {
      await _serviceImageRepository.deleteServiceImageByPublicUrl(
        previousImageUrl,
      );
    }
  }

  Future<void> setServiceActive({
    required UiService service,
    required bool isActive,
  }) async {
    final updatedService = await _serviceRepository.setServiceActive(
      barberId: _currentBarberId,
      serviceId: service.id,
      isActive: isActive,
    );

    services = services.map((item) {
      if (item.id == service.id) {
        return updatedService;
      }

      return item;
    }).toList();

    notifyListeners();
  }

  Future<int> countActiveAppointmentsForService(String serviceId) {
    return _bookingRepository.countActiveAppointmentsForService(
      barberId: _currentBarberId,
      serviceId: serviceId,
    );
  }

  Future<void> cancelActiveAppointmentsForService(String serviceId) {
    return _bookingRepository.cancelActiveAppointmentsForService(
      barberId: _currentBarberId,
      serviceId: serviceId,
    );
  }

  Future<void> archiveServiceById(String serviceId) async {
    await _serviceRepository.archiveBarberService(
      barberId: _currentBarberId,
      serviceId: serviceId,
    );
    services = services.where((UiService s) => s.id != serviceId).toList();
    notifyListeners();
  }

  UiService? _findServiceById(String serviceId) {
    for (final service in services) {
      if (service.id == serviceId) {
        return service;
      }
    }

    return null;
  }

  String? _cleanText(String? value) {
    if (value == null) {
      return null;
    }

    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  Future<void> deleteServiceImageByUrl(String? imageUrl) {
    return _serviceImageRepository.deleteServiceImageByPublicUrl(imageUrl);
  }

  @override
  void dispose() {
    final String? imageUrlToDelete = selectedAddImageUrl;

    if (imageUrlToDelete != null && imageUrlToDelete.trim().isNotEmpty) {
      Future.microtask(() {
        _serviceImageRepository.deleteServiceImageByPublicUrl(imageUrlToDelete);
      });
    }
    serviceNameController.removeListener(_onAddNameChanged);
    durationController.removeListener(_onAddDurationChanged);
    priceController.removeListener(_onAddPriceChanged);

    serviceNameController.dispose();
    durationController.dispose();
    priceController.dispose();

    super.dispose();
  }
}
