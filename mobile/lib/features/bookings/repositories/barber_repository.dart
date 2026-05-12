import '../../barber/profile/barber_profile.dart';
import '../../../services/supabase_config.dart';
import '../models/barber_rating_summary.dart';
import 'barber_review_summary_repository.dart';

class CustomerBarberAccessRequestModel {
  const CustomerBarberAccessRequestModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.barber,
    this.message,
  });

  final String id;
  final String status;
  final DateTime createdAt;
  final BarberModel barber;
  final String? message;

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'accepted':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

enum CustomerBarberAccessSearchState {
  canSendRequest,
  blockedByBarber,
  pendingRequest,
  rejectedTooMany,
  alreadyAllowed,
}

class CustomerBarberAccessSearchInfo {
  const CustomerBarberAccessSearchInfo({
    required this.state,
    this.rejectedCount = 0,
  });

  final CustomerBarberAccessSearchState state;
  final int rejectedCount;

  bool get canSendRequest {
    return state == CustomerBarberAccessSearchState.canSendRequest;
  }

  bool get isDanger {
    return state == CustomerBarberAccessSearchState.blockedByBarber ||
        state == CustomerBarberAccessSearchState.rejectedTooMany;
  }

  String get message {
    switch (state) {
      case CustomerBarberAccessSearchState.blockedByBarber:
        return 'قام الحلاق بمنعك من الحجز عنده، يرجى مراجعته.';
      case CustomerBarberAccessSearchState.pendingRequest:
        return 'لقد قمت بإرسال طلب لهذا الحلاق، وحالة الطلب معلقة حتى الآن.';
      case CustomerBarberAccessSearchState.rejectedTooMany:
        return 'لقد قام هذا الحلاق برفض طلبك عدة مرات، يرجى مراجعته لكي يقوم بإضافتك.';
      case CustomerBarberAccessSearchState.alreadyAllowed:
        return 'أنت مسموح لك بالحجز عند هذا الحلاق، يمكنك اختياره من تبويب اختر حلاق.';
      case CustomerBarberAccessSearchState.canSendRequest:
        return 'يمكنك إرسال طلب صلاحية حجز لهذا الحلاق.';
    }
  }
}

class BarberRepository implements BarberRepositoryContract {
  const BarberRepository({
    this.reviewSummaryRepository = const BarberReviewSummaryRepository(),
  });

  final BarberReviewSummaryRepository reviewSummaryRepository;
  static const String _barberSelectColumns =
      'id, profile_id, salon_id, area_id, name, shop_name, phone, address, bio, rating, salon_image_url, booking_window_enabled, booking_window_type, areas(id, governorate_id, name_ar, governorates(id, name_ar))';

  @override
  Future<List<BarberModel>> getAvailableBarbers() async {
    final rows = await SupabaseConfig.client
        .from('barbers')
        .select(_barberSelectColumns)
        .eq('is_active', true)
        .order('name');

    final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(rows);
    final ratingSummariesByBarberId = await _loadRatingSummariesByBarberId(
      rows,
    );

    return rows.map<BarberModel>((row) {
      final barberId = row['id']?.toString();

      return _mapBarberRow(
        row,
        avatarUrlsByProfileId: avatarUrlsByProfileId,
        ratingSummary: barberId == null
            ? BarberRatingSummary.empty
            : ratingSummariesByBarberId[barberId] ?? BarberRatingSummary.empty,
      );
    }).toList();
  }

  @override
  Future<List<BarberModel>> getAvailableBarbersByArea({
    required String areaId,
  }) async {
    final String cleanAreaId = areaId.trim();

    if (cleanAreaId.isEmpty) {
      return <BarberModel>[];
    }

    final rows = await SupabaseConfig.client
        .from('barbers')
        .select(_barberSelectColumns)
        .eq('is_active', true)
        .eq('area_id', cleanAreaId)
        .order('name');

    final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(rows);
    final ratingSummariesByBarberId = await _loadRatingSummariesByBarberId(
      rows,
    );

    return rows.map<BarberModel>((row) {
      final barberId = row['id']?.toString();

      return _mapBarberRow(
        row,
        avatarUrlsByProfileId: avatarUrlsByProfileId,
        ratingSummary: barberId == null
            ? BarberRatingSummary.empty
            : ratingSummariesByBarberId[barberId] ?? BarberRatingSummary.empty,
      );
    }).toList();
  }

