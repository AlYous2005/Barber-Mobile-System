import 'package:flutter/material.dart';

import '../../controllers/barber/barber_customers_controller.dart';
import '../../features/barber/profile/barber_profile.dart';
import '../../general_utils/app_theme_colors.dart';

class BarberCustomersScreen extends StatefulWidget {
  const BarberCustomersScreen({
    super.key,
    this.initialTab = BarberCustomersTab.addCustomer,
    this.highlightedRequestId,
  });

  final BarberCustomersTab initialTab;
  final String? highlightedRequestId;

  @override
  State<BarberCustomersScreen> createState() => _BarberCustomersScreenState();
}

class _BarberCustomersScreenState extends State<BarberCustomersScreen> {
  late final BarberCustomersController controller;

  final Map<String, GlobalKey> _requestCardKeys = <String, GlobalKey>{};
  bool _didScrollToHighlightedRequest = false;

  @override
  void initState() {
    super.initState();
    controller = BarberCustomersController();
    controller.changeTab(widget.initialTab);
    controller.loadInitialData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _scheduleScrollToHighlightedRequest() {
    final String? highlightedRequestId = widget.highlightedRequestId;

    if (_didScrollToHighlightedRequest ||
        highlightedRequestId == null ||
        highlightedRequestId.isEmpty ||
        controller.activeTab != BarberCustomersTab.requests) {
      return;
    }

    final GlobalKey? requestKey = _requestCardKeys[highlightedRequestId];

    if (requestKey == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didScrollToHighlightedRequest) {
        return;
      }

      final BuildContext? requestContext = requestKey.currentContext;

      if (requestContext == null) {
        return;
      }

      _didScrollToHighlightedRequest = true;

      Scrollable.ensureVisible(
        requestContext,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
    });
  }

  Future<void> _confirmBlockCustomer(LinkedCustomerProfile customer) async {
    final bool? confirmed = await _showConfirmDialog(
      title: 'منع الزبون',
      message:
          'هل تريد منع ${customer.displayName.isEmpty ? 'هذا الزبون' : customer.displayName} من الحجز عندك؟',
      confirmText: 'منع الزبون',
      color: const Color(0xFFDC2626),
    );

    if (confirmed != true) return;

    await controller.blockCustomer(customer);
  }

  Future<void> _confirmUnblockCustomer(LinkedCustomerProfile customer) async {
    final bool? confirmed = await _showConfirmDialog(
      title: 'إعادة السماح',
      message:
          'هل تريد إعادة السماح لـ ${customer.displayName.isEmpty ? 'هذا الزبون' : customer.displayName} بالحجز عندك؟',
      confirmText: 'إعادة السماح',
      color: const Color(0xFF16A34A),
    );

    if (confirmed != true) return;

    await controller.unblockCustomer(customer);
  }

  Future<void> _confirmAcceptRequest(BarberCustomerRequestModel request) async {
    final bool? confirmed = await _showConfirmDialog(
      title: 'قبول الطلب',
      message:
          'هل تريد قبول طلب ${request.customer.displayName.isEmpty ? 'هذا الزبون' : request.customer.displayName} والسماح له بالحجز عندك؟',
      confirmText: 'قبول الطلب',
      color: const Color(0xFF16A34A),
    );

    if (confirmed != true) return;

    await controller.acceptRequest(request);
  }

  Future<void> _confirmRejectRequest(BarberCustomerRequestModel request) async {
    final bool? confirmed = await _showConfirmDialog(
      title: 'رفض الطلب',
      message:
          'هل تريد رفض طلب ${request.customer.displayName.isEmpty ? 'هذا الزبون' : request.customer.displayName}؟',
      confirmText: 'رفض الطلب',
      color: const Color(0xFFDC2626),
    );

    if (confirmed != true) return;

    await controller.rejectRequest(request);
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color color,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.6, fontWeight: FontWeight.w600),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('رجوع'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: color),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(confirmText),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        _scheduleScrollToHighlightedRequest();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              titleSpacing: 0,
              title: const SizedBox.shrink(),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _CustomersIntroCard(),
                    const SizedBox(height: 14),

                    _CustomersTabs(
                      activeTab: controller.activeTab,
                      requestsCount: controller.pendingRequests.length,
                      onTabChanged: controller.changeTab,
                    ),

