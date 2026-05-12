import 'package:flutter/material.dart';

import '../../features/barber/profile/barber_profile.dart';
import '../../services/auth_session.dart';

enum BarberCustomersTab {
  addCustomer,
  accessManagement,
  blockedCustomers,
  requests,
}

enum AccessManagementView { todayCustomers, searchByNameOrPhone }

class BarberCustomersController extends ChangeNotifier {
  BarberCustomersController({
    BarberCustomerLinkRepository customerLinkRepository =
        const BarberCustomerLinkRepository(),
  }) : _customerLinkRepository = customerLinkRepository;

  final BarberCustomerLinkRepository _customerLinkRepository;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController previousCustomerSearchController =
      TextEditingController();

  BarberCustomersTab activeTab = BarberCustomersTab.addCustomer;

  AccessManagementView activeAccessManagementView =
      AccessManagementView.todayCustomers;

  bool isSearchingCustomer = false;
  bool isLinkingCustomer = false;

  bool isLoadingTodayCustomers = false;
  bool isSearchingPreviousCustomers = false;
  bool isBlockingCustomer = false;

  bool isLoadingBlockedCustomers = false;
  bool isUnblockingCustomer = false;

  bool isLoadingRequests = false;
  bool isRespondingToRequest = false;

  String? errorMessage;
  String? successMessage;

  LinkedCustomerProfile? foundCustomer;
  CustomerAccessLinkState? foundCustomerLinkState;
  bool foundCustomerIsFromSameArea = false;
  String? foundCustomerAccessMessage;

  bool get canAllowFoundCustomer {
    final LinkedCustomerProfile? customer = foundCustomer;

    if (customer == null) {
      return false;
    }

    if (foundCustomerIsFromSameArea) {
      return false;
    }

    if (foundCustomerLinkState == CustomerAccessLinkState.active) {
      return false;
    }

    if (foundCustomerLinkState == CustomerAccessLinkState.blocked) {
      return false;
    }

    return true;
  }

  List<LinkedCustomerProfile> todayCustomers = <LinkedCustomerProfile>[];
  List<LinkedCustomerProfile> previousCustomerSearchResults =
      <LinkedCustomerProfile>[];
  List<LinkedCustomerProfile> blockedCustomers = <LinkedCustomerProfile>[];
  List<BarberCustomerRequestModel> pendingRequests =
      <BarberCustomerRequestModel>[];

  String get currentBarberId {
    return AuthSession.currentUser?.barberId ?? '';
  }

  Future<void> loadInitialData() async {
    await loadPendingRequests();
  }

  void changeTab(BarberCustomersTab tab) {
    activeTab = tab;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    if (tab == BarberCustomersTab.accessManagement) {
      loadTodayCustomers();
    }

    if (tab == BarberCustomersTab.blockedCustomers) {
      loadBlockedCustomers();
    }

    if (tab == BarberCustomersTab.requests) {
      loadPendingRequests();
    }
  }

  void changeAccessManagementView(AccessManagementView view) {
    activeAccessManagementView = view;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    if (view == AccessManagementView.todayCustomers) {
      loadTodayCustomers();
    }
  }

  String normalizePhone(String rawPhone) {
    final String cleaned = rawPhone.trim();

    if (cleaned.isEmpty) {
      return '';
    }

    if (cleaned.startsWith('+')) {
      return cleaned.replaceAll(RegExp(r'\s+'), '');
    }

    final String digitsOnly = cleaned.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return '';
    }

    if (digitsOnly.startsWith('00')) {
      return '+${digitsOnly.substring(2)}';
    }

    if (digitsOnly.startsWith('970')) {
      return '+$digitsOnly';
    }

    if (digitsOnly.startsWith('0')) {
      return '+970${digitsOnly.substring(1)}';
    }

    if (digitsOnly.startsWith('5') && digitsOnly.length == 9) {
      return '+970$digitsOnly';
    }

