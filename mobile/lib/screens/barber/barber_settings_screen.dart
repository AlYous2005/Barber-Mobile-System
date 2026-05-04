import 'package:flutter/material.dart';

class BarberSettingsScreen extends StatefulWidget {
  const BarberSettingsScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<BarberSettingsScreen> createState() => _BarberSettingsScreenState();
}

class _BarberSettingsScreenState extends State<BarberSettingsScreen> {
  bool notificationsEnabled = true;
  bool isDarkMode = false;
  bool hasSalonImage = false;

  void _toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notificationsEnabled
              ? 'تم تفعيل إشعارات التطبيق'
              : 'تم إيقاف إشعارات التطبيق',
        ),
      ),
    );
  }

  void _toggleThemeMode(bool value) {
    setState(() {
      isDarkMode = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDarkMode
              ? 'تم اختيار الوضع الداكن مؤقتًا'
              : 'تم اختيار الوضع الفاتح مؤقتًا',
        ),
      ),
    );
  }

  void _addOrChangeSalonImage() {
    setState(() {
      hasSalonImage = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasSalonImage
              ? 'تم تحديث صورة الصالون مؤقتًا'
              : 'تمت إضافة صورة الصالون مؤقتًا',
        ),
      ),
    );
  }

  void _removeSalonImage() {
    setState(() {
      hasSalonImage = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إزالة صورة الصالون مؤقتًا')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageBackground = isDarkMode
        ? const Color(0xFF111827)
        : Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          title: Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isDarkMode ? Colors.white : const Color(0xFF111827),
            ),
          ),
          centerTitle: true,
          backgroundColor: pageBackground,
          surfaceTintColor: pageBackground,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : const Color(0xFF111827),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const _SettingsIntroCard(),
            const SizedBox(height: 16),

            _SalonImageSettingsCard(
              hasSalonImage: hasSalonImage,
              onAddOrChangeImage: _addOrChangeSalonImage,
              onRemoveImage: _removeSalonImage,
            ),
            const SizedBox(height: 16),

            _NotificationsSettingsCard(
              notificationsEnabled: notificationsEnabled,
              onToggle: _toggleNotifications,
            ),

            const SizedBox(height: 14),

            _ThemeSettingsCard(
              isDarkMode: isDarkMode,
              onChanged: _toggleThemeMode,
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _SettingsIntroCard extends StatelessWidget {
  const _SettingsIntroCard();

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
          colors: [Color(0xFF6E3F2F), Color(0xFF9B5A3D), Color(0xFFC37A49)],
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
          _SettingsCenterPill(),

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
            'تحكم بإشعارات التطبيق والمظهر العام بسهولة',
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

class _SettingsCenterPill extends StatelessWidget {
  const _SettingsCenterPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Settings Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.settings_rounded, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSettingsCard extends StatelessWidget {
  const _NotificationsSettingsCard({
    required this.notificationsEnabled,
    required this.onToggle,
  });

  final bool notificationsEnabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = notificationsEnabled
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    return _SettingsCardShell(
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
                      'إشعارات التطبيق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'فعّل أو أوقف إشعارات الحجوزات الجديدة وتحديثات المواعيد.',
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
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeSettingsCard extends StatelessWidget {
  const _ThemeSettingsCard({required this.isDarkMode, required this.onChanged});

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsCardShell(
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
                      'مظهر التطبيق',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'اختر بين الوضع الفاتح أو الداكن حسب راحتك أثناء العمل.',
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
              border: Border.all(color: const Color(0xFFE8D8B8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ThemeModeButton(
                    label: 'Light',
                    icon: Icons.light_mode_rounded,
                    isActive: !isDarkMode,
                    onTap: () => onChanged(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ThemeModeButton(
                    label: 'Dark',
                    icon: Icons.dark_mode_rounded,
                    isActive: isDarkMode,
                    onTap: () => onChanged(true),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _StatusPill(
            label: isDarkMode
                ? 'الوضع الداكن مختار حاليًا'
                : 'الوضع الفاتح مختار حاليًا',
            color: isDarkMode
                ? const Color(0xFF6366F1)
                : const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

class _SettingsCardShell extends StatelessWidget {
  const _SettingsCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEDF1F3)),
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
  const _SettingsIconBox({required this.icon, required this.color});

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
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: color, size: 22),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

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
        border: Border.all(color: color.withValues(alpha: 0.18)),
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


class _SalonImageSettingsCard extends StatelessWidget {
  const _SalonImageSettingsCard({
    required this.hasSalonImage,
    required this.onAddOrChangeImage,
    required this.onRemoveImage,
  });

  final bool hasSalonImage;
  final VoidCallback onAddOrChangeImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return _SettingsCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SettingsIconBox(
                icon: Icons.storefront_rounded,
                color: const Color(0xFFC47A3D),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صورة الصالون',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'هذه الصورة ستظهر للعامة والزبائن عند قيامهم بالحجز. ينصح أن تبدو احترافية لتعكس صورة الصالون الجميلة.',
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

          if (hasSalonImage) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF2A2018),
                    Color(0xFF6E3F2F),
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                    ),
                  ),

                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'معاينة صورة الصالون',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'سيتم عرض الصورة هنا بعد ربط الرفع الحقيقي',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _SalonImageButton(
                  label: hasSalonImage ? 'تعديل الصورة' : 'إضافة صورة',
                  icon: hasSalonImage
                      ? Icons.edit_rounded
                      : Icons.add_photo_alternate_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: onAddOrChangeImage,
                ),
              ),

              if (hasSalonImage) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _SalonImageButton(
                    label: 'إزالة الصورة',
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: onRemoveImage,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SalonImageButton extends StatelessWidget {
  const _SalonImageButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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