                    const SizedBox(height: 14),

                    if (controller.errorMessage != null) ...[
                      _MessageBanner(
                        message: controller.errorMessage!,
                        isError: true,
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (controller.successMessage != null) ...[
                      _MessageBanner(
                        message: controller.successMessage!,
                        isError: false,
                      ),
                      const SizedBox(height: 12),
                    ],

                    _buildActiveTabContent(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveTabContent() {
    switch (controller.activeTab) {
      case BarberCustomersTab.addCustomer:
        return _AddCustomerTab(controller: controller);

      case BarberCustomersTab.accessManagement:
        return _AccessManagementTab(
          controller: controller,
          onBlockCustomer: _confirmBlockCustomer,
        );

      case BarberCustomersTab.blockedCustomers:
        return _BlockedCustomersTab(
          controller: controller,
          onUnblockCustomer: _confirmUnblockCustomer,
        );

      case BarberCustomersTab.requests:
        return _RequestsTab(
          controller: controller,
          highlightedRequestId: widget.highlightedRequestId,
          requestCardKeys: _requestCardKeys,
          onAcceptRequest: _confirmAcceptRequest,
          onRejectRequest: _confirmRejectRequest,
        );
    }
  }
}

class _CustomersIntroCard extends StatelessWidget {
  const _CustomersIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9A5A38), Color(0xFFC47A3D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups_rounded, color: Colors.white, size: 15),
                SizedBox(width: 6),
                Text(
                  'Customer Access Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'الزبائن',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'إدارة صلاحيات الزبائن، المنع، وطلبات الحجز الأخرى بسهولة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomersTabs extends StatelessWidget {
  const _CustomersTabs({
    required this.activeTab,
    required this.requestsCount,
    required this.onTabChanged,
  });

  final BarberCustomersTab activeTab;
  final int requestsCount;
  final ValueChanged<BarberCustomersTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CustomersTabButton(
                label: 'إضافة زبون',
                icon: Icons.person_add_alt_1_rounded,
                isActive: activeTab == BarberCustomersTab.addCustomer,
                onTap: () => onTabChanged(BarberCustomersTab.addCustomer),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CustomersTabButton(
                label: 'إدارة الوصول',
                icon: Icons.manage_accounts_rounded,
                isActive: activeTab == BarberCustomersTab.accessManagement,
                onTap: () => onTabChanged(BarberCustomersTab.accessManagement),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CustomersTabButton(
                label: 'الممنوعين',
                icon: Icons.block_rounded,
                isActive: activeTab == BarberCustomersTab.blockedCustomers,
                onTap: () => onTabChanged(BarberCustomersTab.blockedCustomers),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CustomersTabButton(
                label: 'الطلبات',
                icon: Icons.inbox_rounded,
                badgeCount: requestsCount,
                isActive: activeTab == BarberCustomersTab.requests,
                onTap: () => onTabChanged(BarberCustomersTab.requests),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomersTabButton extends StatelessWidget {
  const _CustomersTabButton({
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
      color: isActive
          ? activeColor.withValues(alpha: 0.14)
          : AppThemeColors.card(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.45)
                  : AppThemeColors.border(context),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive
                    ? activeColor
                    : AppThemeColors.textSecondary(context),
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? activeColor
                        : AppThemeColors.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                _TabBadge(count: badgeCount),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final String label = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.isError});

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

class _AddCustomerTab extends StatelessWidget {
  const _AddCustomerTab({required this.controller});

  final BarberCustomersController controller;

  @override
  Widget build(BuildContext context) {
    final LinkedCustomerProfile? customer = controller.foundCustomer;

    return _SectionCard(
      title: 'إضافة زبون من خارج منطقتك',
      subtitle:
          'استخدم هذا التبويب للسماح لزبون مسجل من خارج منطقة الصالون بالحجز عندك.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhoneSearchRow(
            controller: controller.phoneController,
            isLoading: controller.isSearchingCustomer,
            onSearchTap: controller.searchCustomer,
          ),
          if (customer != null) ...[
            const SizedBox(height: 14),
            _FoundCustomerCard(
              customer: customer,
              isLinking: controller.isLinkingCustomer,
              canAllow: controller.canAllowFoundCustomer,
              statusMessage: controller.foundCustomerAccessMessage,
              onAllowTap: controller.allowFoundCustomer,
            ),
          ],
        ],
      ),
    );
  }
}

class _AccessManagementTab extends StatelessWidget {
  const _AccessManagementTab({
    required this.controller,
    required this.onBlockCustomer,
  });

  final BarberCustomersController controller;
  final ValueChanged<LinkedCustomerProfile> onBlockCustomer;

  @override
  Widget build(BuildContext context) {
    final bool isTodayView =
        controller.activeAccessManagementView ==
        AccessManagementView.todayCustomers;

    return Column(
      children: [
        _AccessManagementInnerTabs(
          activeView: controller.activeAccessManagementView,
          onViewChanged: controller.changeAccessManagementView,
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: isTodayView
              ? 'زبائن تعاملوا معك اليوم'
              : 'بحث باستخدام الاسم أو رقم الهاتف',
          subtitle: isTodayView
              ? 'اعرض الزبائن المسجلين الذين تعاملوا معك اليوم حتى تستطيع منع أي زبون مزعج بسرعة.'
              : 'ابحث عن زبون من نفس منطقة الصالون أو زبون مسموح له بالحجز عندك، ثم يمكنك منعه عند الحاجة.',
          child: isTodayView
              ? _TodayCustomersList(
                  controller: controller,
                  onBlockCustomer: onBlockCustomer,
                )
              : _PreviousCustomersSearch(
                  controller: controller,
                  onBlockCustomer: onBlockCustomer,
                ),
        ),
      ],
    );
  }
}

class _AccessManagementInnerTabs extends StatelessWidget {
  const _AccessManagementInnerTabs({
    required this.activeView,
    required this.onViewChanged,
  });

  final AccessManagementView activeView;
  final ValueChanged<AccessManagementView> onViewChanged;

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
            child: _AccessManagementInnerTabButton(
              label: 'زبائن تعاملوا معك اليوم',
              icon: Icons.today_rounded,
              isActive: activeView == AccessManagementView.todayCustomers,
              onTap: () => onViewChanged(AccessManagementView.todayCustomers),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _AccessManagementInnerTabButton(
              label: 'بحث بالاسم أو الهاتف',
              icon: Icons.search_rounded,
              isActive: activeView == AccessManagementView.searchByNameOrPhone,
              onTap: () =>
                  onViewChanged(AccessManagementView.searchByNameOrPhone),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessManagementInnerTabButton extends StatelessWidget {
  const _AccessManagementInnerTabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? activeColor : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? Colors.white
                    : AppThemeColors.textSecondary(context),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : AppThemeColors.textSecondary(context),
                    fontSize: 12.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCustomersList extends StatelessWidget {
  const _TodayCustomersList({
    required this.controller,
    required this.onBlockCustomer,
  });

  final BarberCustomersController controller;
  final ValueChanged<LinkedCustomerProfile> onBlockCustomer;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingTodayCustomers) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.todayCustomers.isEmpty) {
      return const _InlineEmptyState(
        icon: Icons.today_rounded,
        message: 'لا يوجد زبائن مسجلون تعاملوا معك اليوم.',
      );
    }

    return Column(
      children: controller.todayCustomers.map((customer) {
        return _AccessCustomerCard(
          customer: customer,
          actionText: 'منع الحجز',
          actionIcon: Icons.block_rounded,
          actionColor: const Color(0xFFDC2626),
          isLoading: controller.isBlockingCustomer,
          onActionTap: () => onBlockCustomer(customer),
        );
      }).toList(),
    );
  }
}

class _PreviousCustomersSearch extends StatelessWidget {
  const _PreviousCustomersSearch({
    required this.controller,
    required this.onBlockCustomer,
  });

  final BarberCustomersController controller;
  final ValueChanged<LinkedCustomerProfile> onBlockCustomer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TextSearchRow(
          controller: controller.previousCustomerSearchController,
          isLoading: controller.isSearchingPreviousCustomers,
          onSearchTap: controller.searchPreviousCustomers,
        ),
        if (controller.previousCustomerSearchResults.isNotEmpty) ...[
          const SizedBox(height: 14),
          ...controller.previousCustomerSearchResults.map((customer) {
            return _AccessCustomerCard(
              customer: customer,
              actionText: 'منع الحجز',
              actionIcon: Icons.block_rounded,
              actionColor: const Color(0xFFDC2626),
              isLoading: controller.isBlockingCustomer,
              onActionTap: () => onBlockCustomer(customer),
            );
          }),
        ],
      ],
    );
  }
}

class _BlockedCustomersTab extends StatelessWidget {
  const _BlockedCustomersTab({
    required this.controller,
    required this.onUnblockCustomer,
  });

  final BarberCustomersController controller;
  final ValueChanged<LinkedCustomerProfile> onUnblockCustomer;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingBlockedCustomers) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.blockedCustomers.isEmpty) {
      return _EmptyStateCard(
        icon: Icons.block_rounded,
        title: 'لا يوجد زبائن ممنوعون',
        message: 'أي زبون تمنعه من إدارة الوصول سيظهر هنا.',
      );
    }

    return Column(
      children: controller.blockedCustomers.map((customer) {
        return _AccessCustomerCard(
          customer: customer,
          actionText: 'إعادة السماح',
          actionIcon: Icons.verified_user_rounded,
          actionColor: const Color(0xFF16A34A),
          isLoading: controller.isUnblockingCustomer,
          onActionTap: () => onUnblockCustomer(customer),
        );
      }).toList(),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({
    required this.controller,
    required this.highlightedRequestId,
    required this.requestCardKeys,
    required this.onAcceptRequest,
    required this.onRejectRequest,
  });

  final BarberCustomersController controller;
  final String? highlightedRequestId;
  final Map<String, GlobalKey> requestCardKeys;
  final ValueChanged<BarberCustomerRequestModel> onAcceptRequest;
  final ValueChanged<BarberCustomerRequestModel> onRejectRequest;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingRequests) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.pendingRequests.isEmpty) {
      return _EmptyStateCard(
        icon: Icons.inbox_rounded,
        title: 'لا توجد طلبات حاليًا',
        message:
            'سيظهر هنا الزبائن الذين يرسلون طلبات للحجز عندك من مناطق أخرى.',
      );
    }

    return Column(
      children: controller.pendingRequests.map((request) {
        final bool isHighlighted =
            highlightedRequestId != null &&
            highlightedRequestId!.isNotEmpty &&
            request.id == highlightedRequestId;

        final GlobalKey requestKey = requestCardKeys.putIfAbsent(
          request.id,
          () => GlobalKey(),
        );

        return _RequestCard(
          key: requestKey,
          request: request,
          isHighlighted: isHighlighted,
          isResponding: controller.isRespondingToRequest,
          onAcceptTap: () => onAcceptRequest(request),
          onRejectTap: () => onRejectRequest(request),
        );
      }).toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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

class _PhoneSearchRow extends StatelessWidget {
  const _PhoneSearchRow({
    required this.controller,
    required this.isLoading,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return _SearchRow(
      controller: controller,
      hintText: 'مثال: 0599350166',
      icon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      isLoading: isLoading,
      buttonText: 'بحث',
      onSearchTap: onSearchTap,
    );
  }
}

class _TextSearchRow extends StatelessWidget {
  const _TextSearchRow({
    required this.controller,
    required this.isLoading,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return _SearchRow(
      controller: controller,
      hintText: 'ابحث بالاسم أو رقم الهاتف',
      icon: Icons.search_rounded,
      keyboardType: TextInputType.text,
      isLoading: isLoading,
      buttonText: 'بحث',
      onSearchTap: onSearchTap,
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.keyboardType,
    required this.isLoading,
    required this.buttonText,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isLoading;
  final String buttonText;
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
                Icon(icon, color: const Color(0xFFC47A3D), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    onSubmitted: (_) => onSearchTap(),
                    style: TextStyle(
                      color: AppThemeColors.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
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
                : Text(
                    buttonText,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ),
      ],
    );
  }
}

class _FoundCustomerCard extends StatelessWidget {
  const _FoundCustomerCard({
    required this.customer,
    required this.isLinking,
    required this.canAllow,
    required this.statusMessage,
    required this.onAllowTap,
  });

  final LinkedCustomerProfile customer;
  final bool isLinking;
  final bool canAllow;
  final String? statusMessage;
  final VoidCallback onAllowTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CustomerIdentityBlock(customer: customer),
          if (statusMessage != null && statusMessage!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _CustomerAccessHintBox(message: statusMessage!),
          ],
          if (canAllow) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isLinking ? null : onAllowTap,
              icon: isLinking
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.verified_user_rounded),
              label: Text(
                isLinking ? 'جاري التنفيذ...' : 'السماح له بالحجز',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
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

class _CustomerAccessHintBox extends StatelessWidget {
  const _CustomerAccessHintBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFC47A3D).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC47A3D).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFC47A3D),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 12.8,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessCustomerCard extends StatelessWidget {
  const _AccessCustomerCard({
    required this.customer,
    required this.actionText,
    required this.actionIcon,
    required this.actionColor,
    required this.isLoading,
    required this.onActionTap,
  });

  final LinkedCustomerProfile customer;
  final String actionText;
  final IconData actionIcon;
  final Color actionColor;
  final bool isLoading;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CustomerIdentityBlock(customer: customer),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: isLoading ? null : onActionTap,
            icon: isLoading
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(actionIcon),
            label: Text(
              isLoading ? 'جاري التنفيذ...' : actionText,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    super.key,
    required this.request,
    required this.isHighlighted,
    required this.isResponding,
    required this.onAcceptTap,
    required this.onRejectTap,
  });

  final BarberCustomerRequestModel request;
  final bool isHighlighted;
  final bool isResponding;
  final VoidCallback onAcceptTap;
  final VoidCallback onRejectTap;

  @override
  Widget build(BuildContext context) {
    final Color highlightColor = const Color(0xFFC47A3D);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isHighlighted
            ? highlightColor.withValues(alpha: 0.10)
            : AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted
              ? highlightColor
              : AppThemeColors.border(context),
          width: isHighlighted ? 1.8 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: highlightColor.withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CustomerIdentityBlock(customer: request.customer),

          if (isHighlighted) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFC47A3D).withValues(alpha: 0.24),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFFC47A3D),
                    size: 18,
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'هذا هو الطلب القادم من الإشعار',
                      style: TextStyle(
                        color: Color(0xFFC47A3D),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              request.message!,
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 12.8,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isResponding ? null : onAcceptTap,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'قبول',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isResponding ? null : onRejectTap,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text(
                    'رفض',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerIdentityBlock extends StatelessWidget {
  const _CustomerIdentityBlock({required this.customer});

  final LinkedCustomerProfile customer;

  @override
  Widget build(BuildContext context) {
    final String displayName = customer.displayName.isEmpty
        ? 'زبون مسجل'
        : customer.displayName;

    return Row(
      children: [
        _CustomerAvatar(
          avatarUrl: customer.avatarUrl,
          displayName: displayName,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppThemeColors.textPrimary(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                customer.phoneNumber,
                style: TextStyle(
                  color: AppThemeColors.textSecondary(context),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.place_rounded,
                    color: Color(0xFF16A34A),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      customer.locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.avatarUrl, required this.displayName});

  final String? avatarUrl;
  final String displayName;

  String get _firstLetter {
    final String cleanedName = displayName.trim();

    if (cleanedName.isEmpty || cleanedName == 'زبون مسجل') {
      return 'ز';
    }

    return cleanedName.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final String? cleanAvatarUrl = avatarUrl?.trim();

    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFC47A3D).withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC47A3D).withValues(alpha: 0.22),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: cleanAvatarUrl == null || cleanAvatarUrl.isEmpty
            ? _CustomerAvatarFallback(firstLetter: _firstLetter)
            : Image.network(
                cleanAvatarUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return _CustomerAvatarFallback(firstLetter: _firstLetter);
                },
              ),
      ),
    );
  }
}

class _CustomerAvatarFallback extends StatelessWidget {
  const _CustomerAvatarFallback({required this.firstLetter});

  final String firstLetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFC47A3D).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Color(0xFFC47A3D),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeColors.softCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppThemeColors.textMuted(context), size: 24),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppThemeColors.textSecondary(context),
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
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