    return '+970$digitsOnly';
  }

  Future<void> searchCustomer() async {
    if (isSearchingCustomer) return;

    final String barberId = currentBarberId;
    final String phone = normalizePhone(phoneController.text);

    if (barberId.isEmpty) {
      errorMessage = 'لا يوجد حساب حلاق مرتبط حاليًا';
      successMessage = null;
      notifyListeners();
      return;
    }

    if (phone.isEmpty) {
      errorMessage = 'أدخل رقم هاتف الزبون أولًا';
      successMessage = null;
      notifyListeners();
      return;
    }

    isSearchingCustomer = true;
    errorMessage = null;
    successMessage = null;
    foundCustomer = null;
    foundCustomerLinkState = null;
    foundCustomerIsFromSameArea = false;
    foundCustomerAccessMessage = null;
    notifyListeners();

    try {
      final String barberAreaId = await _customerLinkRepository.getBarberAreaId(
        barberId: barberId,
      );

      if (barberAreaId.isEmpty) {
        errorMessage =
            'موقع الصالون غير محدد. حدّد المحافظة والمنطقة من الملف الشخصي أولًا.';
        return;
      }

      final customer = await _customerLinkRepository.findCustomerByPhone(
        phoneNumber: phone,
      );

      foundCustomer = customer;

      if (customer == null) {
        errorMessage = 'لا يوجد زبون مسجل بهذا الرقم';
        return;
      }

      foundCustomerLinkState = await _customerLinkRepository
          .getCustomerAccessLinkState(
            barberId: barberId,
            customerId: customer.id,
          );

      foundCustomerIsFromSameArea =
          customer.areaId.isNotEmpty && customer.areaId == barberAreaId;

      if (foundCustomerLinkState == CustomerAccessLinkState.blocked) {
        foundCustomerAccessMessage =
            'هذا الزبون ممنوع حاليًا من الحجز عندك. يمكنك إعادة السماح له من تبويب الممنوعين.';
        return;
      }

      if (foundCustomerLinkState == CustomerAccessLinkState.active) {
        foundCustomerAccessMessage =
            'هذا الزبون مسموح له بالحجز عندك. لتعديل صلاحيته اذهب إلى تبويب إدارة الوصول وابحث عنه.';
        return;
      }

      if (foundCustomerIsFromSameArea) {
        foundCustomerAccessMessage =
            'هذا الزبون يستطيع الحجز عندك لأنه من نفس منطقة الصالون. لتعديل صلاحيته اذهب إلى تبويب إدارة الوصول.';
        return;
      }

      foundCustomerAccessMessage =
          'هذا الزبون من خارج منطقة الصالون. يمكنك السماح له بالحجز عندك.';
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController search error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر البحث عن الزبون، حاول مرة أخرى';
    } finally {
      isSearchingCustomer = false;
      notifyListeners();
    }
  }

  Future<void> allowFoundCustomer() async {
    if (isLinkingCustomer) return;

    final String barberId = currentBarberId;
    final LinkedCustomerProfile? customer = foundCustomer;

    if (barberId.isEmpty) {
      errorMessage = 'لا يوجد حساب حلاق مرتبط حاليًا';
      successMessage = null;
      notifyListeners();
      return;
    }

    if (customer == null) {
      errorMessage = 'ابحث عن زبون أولًا';
      successMessage = null;
      notifyListeners();
      return;
    }

    if (!canAllowFoundCustomer) {
      errorMessage =
          foundCustomerAccessMessage ?? 'لا يمكن تنفيذ السماح لهذا الزبون.';
      successMessage = null;
      notifyListeners();
      return;
    }

    isLinkingCustomer = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _customerLinkRepository.allowCustomer(
        barberId: barberId,
        customerId: customer.id,
      );

      successMessage = 'تم السماح للزبون بالحجز عندك';
      foundCustomerLinkState = CustomerAccessLinkState.active;
      foundCustomerIsFromSameArea = false;
      foundCustomerAccessMessage =
          'هذا الزبون مسموح له بالحجز عندك. لتعديل صلاحيته اذهب إلى تبويب إدارة الوصول وابحث عنه.';
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController allow error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر إضافة الزبون، حاول مرة أخرى';
    } finally {
      isLinkingCustomer = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayCustomers() async {
    final String barberId = currentBarberId;

    if (barberId.isEmpty) {
      todayCustomers = <LinkedCustomerProfile>[];
      errorMessage = 'لا يوجد حساب حلاق مرتبط حاليًا';
      notifyListeners();
      return;
    }

    isLoadingTodayCustomers = true;
    errorMessage = null;
    notifyListeners();

    try {
      todayCustomers = await _customerLinkRepository.getTodayCustomers(
        barberId: barberId,
      );
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController load today error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر تحميل زبائن اليوم';
    } finally {
      isLoadingTodayCustomers = false;
      notifyListeners();
    }
  }

  Future<void> searchPreviousCustomers() async {
    final String barberId = currentBarberId;
    final String query = previousCustomerSearchController.text.trim();

    if (barberId.isEmpty) {
      errorMessage = 'لا يوجد حساب حلاق مرتبط حاليًا';
      notifyListeners();
      return;
    }

    if (query.isEmpty) {
      errorMessage = 'اكتب اسم الزبون أو رقم هاتفه للبحث';
      previousCustomerSearchResults = <LinkedCustomerProfile>[];
      notifyListeners();
      return;
    }

    isSearchingPreviousCustomers = true;
    errorMessage = null;
    successMessage = null;
    previousCustomerSearchResults = <LinkedCustomerProfile>[];
    notifyListeners();

    try {
      final String barberAreaId = await _customerLinkRepository.getBarberAreaId(
        barberId: barberId,
      );

      if (barberAreaId.isEmpty) {
        errorMessage =
            'موقع الصالون غير محدد. حدّد المحافظة والمنطقة من الملف الشخصي أولًا.';
        return;
      }

      previousCustomerSearchResults = await _customerLinkRepository
          .searchAccessManageableCustomers(
            barberId: barberId,
            barberAreaId: barberAreaId,
            query: query,
          );

      if (previousCustomerSearchResults.isEmpty) {
        errorMessage =
            'لم يتم العثور على زبون متاح لإدارة الوصول. إذا كان الزبون من خارج منطقتك وغير مسموح له بعد، استخدم تبويب إضافة زبون.';
      }
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController access search error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر البحث في الزبائن';
    } finally {
      isSearchingPreviousCustomers = false;
      notifyListeners();
    }
  }

  Future<void> blockCustomer(LinkedCustomerProfile customer) async {
    if (isBlockingCustomer) return;

    final String barberId = currentBarberId;

    if (barberId.isEmpty) {
      errorMessage = 'لا يوجد حساب حلاق مرتبط حاليًا';
      notifyListeners();
      return;
    }

    isBlockingCustomer = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _customerLinkRepository.blockCustomer(
        barberId: barberId,
        customerId: customer.id,
      );

      todayCustomers = todayCustomers
          .where((item) => item.id != customer.id)
          .toList();

      previousCustomerSearchResults = previousCustomerSearchResults
          .where((item) => item.id != customer.id)
          .toList();

      successMessage = 'تم منع الزبون من الحجز عندك';
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController block error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر منع الزبون، حاول مرة أخرى';
    } finally {
      isBlockingCustomer = false;
      notifyListeners();
    }
  }

  Future<void> loadBlockedCustomers() async {
    final String barberId = currentBarberId;

    if (barberId.isEmpty) {
      blockedCustomers = <LinkedCustomerProfile>[];
      errorMessage = 'لا يوجد حساب حلاق مرتبط حاليًا';
      notifyListeners();
      return;
    }

    isLoadingBlockedCustomers = true;
    errorMessage = null;
    notifyListeners();

    try {
      blockedCustomers = await _customerLinkRepository.getBlockedCustomers(
        barberId: barberId,
      );
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController blocked load error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر تحميل قائمة الممنوعين';
    } finally {
      isLoadingBlockedCustomers = false;
      notifyListeners();
    }
  }

  Future<void> unblockCustomer(LinkedCustomerProfile customer) async {
    if (isUnblockingCustomer) return;

    final String barberId = currentBarberId;

    if (barberId.isEmpty) {
      errorMessage = 'لا يوجد حساب حلاق مرتبط حاليًا';
      notifyListeners();
      return;
    }

    isUnblockingCustomer = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _customerLinkRepository.allowCustomer(
        barberId: barberId,
        customerId: customer.id,
      );

      blockedCustomers = blockedCustomers
          .where((item) => item.id != customer.id)
          .toList();

      successMessage = 'تمت إعادة السماح للزبون بالحجز';
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController unblock error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر إعادة السماح، حاول مرة أخرى';
    } finally {
      isUnblockingCustomer = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingRequests() async {
    final String barberId = currentBarberId;

    if (barberId.isEmpty) {
      pendingRequests = <BarberCustomerRequestModel>[];
      errorMessage = 'لا يوجد حساب حلاق مرتبط حاليًا';
      notifyListeners();
      return;
    }

    isLoadingRequests = true;
    errorMessage = null;
    notifyListeners();

    try {
      pendingRequests = await _customerLinkRepository.getPendingRequests(
        barberId: barberId,
      );
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController requests load error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر تحميل الطلبات';
    } finally {
      isLoadingRequests = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(BarberCustomerRequestModel request) async {
    if (isRespondingToRequest) return;

    final String barberId = currentBarberId;

    if (barberId.isEmpty) {
      errorMessage = 'لا يوجد حساب حلاق مرتبط حاليًا';
      notifyListeners();
      return;
    }

    isRespondingToRequest = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _customerLinkRepository.acceptRequest(
        requestId: request.id,
        barberId: barberId,
        customerId: request.customer.id,
      );

      pendingRequests = pendingRequests
          .where((item) => item.id != request.id)
          .toList();

      successMessage = 'تم قبول الطلب والسماح للزبون بالحجز';
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController accept request error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر قبول الطلب';
    } finally {
      isRespondingToRequest = false;
      notifyListeners();
    }
  }

  Future<void> rejectRequest(BarberCustomerRequestModel request) async {
    if (isRespondingToRequest) return;

    isRespondingToRequest = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      await _customerLinkRepository.rejectRequest(requestId: request.id);

      pendingRequests = pendingRequests
          .where((item) => item.id != request.id)
          .toList();

      successMessage = 'تم رفض الطلب';
    } catch (error, stackTrace) {
      debugPrint('BarberCustomersController reject request error: $error');
      debugPrintStack(stackTrace: stackTrace);
      errorMessage = 'تعذر رفض الطلب';
    } finally {
      isRespondingToRequest = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    previousCustomerSearchController.dispose();
    super.dispose();
  }
}
