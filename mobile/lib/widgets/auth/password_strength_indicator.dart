import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatefulWidget {
  const PasswordStrengthIndicator({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator> {
  bool _showRules = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final password = widget.controller.text;
        final analysis = _PasswordAnalysis.from(password);

        if (password.isEmpty) {
          return const SizedBox.shrink();
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _showRules = !_showRules;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StrengthHeader(analysis: analysis, showRules: _showRules),
                  const SizedBox(height: 9),
                  _StrengthBar(analysis: analysis),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.08),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _showRules
                        ? Padding(
                            key: const ValueKey('rules-visible'),
                            padding: const EdgeInsets.only(top: 11),
                            child: Column(
                              children: [
                                _PasswordRuleRow(
                                  isValid: analysis.hasMinLength,
                                  text: '8 أحرف على الأقل',
                                ),
                                const SizedBox(height: 7),
                                _PasswordRuleRow(
                                  isValid: analysis.hasNumber,
                                  text: 'يحتوي على رقم',
                                ),
                                const SizedBox(height: 7),
                                _PasswordRuleRow(
                                  isValid: analysis.hasSymbol,
                                  text: 'يحتوي على رمز مثل @ أو # أو \$',
                                ),
                                const SizedBox(height: 7),
                                _PasswordRuleRow(
                                  isValid: analysis.hasUpperAndLowerCase,
                                  text: 'يحتوي على حروف كبيرة وصغيرة',
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            key: const ValueKey('rules-hidden'),
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(
                              'اضغط لعرض شروط كلمة المرور',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.48),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StrengthHeader extends StatelessWidget {
  const _StrengthHeader({required this.analysis, required this.showRules});

  final _PasswordAnalysis analysis;
  final bool showRules;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(analysis.icon, color: analysis.color, size: 17),
        const SizedBox(width: 7),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: analysis.label,
                  style: TextStyle(
                    color: analysis.color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        Icon(
          showRules
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: Colors.white.withValues(alpha: 0.55),
          size: 21,
        ),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.analysis});

  final _PasswordAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index < analysis.level;

        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 4.5,
            margin: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 4),
            decoration: BoxDecoration(
              color: isActive
                  ? analysis.color
                  : Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _PasswordRuleRow extends StatelessWidget {
  const _PasswordRuleRow({required this.isValid, required this.text});

  final bool isValid;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = isValid
        ? const Color(0xFF4ADE80)
        : Colors.white.withValues(alpha: 0.46);

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            color: isValid
                ? const Color(0xFF4ADE80).withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: isValid
                  ? const Color(0xFF4ADE80)
                  : Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Icon(
            isValid ? Icons.check_rounded : Icons.close_rounded,
            color: color,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isValid ? FontWeight.w700 : FontWeight.w500,
              decoration: isValid ? TextDecoration.lineThrough : null,
              decorationColor: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordAnalysis {
  const _PasswordAnalysis({
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasSymbol,
    required this.hasUpperAndLowerCase,
  });

  factory _PasswordAnalysis.from(String password) {
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);

    return _PasswordAnalysis(
      hasMinLength: password.length >= 8,
      hasNumber: RegExp(r'[0-9]').hasMatch(password),
      hasSymbol: RegExp(
        r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\[\]؛،]',
      ).hasMatch(password),
      hasUpperAndLowerCase: hasLowerCase && hasUpperCase,
    );
  }

  final bool hasMinLength;
  final bool hasNumber;
  final bool hasSymbol;
  final bool hasUpperAndLowerCase;

  int get score {
    var value = 0;

    if (hasMinLength) value++;
    if (hasNumber) value++;
    if (hasSymbol) value++;
    if (hasUpperAndLowerCase) value++;

    return value;
  }

  int get level {
    if (score <= 1) return 1;
    if (score == 2) return 2;
    if (score == 3) return 3;
    return 4;
  }

  String get label {
    if (score <= 1) return 'ضعيفة';
    if (score == 2) return 'مقبولة';
    if (score == 3) return 'جيدة';
    return 'قوية';
  }

  Color get color {
    if (score <= 1) return const Color(0xFFEF4444);
    if (score == 2) return const Color(0xFFF59E0B);
    if (score == 3) return const Color(0xFF38BDF8);
    return const Color(0xFF4ADE80);
  }

  IconData get icon {
    if (score <= 1) return Icons.warning_rounded;
    if (score == 2) return Icons.info_rounded;
    if (score == 3) return Icons.verified_rounded;
    return Icons.shield_rounded;
  }
}
