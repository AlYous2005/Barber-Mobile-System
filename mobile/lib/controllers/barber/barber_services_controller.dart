// State + Validation + Repository Calls

import 'package:flutter/material.dart';

import '../../models/ui_service_model.dart';
import '../../repositories/service_repository.dart';
import '../../services/auth_session.dart';
import '../../utils/validators/service_field_validation.dart';

class BarberServicesController extends ChangeNotifier {
  BarberServicesController({
    ServiceRepository serviceRepository = const ServiceRepository(),
  }) : _serviceRepository = serviceRepository {
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

  void resetForm() {
    addNameError = null;
    addDurationError = null;
    addPriceError = null;

    serviceNameController.clear();
    durationController.clear();
    priceController.clear();

    notifyListeners();
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
      isActive: true,
    );

    final createdService = await _serviceRepository.addBarberService(
      barberId: _currentBarberId,
      service: newService,
    );

    services = [createdService, ...services];

    serviceNameController.clear();
    durationController.clear();
    priceController.clear();

    notifyListeners();
  }

  Future<void> updateService(UiService updatedService) async {
    final savedService = await _serviceRepository.updateBarberService(
      barberId: _currentBarberId,
      service: updatedService,
    );

    services = services.map((service) {
      if (service.id == savedService.id) {
        return savedService;
      }

      return service;
    }).toList();

    notifyListeners();
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

  @override
  void dispose() {
    serviceNameController.removeListener(_onAddNameChanged);
    durationController.removeListener(_onAddDurationChanged);
    priceController.removeListener(_onAddPriceChanged);

    serviceNameController.dispose();
    durationController.dispose();
    priceController.dispose();

    super.dispose();
  }
}
