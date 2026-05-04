import 'package:flutter/material.dart';

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  State<CustomerSettingsScreen> createState() => _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  bool notificationsEnabled = true;
  bool isDarkMode = false;

  void _toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notificationsEnabled
              ? 'تم تفعيل إشعارات المواعيد'
              : 'تم إيقاف إشعارات المواعيد',
        ),
      ),
    );
  }

  void _setThemeMode(bool dark) {
    setState(() {
      isDarkMode = dark;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDarkMode
              ? 'تم اختيار النمط الداكن مؤقتًا'
              : 'تم اختيار النمط الفاتح مؤقتًا',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageBackground =
        isDarkMode ? const Color(0xFF111827) : Colors.white;

    final Color textColor =
        isDarkMode ? Colors.white : const Color(0xFF111827);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: pageBackground,
          surfaceTintColor: pageBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const _CustomerSettingsIntroCard(),

            const SizedBox(height: 16),

            _CustomerNotificationsCard(
              notificationsEnabled: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),

            const SizedBox(height: 14),

            _CustomerAppearanceCard(
              isDarkMode: isDarkMode,
              onSelectLight: () => _setThemeMode(false),
              onSelectDark: () => _setThemeMode(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerSettingsIntroCard extends StatelessWidget {
  const _CustomerSettingsIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6E3F2F),
            Color(0xFF9B5A3D),
            Color(0xFFC37A49),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CustomerSettingsCenterPill(),
          SizedBox(height: 14),
          Text(
            'الإعدادات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111111),
              height: 1.1,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'تحكم بإشعارات المواعيد ومظهر التطبيق بسهولة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerSettingsCenterPill extends StatelessWidget {
  const _CustomerSettingsCenterPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Customer Settings',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.settings_rounded,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerNotificationsCard extends StatelessWidget {
  const _CustomerNotificationsCard({
    required this.notificationsEnabled,
    required this.onChanged,
  });

  final bool notificationsEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        notificationsEnabled ? const Color(0xFF16A34A) : const Color(0xFFEF4444);

    return _CustomerSettingsCardShell(
      child: Column(
        children: [
          Row(
            children: [
              _SettingsIconBox(
                icon: Icons.notifications_active_rounded,
                color: const Color(0xFFC47A3D),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إشعارات المواعيد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'نستخدمها لتذكيرك قبل موعدك بـ 15 دقيقة وتنبيهك عند تأكيد أو تغيير حالة الحجز.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _StatusPill(
                  label: notificationsEnabled
                      ? 'الإشعارات مفعلة'
                      : 'الإشعارات متوقفة',
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Switch(
                value: notificationsEnabled,
                activeThumbColor: const Color(0xFF16A34A),
                onChanged: onChanged,
              ),
            ],
          ),

          const SizedBox(height: 12),

          const _PermissionHintBox(),
        ],
      ),
    );
  }
}

class _PermissionHintBox extends StatelessWidget {
  const _PermissionHintBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8D8B8),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_rounded,
            color: Color(0xFFC47A3D),
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'قد يطلب الهاتف إذنًا إضافيًا لتفعيل الإشعارات الخارجية. بدون هذا الإذن لن يصلك تنبيه خارج التطبيق.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.55,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B4F3E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerAppearanceCard extends StatelessWidget {
  const _CustomerAppearanceCard({
    required this.isDarkMode,
    required this.onSelectLight,
    required this.onSelectDark,
  });

  final bool isDarkMode;
  final VoidCallback onSelectLight;
  final VoidCallback onSelectDark;

  @override
  Widget build(BuildContext context) {
    return _CustomerSettingsCardShell(
      child: Column(
        children: [
          Row(
            children: [
              _SettingsIconBox(
                icon: isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: isDarkMode
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نمط التطبيق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'اختر النمط الفاتح أو الداكن حسب راحتك أثناء استخدام التطبيق.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F3ED),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE8D8B8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ThemeModeButton(
                    label: 'فاتح',
                    icon: Icons.light_mode_rounded,
                    isActive: !isDarkMode,
                    onTap: onSelectLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ThemeModeButton(
                    label: 'داكن',
                    icon: Icons.dark_mode_rounded,
                    isActive: isDarkMode,
                    onTap: onSelectDark,
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

class _CustomerSettingsCardShell extends StatelessWidget {
  const _CustomerSettingsCardShell({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFEDF1F3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingsIconBox extends StatelessWidget {
  const _SettingsIconBox({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
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
    final Color activeColor = const Color(0xFF9A5A38);

    return Material(
      color: isActive ? activeColor : Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x229A5A38),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isActive ? Colors.white : const Color(0xFF6B5D52),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : const Color(0xFF6B5D52),
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