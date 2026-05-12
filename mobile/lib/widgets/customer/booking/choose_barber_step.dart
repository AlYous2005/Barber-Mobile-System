import 'package:flutter/material.dart';

import '../../../controllers/customer/customer_booking_controller.dart';
import '../../../features/barber/profile/barber_profile.dart';
import '../../../features/locations/locations.dart';
import '../../../general_utils/app_theme_colors.dart';
import '../../../features/bookings/repositories/barber_repository.dart';

class ChooseBarberStep extends StatelessWidget {
  const ChooseBarberStep({super.key, required this.controller});

  final CustomerBookingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CustomerBarberChoiceTabs(controller: controller),
        const SizedBox(height: 14),
        _buildActiveContent(),
      ],
    );
  }

  Widget _buildActiveContent() {
    switch (controller.activeBarberChoiceTab) {
      case CustomerBarberChoiceTab.availableBarbers:
        return _AvailableBarbersTab(controller: controller);

      case CustomerBarberChoiceTab.searchBarber:
        return _SearchBarberTab(controller: controller);

      case CustomerBarberChoiceTab.requests:
        return _CustomerRequestsTab(controller: controller);
    }
  }
}

class _CustomerBarberChoiceTabs extends StatelessWidget {
  const _CustomerBarberChoiceTabs({required this.controller});