  Future<Map<String, CustomerBarberAccessSearchInfo>>
  getAccessSearchInfoForBarbers({
    required String customerId,
    required List<String> barberIds,
  }) async {
    final String cleanCustomerId = customerId.trim();

    final List<String> cleanBarberIds = barberIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (cleanCustomerId.isEmpty || cleanBarberIds.isEmpty) {
      return <String, CustomerBarberAccessSearchInfo>{};
    }

    final Map<String, CustomerBarberAccessSearchInfo> result =
        <String, CustomerBarberAccessSearchInfo>{};

    for (final barberId in cleanBarberIds) {
      result[barberId] = const CustomerBarberAccessSearchInfo(
        state: CustomerBarberAccessSearchState.canSendRequest,
      );
    }

    final linkRows = await SupabaseConfig.client
        .from('barber_customer_links')
        .select('barber_id, is_active')
        .eq('customer_id', cleanCustomerId)
        .inFilter('barber_id', cleanBarberIds);

    final Set<String> blockedBarberIds = <String>{};
    final Set<String> allowedBarberIds = <String>{};

    for (final row in linkRows) {
      final String barberId = _cleanText(row['barber_id']);

      if (barberId.isEmpty) {
        continue;
      }

      if (row['is_active'] == true) {
        allowedBarberIds.add(barberId);
      } else {
        blockedBarberIds.add(barberId);
      }
    }

    for (final barberId in allowedBarberIds) {
      result[barberId] = const CustomerBarberAccessSearchInfo(
        state: CustomerBarberAccessSearchState.alreadyAllowed,
      );
    }

    for (final barberId in blockedBarberIds) {
      result[barberId] = const CustomerBarberAccessSearchInfo(
        state: CustomerBarberAccessSearchState.blockedByBarber,
      );
    }

    final requestRows = await SupabaseConfig.client
        .from('barber_customer_requests')
        .select('barber_id, status')
        .eq('customer_id', cleanCustomerId)
        .inFilter('barber_id', cleanBarberIds);

    final Map<String, int> rejectedCountByBarberId = <String, int>{};
    final Set<String> pendingBarberIds = <String>{};

    for (final row in requestRows) {
      final String barberId = _cleanText(row['barber_id']);
      final String status = _cleanText(row['status']);

      if (barberId.isEmpty) {
        continue;
      }

      if (status == 'pending') {
        pendingBarberIds.add(barberId);
      }

      if (status == 'rejected') {
        rejectedCountByBarberId[barberId] =
            (rejectedCountByBarberId[barberId] ?? 0) + 1;
      }
    }

    for (final barberId in pendingBarberIds) {
      if (blockedBarberIds.contains(barberId) ||
          allowedBarberIds.contains(barberId)) {
        continue;
      }

      result[barberId] = const CustomerBarberAccessSearchInfo(
        state: CustomerBarberAccessSearchState.pendingRequest,
      );
    }

    for (final entry in rejectedCountByBarberId.entries) {
      final String barberId = entry.key;
      final int rejectedCount = entry.value;

      if (blockedBarberIds.contains(barberId) ||
          allowedBarberIds.contains(barberId) ||
          pendingBarberIds.contains(barberId)) {
        continue;
      }

      if (rejectedCount >= 2) {
        result[barberId] = CustomerBarberAccessSearchInfo(
          state: CustomerBarberAccessSearchState.rejectedTooMany,
          rejectedCount: rejectedCount,
        );
      }
    }

    return result;
  }

