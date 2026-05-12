import '../../../../services/supabase_config.dart';

class LinkedCustomerProfile {
  const LinkedCustomerProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.areaId,
    required this.areaName,
    required this.governorateName,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String areaId;
  final String areaName;
  final String governorateName;
  final String? avatarUrl;

  String get displayName {
    return '$firstName $lastName'.trim();
  }

  String get searchableText {
    return '$firstName $lastName $phoneNumber'.toLowerCase().trim();
  }

  String get locationLabel {
    if (governorateName.isNotEmpty && areaName.isNotEmpty) {
      return '$governorateName - $areaName';
    }

    if (areaName.isNotEmpty) {
      return areaName;
    }

    if (governorateName.isNotEmpty) {
      return governorateName;
    }

    return 'المنطقة غير محددة';
  }
}

class BarberCustomerRequestModel {
  const BarberCustomerRequestModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.customer,
    this.message,
  });

  final String id;
  final String status;
  final DateTime createdAt;
  final LinkedCustomerProfile customer;
  final String? message;
}

enum CustomerAccessLinkState { active, blocked }

class BarberCustomerLinkRepository {
  const BarberCustomerLinkRepository();

  Future<String> getBarberAreaId({required String barberId}) async {
    final String cleanBarberId = barberId.trim();

    if (cleanBarberId.isEmpty) {
      return '';
    }

    final row = await SupabaseConfig.client
        .from('barbers')
        .select('area_id')
        .eq('id', cleanBarberId)
        .maybeSingle();

    if (row == null) {
      return '';
    }

    return _clean(row['area_id']);
  }

  Future<CustomerAccessLinkState?> getCustomerAccessLinkState({
    required String barberId,
    required String customerId,
  }) async {
    final String cleanBarberId = barberId.trim();
    final String cleanCustomerId = customerId.trim();

    if (cleanBarberId.isEmpty || cleanCustomerId.isEmpty) {
      return null;
    }

    final row = await SupabaseConfig.client
        .from('barber_customer_links')
        .select('is_active')
        .eq('barber_id', cleanBarberId)
        .eq('customer_id', cleanCustomerId)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    final bool isActive = row['is_active'] == true;

    return isActive
        ? CustomerAccessLinkState.active
        : CustomerAccessLinkState.blocked;
  }

  Future<LinkedCustomerProfile?> findCustomerByPhone({
    required String phoneNumber,
  }) async {
    final String cleanPhone = phoneNumber.trim();

    if (cleanPhone.isEmpty) {
      return null;
    }

    final row = await SupabaseConfig.client
        .from('profiles')
        .select(
          'id, first_name, last_name, phone_number, avatar_url, area_id, '
          'areas(name_ar, governorates(name_ar))',
        )
        .eq('phone_number', cleanPhone)
        .eq('role', 'customer')
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return _mapCustomerRow(row);
  }

  Future<void> allowCustomer({
    required String barberId,
    required String customerId,
  }) async {
    await _upsertCustomerAccess(
      barberId: barberId,
      customerId: customerId,
      isActive: true,
    );
  }

  Future<void> blockCustomer({
    required String barberId,
    required String customerId,
  }) async {
    await _upsertCustomerAccess(
      barberId: barberId,
      customerId: customerId,
      isActive: false,
    );
  }