  final CustomerBookingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ChoiceTabButton(
              label: 'اختر حلاق',
              icon: Icons.content_cut_rounded,
              isActive:
                  controller.activeBarberChoiceTab ==
                  CustomerBarberChoiceTab.availableBarbers,
              onTap: () => controller.changeBarberChoiceTab(
                CustomerBarberChoiceTab.availableBarbers,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ChoiceTabButton(
              label: 'البحث عن حلاق',
              icon: Icons.search_rounded,
              isActive:
                  controller.activeBarberChoiceTab ==
                  CustomerBarberChoiceTab.searchBarber,
              onTap: () => controller.changeBarberChoiceTab(
                CustomerBarberChoiceTab.searchBarber,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ChoiceTabButton(
              label: 'الطلبات',
              icon: Icons.inbox_rounded,
              badgeCount: controller.customerAccessRequests
                  .where((request) => request.status == 'pending')
                  .length,
              isActive:
                  controller.activeBarberChoiceTab ==
                  CustomerBarberChoiceTab.requests,
              onTap: () => controller.changeBarberChoiceTab(
                CustomerBarberChoiceTab.requests,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceTabButton extends StatelessWidget {
  const _ChoiceTabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFC47A3D);

    return Material(
      color: isActive ? activeColor : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isActive
                    ? Colors.white
                    : AppThemeColors.textSecondary(context),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : AppThemeColors.textSecondary(context),
                    fontSize: 11.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 5),
                _SmallBadge(count: badgeCount),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final String label = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AvailableBarbersTab extends StatelessWidget {
  const _AvailableBarbersTab({required this.controller});

  final CustomerBookingController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.availableBarbers.isEmpty) {
      return const _EmptyMessageCard(
        icon: Icons.content_cut_rounded,
        title: 'لا يوجد حلاقون متاحون',
        message: 'لا يوجد حلاقون متاحون لك حاليًا حسب منطقتك وصلاحيات الحجز.',
      );
    }

    return Column(
      children: [
        ...controller.availableBarbers.map(
          (barber) => _WarmBarberChoiceCard(
            barber: barber,
            selected: controller.selectedBarber?.id == barber.id,
            onTap: () => controller.selectBarber(barber),
          ),
        ),
      ],
    );
  }
}

class _SearchBarberTab extends StatelessWidget {
  const _SearchBarberTab({required this.controller});

  final CustomerBookingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchBarberCard(controller: controller),

        if (controller.barberSearchErrorMessage != null) ...[
          const SizedBox(height: 12),
          _InlineStatusMessage(
            message: controller.barberSearchErrorMessage!,
            isError: true,
          ),
        ],

        if (controller.accessRequestSuccessMessage != null) ...[
          const SizedBox(height: 12),
          _InlineStatusMessage(
            message: controller.accessRequestSuccessMessage!,
            isError: false,
          ),
        ],

        if (controller.barberSearchMessage != null) ...[
          const SizedBox(height: 12),
          _InlineStatusMessage(
            message: controller.barberSearchMessage!,
            isError: false,
          ),
        ],

        if (controller.searchedBarbers.isNotEmpty) ...[
          const SizedBox(height: 14),
          ...controller.searchedBarbers.map(
            (barber) => _SearchBarberResultCard(
              barber: barber,
              accessInfo: controller.searchedBarberAccessInfoById[barber.id],
              isSending: controller.isSendingAccessRequest,
              onSendRequestTap: () =>
                  controller.sendAccessRequestToBarber(barber),
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchBarberCard extends StatelessWidget {
  const _SearchBarberCard({required this.controller});

  final CustomerBookingController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'البحث عن حلاق',
      subtitle:
          'ابحث باسم الحلاق أو رقم هاتفه. يمكنك اختيار المحافظة والمنطقة لتقليل نتائج البحث.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchInputRow(
            controller: controller.barberSearchController,
            isLoading: controller.isSearchingBarbers,
            onSearchTap: controller.searchBarbersForAccessRequest,
          ),
          const SizedBox(height: 12),
          _GovernorateDropdown(controller: controller),
          const SizedBox(height: 10),
          _AreaDropdown(controller: controller),
        ],
      ),
    );
  }
}

class _GovernorateDropdown extends StatelessWidget {
  const _GovernorateDropdown({required this.controller});

  final CustomerBookingController controller;

  @override
  Widget build(BuildContext context) {
    return _DropdownShell(
      icon: Icons.map_rounded,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedSearchGovernorateId,
          isExpanded: true,
          hint: Text(
            controller.isLoadingSearchGovernorates
                ? 'جاري تحميل المحافظات...'
                : 'اختر المحافظة',
            style: TextStyle(
              color: AppThemeColors.textMuted(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          items: controller.governorates.map((GovernorateModel governorate) {
            return DropdownMenuItem<String>(
              value: governorate.id,
              child: Text(
                governorate.nameAr,
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }).toList(),
          onChanged: controller.isLoadingSearchGovernorates
              ? null
              : controller.changeSearchGovernorate,
        ),
      ),
    );
  }
}

class _AreaDropdown extends StatelessWidget {
  const _AreaDropdown({required this.controller});

  final CustomerBookingController controller;

  @override
  Widget build(BuildContext context) {
    return _DropdownShell(
      icon: Icons.place_rounded,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedSearchAreaId,
          isExpanded: true,
          hint: Text(
            controller.isLoadingSearchAreas
                ? 'جاري تحميل المناطق...'
                : 'اختر المنطقة',
            style: TextStyle(
              color: AppThemeColors.textMuted(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          items: controller.searchAreas.map((AreaModel area) {
            return DropdownMenuItem<String>(
              value: area.id,
              child: Text(
                area.nameAr,
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }).toList(),
          onChanged: controller.isLoadingSearchAreas
              ? null
              : controller.changeSearchArea,
        ),
      ),
    );
  }
}

class _DropdownShell extends StatelessWidget {
  const _DropdownShell({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC47A3D), size: 20),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SearchInputRow extends StatelessWidget {
  const _SearchInputRow({
    required this.controller,
    required this.isLoading,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppThemeColors.softCard(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppThemeColors.border(context)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFC47A3D),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.text,
                    onSubmitted: (_) => onSearchTap(),
                    style: TextStyle(
                      color: AppThemeColors.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'اسم الحلاق أو رقم الهاتف',
                      hintStyle: TextStyle(
                        color: AppThemeColors.textMuted(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSearchTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC47A3D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'بحث',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ),
      ],
    );
  }
}

class _SearchBarberResultCard extends StatelessWidget {
  const _SearchBarberResultCard({
    required this.barber,
    required this.accessInfo,
    required this.isSending,
    required this.onSendRequestTap,
  });

  final BarberModel barber;
  final CustomerBarberAccessSearchInfo? accessInfo;
  final bool isSending;
  final VoidCallback onSendRequestTap;

  @override
  Widget build(BuildContext context) {
    final CustomerBarberAccessSearchInfo resolvedAccessInfo =
        accessInfo ??
        const CustomerBarberAccessSearchInfo(
          state: CustomerBarberAccessSearchState.canSendRequest,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BarberCardIdentity(barber: barber),
          const SizedBox(height: 13),

          if (!resolvedAccessInfo.canSendRequest) ...[
            _SearchAccessStatusBox(accessInfo: resolvedAccessInfo),
          ] else ...[
            ElevatedButton.icon(
              onPressed: isSending ? null : onSendRequestTap,
              icon: isSending
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                isSending ? 'جاري الإرسال...' : 'إرسال طلب صلاحية حجز',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC47A3D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchAccessStatusBox extends StatelessWidget {
  const _SearchAccessStatusBox({required this.accessInfo});

  final CustomerBarberAccessSearchInfo accessInfo;

  @override
  Widget build(BuildContext context) {
    final Color color = accessInfo.isDanger
        ? const Color(0xFFDC2626)
        : const Color(0xFFC47A3D);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            accessInfo.isDanger
                ? Icons.block_rounded
                : Icons.info_outline_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              accessInfo.message,
              style: TextStyle(
                color: color,
                fontSize: 12.8,
                fontWeight: FontWeight.w900,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerRequestsTab extends StatelessWidget {
  const _CustomerRequestsTab({required this.controller});

  final CustomerBookingController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingCustomerRequests) {
      return const Padding(
        padding: EdgeInsets.only(top: 35),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.customerAccessRequests.isEmpty) {
      return const _EmptyMessageCard(
        icon: Icons.inbox_rounded,
        title: 'لا توجد طلبات',
        message: 'عند إرسال طلب صلاحية حجز لحلاق، سيظهر الطلب وحالته هنا.',
      );
    }

    return Column(
      children: controller.customerAccessRequests.map((request) {
        return _CustomerAccessRequestCard(request: request);
      }).toList(),
    );
  }
}

class _CustomerAccessRequestCard extends StatelessWidget {
  const _CustomerAccessRequestCard({required this.request});

  final CustomerBarberAccessRequestModel request;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (request.status) {
      'accepted' => const Color(0xFF16A34A),
      'rejected' => const Color(0xFFDC2626),
      _ => const Color(0xFFC47A3D),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BarberCardIdentity(barber: request.barber),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withValues(alpha: 0.20)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'حالة الطلب: ${request.statusLabel}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarberCardIdentity extends StatelessWidget {
  const _BarberCardIdentity({required this.barber});

  final BarberModel barber;

  String get _displayLocation {
    final cleaned = barber.locationLabel?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return 'المنطقة غير محددة';
    }

    return cleaned;
  }

  String? get _displayDetailedAddress {
    final cleaned = barber.address?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BarberChoiceAvatar(
          avatarUrl: barber.barberAvatarUrl,
          barberName: barber.name,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                barber.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                barber.shopName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 17,
                    color: Color(0xFFC47A3D),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _displayLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppThemeColors.textSecondary(context),
                        fontSize: 12.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (_displayDetailedAddress != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 22),
                  child: Text(
                    _displayDetailedAddress!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppThemeColors.textMuted(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 9),
              _FiveStarsMiniRating(rating: barber.rating),
            ],
          ),
        ),
      ],
    );
  }
}

class _WarmBarberChoiceCard extends StatelessWidget {
  const _WarmBarberChoiceCard({
    required this.barber,
    required this.selected,
    required this.onTap,
  });

  final BarberModel barber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? const Color(0xFFC47A3D)
        : AppThemeColors.border(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: selected ? 1.7 : 1),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? const Color(0x22C47A3D)
                      : const Color(0x10000000),
                  blurRadius: selected ? 22 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _BarberChoiceAvatar(
                      avatarUrl: barber.barberAvatarUrl,
                      barberName: barber.name,
                    ),
                    if (selected)
                      Positioned(
                        left: -2,
                        bottom: -2,
                        child: Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF16A34A),
                            border: Border.all(
                              color: AppThemeColors.card(context),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 13),
                Expanded(child: _BarberCardIdentityTextOnly(barber: barber)),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 38,
                  height: 82,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFC47A3D)
                        : AppThemeColors.softCard(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFC47A3D)
                          : AppThemeColors.border(context),
                    ),
                  ),
                  child: Icon(
                    selected
                        ? Icons.check_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    color: selected ? Colors.white : const Color(0xFFC47A3D),
                    size: selected ? 22 : 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarberCardIdentityTextOnly extends StatelessWidget {
  const _BarberCardIdentityTextOnly({required this.barber});

  final BarberModel barber;

  String get _displayLocation {
    final cleaned = barber.locationLabel?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return 'المنطقة غير محددة';
    }

    return cleaned;
  }

  String? get _displayDetailedAddress {
    final cleaned = barber.address?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          barber.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppThemeColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          barber.shopName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppThemeColors.textSecondary(context),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 17,
              color: Color(0xFFC47A3D),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                _displayLocation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 12.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (_displayDetailedAddress != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 22),
            child: Text(
              _displayDetailedAddress!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppThemeColors.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 9),
        _FiveStarsMiniRating(rating: barber.rating),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppThemeColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: AppThemeColors.textSecondary(context),
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InlineStatusMessage extends StatelessWidget {
  const _InlineStatusMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color color = isError
        ? const Color(0xFFDC2626)
        : const Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessageCard extends StatelessWidget {
  const _EmptyMessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppThemeColors.textMuted(context), size: 38),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeColors.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeColors.textSecondary(context),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FiveStarsMiniRating extends StatelessWidget {
  const _FiveStarsMiniRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final int fullStars = rating.floor();
    final bool hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;

        if (index < fullStars) {
          icon = Icons.star_rounded;
        } else if (index == fullStars && hasHalfStar) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 2),
          child: Icon(icon, size: 16, color: const Color(0xFFF59E0B)),
        );
      }),
    );
  }
}

class _BarberChoiceAvatar extends StatelessWidget {
  const _BarberChoiceAvatar({
    required this.avatarUrl,
    required this.barberName,
  });

  final String? avatarUrl;
  final String barberName;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatarUrl?.trim();

    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
        ),
        border: Border.all(color: const Color(0xFFE7B679), width: 2.4),
      ),
      child: ClipOval(
        child: imageUrl == null || imageUrl.isEmpty
            ? _BarberChoiceAvatarFallback(barberName: barberName)
            : Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return _BarberChoiceAvatarFallback(barberName: barberName);
                },
              ),
      ),
    );
  }
}

class _BarberChoiceAvatarFallback extends StatelessWidget {
  const _BarberChoiceAvatarFallback({required this.barberName});

  final String barberName;

  @override
  Widget build(BuildContext context) {
    final String firstLetter = barberName.trim().isEmpty
        ? 'ح'
        : barberName.trim().characters.first;

    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF6E3F2F), Color(0xFFC47A3D)],
        ),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