  Future<List<BarberModel>> getAvailableBarbersForCustomer({
    required String customerId,
    required String customerAreaId,
  }) async {
    final String cleanCustomerId = customerId.trim();
    final String cleanCustomerAreaId = customerAreaId.trim();

    if (cleanCustomerId.isEmpty || cleanCustomerAreaId.isEmpty) {
      return <BarberModel>[];
    }

    final List<BarberModel> sameAreaBarbers = await getAvailableBarbersByArea(
      areaId: cleanCustomerAreaId,
    );

    final linkRows = await SupabaseConfig.client
        .from('barber_customer_links')
        .select('barber_id, is_active')
        .eq('customer_id', cleanCustomerId);

    final Set<String> activeLinkedBarberIds = <String>{};
    final Set<String> blockedBarberIds = <String>{};

    for (final row in linkRows) {
      final String barberId = _cleanText(row['barber_id']);

      if (barberId.isEmpty) {
        continue;
      }

      final bool isActive = row['is_active'] == true;

      if (isActive) {
        activeLinkedBarberIds.add(barberId);
      } else {
        blockedBarberIds.add(barberId);
      }
    }

    final Map<String, BarberModel> resultById = <String, BarberModel>{};

    for (final barber in sameAreaBarbers) {
      resultById[barber.id] = barber;
    }

    final List<String> allowedOutsideAreaIds = activeLinkedBarberIds
        .where((barberId) => !blockedBarberIds.contains(barberId))
        .where((barberId) => !resultById.containsKey(barberId))
        .toList();

    if (allowedOutsideAreaIds.isNotEmpty) {
      final rows = await SupabaseConfig.client
          .from('barbers')
          .select(_barberSelectColumns)
          .inFilter('id', allowedOutsideAreaIds)
          .eq('is_active', true)
          .order('name');

      final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(rows);
      final ratingSummariesByBarberId = await _loadRatingSummariesByBarberId(
        rows,
      );

      for (final row in rows) {
        final String barberId = _cleanText(row['id']);

        if (barberId.isEmpty) {
          continue;
        }

        resultById[barberId] = _mapBarberRow(
          row,
          avatarUrlsByProfileId: avatarUrlsByProfileId,
          ratingSummary:
              ratingSummariesByBarberId[barberId] ?? BarberRatingSummary.empty,
        );
      }
    }

    for (final blockedBarberId in blockedBarberIds) {
      resultById.remove(blockedBarberId);
    }

    final List<BarberModel> result = resultById.values.toList();

    result.sort((first, second) {
      return first.name.compareTo(second.name);
    });

    return result;
  }

  Future<List<BarberModel>> searchBarbersForAccessRequest({
    required String query,
    String? governorateId,
    String? areaId,
    String? currentCustomerAreaId,
  }) async {
    final String cleanQuery = query.trim().toLowerCase();
    final String? cleanGovernorateId = governorateId?.trim();
    final String? cleanAreaId = areaId?.trim();
    final String? cleanCustomerAreaId = currentCustomerAreaId?.trim();

    if (cleanQuery.isEmpty &&
        (cleanGovernorateId == null || cleanGovernorateId.isEmpty) &&
        (cleanAreaId == null || cleanAreaId.isEmpty)) {
      return <BarberModel>[];
    }

    dynamic request = SupabaseConfig.client
        .from('barbers')
        .select(_barberSelectColumns)
        .eq('is_active', true);

    if (cleanAreaId != null && cleanAreaId.isNotEmpty) {
      request = request.eq('area_id', cleanAreaId);
    }

    final rows = await request.order('name').limit(80);

    final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(rows);
    final ratingSummariesByBarberId = await _loadRatingSummariesByBarberId(
      rows,
    );

    final List<BarberModel> barbers = rows.map<BarberModel>((row) {
      final barberId = row['id']?.toString();

      return _mapBarberRow(
        row,
        avatarUrlsByProfileId: avatarUrlsByProfileId,
        ratingSummary: barberId == null
            ? BarberRatingSummary.empty
            : ratingSummariesByBarberId[barberId] ?? BarberRatingSummary.empty,
      );
    }).toList();

    final List<BarberModel> filtered = barbers.where((barber) {
      final bool isSameCustomerArea =
          cleanCustomerAreaId != null &&
          cleanCustomerAreaId.isNotEmpty &&
          barber.areaId == cleanCustomerAreaId;

      if (isSameCustomerArea) {
        return false;
      }

      final bool matchesText =
          cleanQuery.isEmpty || _barberMatchesQuery(barber, cleanQuery);

      return matchesText;
    }).toList();

    return filtered;
  }

  Future<void> sendCustomerAccessRequest({
    required String barberId,
    required String customerId,
    String? message,
  }) async {
    final String cleanBarberId = barberId.trim();
    final String cleanCustomerId = customerId.trim();
    final String? cleanMessage = message?.trim();

    if (cleanBarberId.isEmpty) {
      throw StateError('Missing barber id');
    }

    if (cleanCustomerId.isEmpty) {
      throw StateError('Missing customer id');
    }

    await SupabaseConfig.client.from('barber_customer_requests').insert({
      'barber_id': cleanBarberId,
      'customer_id': cleanCustomerId,
      'status': 'pending',
      'message': cleanMessage == null || cleanMessage.isEmpty
          ? null
          : cleanMessage,
    });
  }