  Future<void> _upsertCustomerAccess({
    required String barberId,
    required String customerId,
    required bool isActive,
  }) async {
    final String cleanBarberId = barberId.trim();
    final String cleanCustomerId = customerId.trim();

    if (cleanBarberId.isEmpty) {
      throw StateError('Missing barber id');
    }

    if (cleanCustomerId.isEmpty) {
      throw StateError('Missing customer id');
    }

    await SupabaseConfig.client.from('barber_customer_links').upsert({
      'barber_id': cleanBarberId,
      'customer_id': cleanCustomerId,
      'is_active': isActive,
      'created_by': 'barber',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'barber_id,customer_id');
  }

  Future<List<LinkedCustomerProfile>> getAllowedCustomers({
    required String barberId,
  }) async {
    return _getLinkedCustomersByActiveState(barberId: barberId, isActive: true);
  }

  Future<List<LinkedCustomerProfile>> getBlockedCustomers({
    required String barberId,
  }) async {
    return _getLinkedCustomersByActiveState(
      barberId: barberId,
      isActive: false,
    );
  }

  Future<List<LinkedCustomerProfile>> _getLinkedCustomersByActiveState({
    required String barberId,
    required bool isActive,
  }) async {
    final String cleanBarberId = barberId.trim();

    if (cleanBarberId.isEmpty) {
      return <LinkedCustomerProfile>[];
    }

    final rows = await SupabaseConfig.client
        .from('barber_customer_links')
        .select(
          'customer_id, profiles!barber_customer_links_customer_id_fkey('
          'id, first_name, last_name, phone_number, avatar_url, area_id, '
          'areas(name_ar, governorates(name_ar))'
          ')',
        )
        .eq('barber_id', cleanBarberId)
        .eq('is_active', isActive)
        .order('updated_at', ascending: false);

    return _mapLinkedCustomerRows(rows);
  }

  Future<List<LinkedCustomerProfile>> getTodayCustomers({
    required String barberId,
  }) async {
    final String cleanBarberId = barberId.trim();

    if (cleanBarberId.isEmpty) {
      return <LinkedCustomerProfile>[];
    }

    final String today = DateTime.now().toIso8601String().substring(0, 10);

    final rows = await SupabaseConfig.client
        .from('appointments')
        .select(
          'customer_id, profiles!appointments_customer_id_fkey('
          'id, first_name, last_name, phone_number, avatar_url, area_id, '
          'areas(name_ar, governorates(name_ar))'
          ')',
        )
        .eq('barber_id', cleanBarberId)
        .eq('appointment_date', today)
        .not('customer_id', 'is', null)
        .order('start_time');

    return _mapUniqueCustomersFromAppointmentRows(rows);
  }

  Future<List<LinkedCustomerProfile>> searchPreviousCustomers({
    required String barberId,
    required String query,
  }) async {
    final String cleanBarberId = barberId.trim();
    final String cleanQuery = query.trim().toLowerCase();

    if (cleanBarberId.isEmpty || cleanQuery.isEmpty) {
      return <LinkedCustomerProfile>[];
    }

    final rows = await SupabaseConfig.client
        .from('appointments')
        .select(
          'customer_id, profiles!appointments_customer_id_fkey('
          'id, first_name, last_name, phone_number, avatar_url, area_id, '
          'areas(name_ar, governorates(name_ar))'
          ')',
        )
        .eq('barber_id', cleanBarberId)
        .not('customer_id', 'is', null)
        .order('appointment_date', ascending: false)
        .limit(250);

    final customers = _mapUniqueCustomersFromAppointmentRows(rows);

    return customers.where((customer) {
      return customer.searchableText.contains(cleanQuery);
    }).toList();
  }

  Future<List<BarberCustomerRequestModel>> getPendingRequests({
    required String barberId,
  }) async {
    final String cleanBarberId = barberId.trim();

    if (cleanBarberId.isEmpty) {
      return <BarberCustomerRequestModel>[];
    }

    final rows = await SupabaseConfig.client
        .from('barber_customer_requests')
        .select(
          'id, status, message, created_at, customer_id, '
          'profiles!barber_customer_requests_customer_id_fkey('
          'id, first_name, last_name, phone_number, avatar_url, area_id, '
          'areas(name_ar, governorates(name_ar))'
          ')',
        )
        .eq('barber_id', cleanBarberId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    final List<BarberCustomerRequestModel> requests =
        <BarberCustomerRequestModel>[];

    for (final row in rows) {
      final profileRow = row['profiles'];

      if (profileRow is! Map<String, dynamic>) {
        continue;
      }

      requests.add(
        BarberCustomerRequestModel(
          id: _clean(row['id']),
          status: _clean(row['status']),
          message: _cleanNullable(row['message']),
          createdAt: _parseDate(row['created_at']),
          customer: _mapCustomerRow(profileRow),
        ),
      );
    }

    return requests;
  }

  Future<List<LinkedCustomerProfile>> searchAccessManageableCustomers({
    required String barberId,
    required String barberAreaId,
    required String query,
  }) async {
    final String cleanBarberId = barberId.trim();
    final String cleanBarberAreaId = barberAreaId.trim();
    final String cleanQuery = query.trim();

    if (cleanBarberId.isEmpty || cleanQuery.isEmpty) {
      return <LinkedCustomerProfile>[];
    }

    final Map<String, LinkedCustomerProfile> candidates =
        <String, LinkedCustomerProfile>{};

    final Set<String> blockedCustomerIds = <String>{};

    final linkRows = await SupabaseConfig.client
        .from('barber_customer_links')
        .select(
          'is_active, customer_id, profiles!barber_customer_links_customer_id_fkey('
          'id, first_name, last_name, phone_number, avatar_url, area_id, '
          'areas(name_ar, governorates(name_ar))'
          ')',
        )
        .eq('barber_id', cleanBarberId);

    for (final row in linkRows) {
      final String customerId = _clean(row['customer_id']);
      final bool isActive = row['is_active'] == true;

      if (!isActive) {
        blockedCustomerIds.add(customerId);
        continue;
      }

      final profileRow = row['profiles'];

      if (profileRow is Map<String, dynamic>) {
        final customer = _mapCustomerRow(profileRow);

        if (customer.id.isNotEmpty) {
          candidates[customer.id] = customer;
        }
      }
    }

    if (cleanBarberAreaId.isNotEmpty) {
      final sameAreaRows = await SupabaseConfig.client
          .from('profiles')
          .select(
            'id, first_name, last_name, phone_number, avatar_url, role, area_id, '
            'areas(name_ar, governorates(name_ar))',
          )
          .eq('role', 'customer')
          .eq('area_id', cleanBarberAreaId)
          .limit(300);

      for (final row in sameAreaRows) {
        final customer = _mapCustomerRow(row);

        if (customer.id.isNotEmpty) {
          candidates[customer.id] = customer;
        }
      }
    }

    for (final blockedCustomerId in blockedCustomerIds) {
      candidates.remove(blockedCustomerId);
    }

    final List<LinkedCustomerProfile> filteredCustomers = candidates.values
        .where((customer) {
          return _customerMatchesQuery(customer: customer, query: cleanQuery);
        })
        .toList();

    filteredCustomers.sort((first, second) {
      return first.displayName.compareTo(second.displayName);
    });

    return filteredCustomers;
  }

  Future<void> acceptRequest({
    required String requestId,
    required String barberId,
    required String customerId,
  }) async {
    final String cleanRequestId = requestId.trim();

    if (cleanRequestId.isEmpty) {
      throw StateError('Missing request id');
    }

    await SupabaseConfig.client
        .from('barber_customer_requests')
        .update({
          'status': 'accepted',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
          'responded_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', cleanRequestId);

    await allowCustomer(barberId: barberId, customerId: customerId);
  }

  Future<void> rejectRequest({required String requestId}) async {
    final String cleanRequestId = requestId.trim();

    if (cleanRequestId.isEmpty) {
      throw StateError('Missing request id');
    }

    await SupabaseConfig.client
        .from('barber_customer_requests')
        .update({
          'status': 'rejected',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
          'responded_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', cleanRequestId);
  }

  List<LinkedCustomerProfile> _mapLinkedCustomerRows(List<dynamic> rows) {
    final List<LinkedCustomerProfile> customers = <LinkedCustomerProfile>[];

    for (final row in rows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }

      final profileRow = row['profiles'];

      if (profileRow is Map<String, dynamic>) {
        customers.add(_mapCustomerRow(profileRow));
      }
    }

    return customers;
  }

  List<LinkedCustomerProfile> _mapUniqueCustomersFromAppointmentRows(
    List<dynamic> rows,
  ) {
    final Map<String, LinkedCustomerProfile> uniqueCustomers =
        <String, LinkedCustomerProfile>{};

    for (final row in rows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }

      final profileRow = row['profiles'];

      if (profileRow is! Map<String, dynamic>) {
        continue;
      }

      final customer = _mapCustomerRow(profileRow);

      if (customer.id.isNotEmpty) {
        uniqueCustomers[customer.id] = customer;
      }
    }

    return uniqueCustomers.values.toList();
  }

  LinkedCustomerProfile _mapCustomerRow(Map<String, dynamic> row) {
    final areaRow = row['areas'];
    final Map<String, dynamic>? areaMap = areaRow is Map<String, dynamic>
        ? areaRow
        : null;

    final governorateRow = areaMap?['governorates'];
    final Map<String, dynamic>? governorateMap =
        governorateRow is Map<String, dynamic> ? governorateRow : null;

    return LinkedCustomerProfile(
      id: _clean(row['id']),
      firstName: _clean(row['first_name']),
      lastName: _clean(row['last_name']),
      phoneNumber: _clean(row['phone_number']),
      areaId: _clean(row['area_id']),
      areaName: _clean(areaMap?['name_ar']),
      governorateName: _clean(governorateMap?['name_ar']),
      avatarUrl: _cleanNullable(row['avatar_url']),
    );
  }

  DateTime _parseDate(dynamic value) {
    final parsed = DateTime.tryParse((value ?? '').toString());

    if (parsed == null) {
      return DateTime.now();
    }

    return parsed.toLocal();
  }

  bool _customerMatchesQuery({
    required LinkedCustomerProfile customer,
    required String query,
  }) {
    final String cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return false;
    }

    final String textSearchSource =
        '${customer.firstName} ${customer.lastName} ${customer.phoneNumber}'
            .toLowerCase();

    if (textSearchSource.contains(cleanQuery)) {
      return true;
    }

    final String queryDigits = _digitsOnly(cleanQuery);
    final String phoneDigits = _digitsOnly(customer.phoneNumber);

    if (queryDigits.isEmpty || phoneDigits.isEmpty) {
      return false;
    }

    final List<String> queryVariants = <String>[queryDigits];

    if (queryDigits.startsWith('0')) {
      queryVariants.add('970${queryDigits.substring(1)}');
    }

    if (queryDigits.startsWith('970')) {
      queryVariants.add('0${queryDigits.substring(3)}');
    }

    if (queryDigits.startsWith('5') && queryDigits.length == 9) {
      queryVariants.add('970$queryDigits');
      queryVariants.add('0$queryDigits');
    }

    return queryVariants.any(phoneDigits.contains);
  }

  static String _digitsOnly(dynamic value) {
    return (value ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String _clean(dynamic value) {
    return (value ?? '').toString().trim();
  }

  static String? _cleanNullable(dynamic value) {
    final cleaned = _clean(value);

    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }
}