  Future<List<CustomerBarberAccessRequestModel>> getCustomerAccessRequests({
    required String customerId,
  }) async {
    final String cleanCustomerId = customerId.trim();

    if (cleanCustomerId.isEmpty) {
      return <CustomerBarberAccessRequestModel>[];
    }

    final rows = await SupabaseConfig.client
        .from('barber_customer_requests')
        .select(
          'id, status, message, created_at, barber_id, '
          'barbers($_barberSelectColumns)',
        )
        .eq('customer_id', cleanCustomerId)
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> barberRows = <Map<String, dynamic>>[];

    for (final row in rows) {
      final barberRow = row['barbers'];

      if (barberRow is Map<String, dynamic>) {
        barberRows.add(barberRow);
      }
    }

    final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(barberRows);
    final ratingSummariesByBarberId = await _loadRatingSummariesByBarberId(
      barberRows,
    );

    final List<CustomerBarberAccessRequestModel> requests =
        <CustomerBarberAccessRequestModel>[];

    for (final row in rows) {
      final barberRow = row['barbers'];

      if (barberRow is! Map<String, dynamic>) {
        continue;
      }

      final String? barberId = barberRow['id']?.toString();

      requests.add(
        CustomerBarberAccessRequestModel(
          id: _cleanText(row['id']),
          status: _cleanText(row['status']),
          message: _cleanNullableText(row['message']?.toString()),
          createdAt: _parseDate(row['created_at']),
          barber: _mapBarberRow(
            barberRow,
            avatarUrlsByProfileId: avatarUrlsByProfileId,
            ratingSummary: barberId == null
                ? BarberRatingSummary.empty
                : ratingSummariesByBarberId[barberId] ??
                      BarberRatingSummary.empty,
          ),
        ),
      );
    }

    return requests;
  }

  Future<List<BarberModel>> getBarbersBySalonId({
    required String salonId,
  }) async {
    final cleanedSalonId = salonId.trim();

    if (cleanedSalonId.isEmpty) {
      return [];
    }

    final rows = await SupabaseConfig.client
        .from('barbers')
        .select(_barberSelectColumns)
        .eq('salon_id', cleanedSalonId)
        .eq('is_active', true)
        .order('name');

    final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(rows);
    final ratingSummariesByBarberId = await _loadRatingSummariesByBarberId(
      rows,
    );

    return rows.map<BarberModel>((row) {
      final barberId = row['id']?.toString();

      return _mapBarberRow(
        row,
        avatarUrlsByProfileId: avatarUrlsByProfileId,
        ratingSummary: barberId == null
            ? BarberRatingSummary.empty
            : ratingSummariesByBarberId[barberId] ?? BarberRatingSummary.empty,
      );
    }).toList();
  }

  @override
  Future<BarberModel?> findBarberByName(String barberName) async {
    final normalizedName = barberName.trim();

    if (normalizedName.isEmpty) {
      return null;
    }

    final rows = await SupabaseConfig.client
        .from('barbers')
        .select(
          'id, profile_id, salon_id, area_id, name, shop_name, phone, address, bio, rating, salon_image_url, booking_window_enabled, booking_window_type',
        )
        .eq('is_active', true)
        .eq('name', normalizedName)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final avatarUrlsByProfileId = await _loadAvatarUrlsByProfileId(rows);
    final ratingSummariesByBarberId = await _loadRatingSummariesByBarberId(
      rows,
    );

    final barberId = rows.first['id']?.toString();

    return _mapBarberRow(
      rows.first,
      avatarUrlsByProfileId: avatarUrlsByProfileId,
      ratingSummary: barberId == null
          ? BarberRatingSummary.empty
          : ratingSummariesByBarberId[barberId] ?? BarberRatingSummary.empty,
    );
  }

  Future<Map<String, BarberRatingSummary>> _loadRatingSummariesByBarberId(
    List<dynamic> barberRows,
  ) async {
    final barberIds = barberRows
        .map((row) => row['id']?.toString())
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    return reviewSummaryRepository.getSummariesByBarberIds(
      barberIds: barberIds,
    );
  }

  Future<Map<String, String>> _loadAvatarUrlsByProfileId(
    List<dynamic> barberRows,
  ) async {
    final profileIds = barberRows
        .map((row) => row['profile_id']?.toString())
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    if (profileIds.isEmpty) {
      return {};
    }

    final profileRows = await SupabaseConfig.client
        .from('profiles')
        .select('id, avatar_url')
        .inFilter('id', profileIds);

    final Map<String, String> avatarUrlsByProfileId = {};

    for (final row in profileRows) {
      final profileId = row['id']?.toString();
      final avatarUrl = row['avatar_url']?.toString().trim();

      if (profileId == null ||
          profileId.isEmpty ||
          avatarUrl == null ||
          avatarUrl.isEmpty) {
        continue;
      }

      avatarUrlsByProfileId[profileId] = avatarUrl;
    }

    return avatarUrlsByProfileId;
  }

  BarberModel _mapBarberRow(
    Map<String, dynamic> row, {
    required Map<String, String> avatarUrlsByProfileId,
    required BarberRatingSummary ratingSummary,
  }) {
    final profileId = row['profile_id']?.toString();
    final salonImageUrl = row['salon_image_url']?.toString().trim();
    final barberAvatarUrl = profileId == null
        ? null
        : avatarUrlsByProfileId[profileId];

    final areaRow = row['areas'];
    final Map<String, dynamic>? areaMap = areaRow is Map<String, dynamic>
        ? areaRow
        : null;

    final governorateRow = areaMap?['governorates'];
    final Map<String, dynamic>? governorateMap =
        governorateRow is Map<String, dynamic> ? governorateRow : null;

    return BarberModel(
      id: row['id'].toString(),
      name: (row['name'] ?? '').toString(),
      shopName: (row['shop_name'] ?? '').toString(),
      distance: 'غير محدد',
      rating: ratingSummary.ratingCount == 0
          ? _parseRating(row['rating'])
          : ratingSummary.averageRating,
      ratingCount: ratingSummary.ratingCount,
      satisfactionRate: ratingSummary.satisfactionRate,
      ratingBreakdown: ratingSummary.ratingBreakdown,
      salonId: _cleanNullableText(row['salon_id']?.toString()),
      areaId: _cleanNullableText(row['area_id']?.toString()),
      areaName: _cleanNullableText(areaMap?['name_ar']?.toString()),
      governorateName: _cleanNullableText(
        governorateMap?['name_ar']?.toString(),
      ),
      salonImageUrl: _cleanNullableText(salonImageUrl),
      barberAvatarUrl: _cleanNullableText(barberAvatarUrl),
      phone: _cleanNullableText(row['phone']?.toString()),
      address: _cleanNullableText(row['address']?.toString()),
      bio: _cleanNullableText(row['bio']?.toString()),
      bookingWindowEnabled: row['booking_window_enabled'] == true,
      bookingWindowType: _parseBookingWindowType(row['booking_window_type']),
    );
  }

  bool _barberMatchesQuery(BarberModel barber, String query) {
    final String cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return true;
    }

    final String searchSource =
        '${barber.name} ${barber.shopName} ${barber.phone ?? ''}'.toLowerCase();

    if (searchSource.contains(cleanQuery)) {
      return true;
    }

    final String queryDigits = _digitsOnly(cleanQuery);
    final String phoneDigits = _digitsOnly(barber.phone ?? '');

    if (queryDigits.isEmpty || phoneDigits.isEmpty) {
      return false;
    }

    final List<String> variants = <String>[queryDigits];

    if (queryDigits.startsWith('0')) {
      variants.add('970${queryDigits.substring(1)}');
    }

    if (queryDigits.startsWith('970')) {
      variants.add('0${queryDigits.substring(3)}');
    }

    if (queryDigits.startsWith('5') && queryDigits.length == 9) {
      variants.add('970$queryDigits');
      variants.add('0$queryDigits');
    }

    return variants.any(phoneDigits.contains);
  }

  DateTime _parseDate(dynamic value) {
    final parsed = DateTime.tryParse((value ?? '').toString());

    if (parsed == null) {
      return DateTime.now();
    }

    return parsed.toLocal();
  }

  String _cleanText(dynamic value) {
    return (value ?? '').toString().trim();
  }

  static String _digitsOnly(dynamic value) {
    return (value ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _parseBookingWindowType(dynamic value) {
    final String raw = (value ?? 'month').toString().trim();
    if (raw.isEmpty) {
      return 'month';
    }
    return raw;
  }

  String? _cleanNullableText(String? value) {
    final cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  double _parseRating(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
