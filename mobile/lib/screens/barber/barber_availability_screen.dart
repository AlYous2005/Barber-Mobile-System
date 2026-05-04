import 'package:flutter/material.dart';

class BarberAvailabilityScreen extends StatefulWidget {
  const BarberAvailabilityScreen({super.key});

  @override
  State<BarberAvailabilityScreen> createState() =>
      _BarberAvailabilityScreenState();
}

class _BarberAvailabilityScreenState extends State<BarberAvailabilityScreen> {
  String selectedTab = 'closures';

  final TextEditingController _closureReasonController =
      TextEditingController();
  final TextEditingController _timeBlockReasonController =
      TextEditingController();

  DateTime? selectedClosureDate;

  String timeBlockMode = 'recurring';
  DateTime? selectedTimeBlockDate;
  String selectedStartTime = '13:00';
  String selectedEndTime = '14:00';

  late List<_ClosureDay> closures;
  late List<_TimeBlock> timeBlocks;

  @override
  void initState() {
    super.initState();

    closures = [
      _ClosureDay(
        id: 'c1',
        dateLabel: '15/5/2026',
        reason: 'إجازة خاصة',
      ),
      _ClosureDay(
        id: 'c2',
        dateLabel: '22/5/2026',
        reason: 'ظرف طارئ',
      ),
    ];

    timeBlocks = [
      _TimeBlock(
        id: 't1',
        type: 'recurring',
        dateLabel: null,
        startTime: '13:00',
        endTime: '14:00',
        reason: 'استراحة غداء',
      ),
      _TimeBlock(
        id: 't2',
        type: 'specific',
        dateLabel: '18/5/2026',
        startTime: '17:00',
        endTime: '18:30',
        reason: 'مشوار خاص',
      ),
    ];
  }

  @override
  void dispose() {
    _closureReasonController.dispose();
    _timeBlockReasonController.dispose();
    super.dispose();
  }

  Future<void> _pickClosureDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedClosureDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedClosureDate = pickedDate;
    });
  }

  Future<void> _pickTimeBlockDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedTimeBlockDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedTimeBlockDate = pickedDate;
    });
  }

  Future<void> _pickStartTime() async {
    final String? picked = await _pickTime(
      context: context,
      initialValue: selectedStartTime,
    );

    if (picked == null) return;

    setState(() {
      selectedStartTime = picked;
    });
  }

  Future<void> _pickEndTime() async {
    final String? picked = await _pickTime(
      context: context,
      initialValue: selectedEndTime,
    );

    if (picked == null) return;

    setState(() {
      selectedEndTime = picked;
    });
  }

  static Future<String?> _pickTime({
    required BuildContext context,
    required String initialValue,
  }) async {
    final parts = initialValue.split(':');
    final hour = int.tryParse(parts.first) ?? 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );

    if (picked == null) return null;

    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'اختر التاريخ';
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _formatTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final time = TimeOfDay(hour: hour, minute: minute);
    final displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final displayMinute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحًا' : 'مساءً';

    return '$displayHour:$displayMinute $period';
  }

  void _addClosure() {
    if (selectedClosureDate == null) {
      _showMessage('يرجى اختيار تاريخ الإغلاق');
      return;
    }

    final String reason = _closureReasonController.text.trim();

    setState(() {
      closures.insert(
        0,
        _ClosureDay(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          dateLabel: _dateLabel(selectedClosureDate),
          reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
        ),
      );

      selectedClosureDate = null;
      _closureReasonController.clear();
    });

    _showMessage('تمت إضافة يوم الإغلاق بنجاح');
  }

  void _addTimeBlock() {
    if (timeBlockMode == 'specific' && selectedTimeBlockDate == null) {
      _showMessage('يرجى اختيار تاريخ فترة عدم التوفر');
      return;
    }

    final String reason = _timeBlockReasonController.text.trim();

    setState(() {
      timeBlocks.insert(
        0,
        _TimeBlock(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: timeBlockMode,
          dateLabel:
              timeBlockMode == 'specific' ? _dateLabel(selectedTimeBlockDate) : null,
          startTime: selectedStartTime,
          endTime: selectedEndTime,
          reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
        ),
      );

      selectedTimeBlockDate = null;
      selectedStartTime = '13:00';
      selectedEndTime = '14:00';
      _timeBlockReasonController.clear();
      timeBlockMode = 'recurring';
    });

    _showMessage('تمت إضافة فترة عدم التوفر بنجاح');
  }

  void _deleteClosure(_ClosureDay closure) {
    _showConfirmDialog(
      title: 'حذف يوم الإغلاق',
      message: 'هل تريد حذف يوم الإغلاق بتاريخ ${closure.dateLabel}؟',
      confirmText: 'حذف',
      color: const Color(0xFFEF4444),
      onConfirm: () {
        setState(() {
          closures.removeWhere((item) => item.id == closure.id);
        });

        _showMessage('تم حذف يوم الإغلاق');
      },
    );
  }

  void _deleteTimeBlock(_TimeBlock block) {
    _showConfirmDialog(
      title: 'حذف فترة عدم التوفر',
      message:
          'هل تريد حذف الفترة من ${_formatTime(block.startTime)} إلى ${_formatTime(block.endTime)}؟',
      confirmText: 'حذف',
      color: const Color(0xFFEF4444),
      onConfirm: () {
        setState(() {
          timeBlocks.removeWhere((item) => item.id == block.id);
        });

        _showMessage('تم حذف فترة عدم التوفر');
      },
    );
  }

  void _editClosure(_ClosureDay closure) {
    final TextEditingController reasonController = TextEditingController(
      text: closure.reason,
    );

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SheetHandle(),
                    const SizedBox(height: 16),
                    _SheetHeader(
                      title: 'تعديل يوم الإغلاق',
                      subtitle: closure.dateLabel,
                      icon: Icons.edit_rounded,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 18),
                    _TextInputBox(
                      label: 'سبب الإغلاق',
                      hint: 'مثال: إجازة خاصة / ظرف طارئ',
                      icon: Icons.info_rounded,
                      controller: reasonController,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _PrimaryButton(
                            label: 'حفظ التعديلات',
                            icon: Icons.save_rounded,
                            color: const Color(0xFFC47A3D),
                            onTap: () {
                              setState(() {
                                closures = closures.map((item) {
                                  if (item.id != closure.id) return item;

                                  final String reason =
                                      reasonController.text.trim();

                                  return item.copyWith(
                                    reason: reason.isEmpty
                                        ? 'بدون سبب مذكور'
                                        : reason,
                                  );
                                }).toList();
                              });

                              Navigator.of(context).pop();
                              _showMessage('تم تعديل يوم الإغلاق');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SecondaryButton(
                            label: 'إلغاء',
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(reasonController.dispose);
  }

  void _editTimeBlock(_TimeBlock block) {
    String editType = block.type;
    DateTime? editDate;
    String editStart = block.startTime;
    String editEnd = block.endTime;
    final TextEditingController reasonController = TextEditingController(
      text: block.reason,
    );

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickEditDate() async {
              final DateTime now = DateTime.now();

              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: editDate ?? now,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
              );

              if (pickedDate == null) return;

              setSheetState(() {
                editDate = pickedDate;
              });
            }

            Future<void> pickEditStart() async {
              final picked = await _pickTime(
                context: context,
                initialValue: editStart,
              );

              if (picked == null) return;

              setSheetState(() {
                editStart = picked;
              });
            }

            Future<void> pickEditEnd() async {
              final picked = await _pickTime(
                context: context,
                initialValue: editEnd,
              );

              if (picked == null) return;

              setSheetState(() {
                editEnd = picked;
              });
            }

            void saveEdit() {
              if (editType == 'specific' &&
                  editDate == null &&
                  block.dateLabel == null) {
                _showMessage('يرجى اختيار التاريخ');
                return;
              }

              setState(() {
                timeBlocks = timeBlocks.map((item) {
                  if (item.id != block.id) return item;

                  final String reason = reasonController.text.trim();

                  return item.copyWith(
                    type: editType,
                    dateLabel: editType == 'specific'
                        ? (editDate == null ? block.dateLabel : _dateLabel(editDate))
                        : null,
                    startTime: editStart,
                    endTime: editEnd,
                    reason: reason.isEmpty ? 'بدون سبب مذكور' : reason,
                  );
                }).toList();
              });

              Navigator.of(context).pop();
              _showMessage('تم تعديل فترة عدم التوفر');
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 28,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _SheetHandle(),
                        const SizedBox(height: 16),
                        _SheetHeader(
                          title: 'تعديل فترة عدم التوفر',
                          subtitle: editType == 'recurring'
                              ? 'تتكرر في أيام الدوام'
                              : 'ليوم محدد',
                          icon: Icons.edit_rounded,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 18),
                        _ModeSwitch(
                          selectedMode: editType,
                          onChanged: (value) {
                            setSheetState(() {
                              editType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                        if (editType == 'specific')
                          _PickerBox(
                            label: 'التاريخ',
                            value: editDate == null
                                ? (block.dateLabel ?? 'اختر التاريخ')
                                : _dateLabel(editDate),
                            icon: Icons.calendar_month_rounded,
                            onTap: pickEditDate,
                          )
                        else
                          const _InfoBox(
                            text:
                                'هذه الفترة ستتكرر تلقائيًا على كل يوم مفعّل في ساعات العمل.',
                            icon: Icons.repeat_rounded,
                          ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _PickerBox(
                                label: 'من الساعة',
                                value: _formatTime(editStart),
                                icon: Icons.access_time_rounded,
                                onTap: pickEditStart,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PickerBox(
                                label: 'إلى الساعة',
                                value: _formatTime(editEnd),
                                icon: Icons.access_time_rounded,
                                onTap: pickEditEnd,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _TextInputBox(
                          label: 'السبب',
                          hint: 'مثال: استراحة غداء',
                          icon: Icons.info_rounded,
                          controller: reasonController,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _PrimaryButton(
                                label: 'حفظ التعديلات',
                                icon: Icons.save_rounded,
                                color: const Color(0xFFC47A3D),
                                onTap: saveEdit,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SecondaryButton(
                                label: 'إلغاء',
                                icon: Icons.close_rounded,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(reasonController.dispose);
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color color,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: _PrimaryButton(
                      label: confirmText,
                      icon: Icons.delete_rounded,
                      color: color,
                      onTap: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: _SecondaryButton(
                      label: 'إلغاء',
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).pop(),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosuresTab = selectedTab == 'closures';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
           '',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const _AvailabilityIntroCard(),

            const SizedBox(height: 14),

            _AvailabilitySubnav(
              selectedTab: selectedTab,
              onChanged: (value) {
                setState(() {
                  selectedTab = value;
                });
              },
            ),

            const SizedBox(height: 16),

            if (isClosuresTab) ...[
              _ClosureAddCard(
                selectedDateLabel: _dateLabel(selectedClosureDate),
                reasonController: _closureReasonController,
                onPickDate: _pickClosureDate,
                onAdd: _addClosure,
                onReset: () {
                  setState(() {
                    selectedClosureDate = null;
                    _closureReasonController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),
              _ClosuresList(
                closures: closures,
                onEdit: _editClosure,
                onDelete: _deleteClosure,
              ),
            ] else ...[
              _TimeBlockAddCard(
                selectedMode: timeBlockMode,
                onModeChanged: (value) {
                  setState(() {
                    timeBlockMode = value;
                  });
                },
                selectedDateLabel: _dateLabel(selectedTimeBlockDate),
                startTimeLabel: _formatTime(selectedStartTime),
                endTimeLabel: _formatTime(selectedEndTime),
                reasonController: _timeBlockReasonController,
                onPickDate: _pickTimeBlockDate,
                onPickStartTime: _pickStartTime,
                onPickEndTime: _pickEndTime,
                onAdd: _addTimeBlock,
                onReset: () {
                  setState(() {
                    timeBlockMode = 'recurring';
                    selectedTimeBlockDate = null;
                    selectedStartTime = '13:00';
                    selectedEndTime = '14:00';
                    _timeBlockReasonController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),
              _TimeBlocksList(
                timeBlocks: timeBlocks,
                formatTime: _formatTime,
                onEdit: _editTimeBlock,
                onDelete: _deleteTimeBlock,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvailabilityIntroCard extends StatelessWidget {
  const _AvailabilityIntroCard();

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
          _AvailabilityCenterPill(),
          SizedBox(height: 14),
          Text(
            'التوفر والإغلاقات',
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
            'أدِر أيام الإغلاق وفترات عدم التوفر داخل ساعات الدوام',
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

class _AvailabilityCenterPill extends StatelessWidget {
  const _AvailabilityCenterPill();

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
              'Availability Center',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.calendar_month_rounded,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilitySubnav extends StatelessWidget {
  const _AvailabilitySubnav({
    required this.selectedTab,
    required this.onChanged,
  });

  final String selectedTab;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: _SubnavButton(
              label: 'إغلاقات الأيام',
              icon: Icons.calendar_month_rounded,
              isActive: selectedTab == 'closures',
              onTap: () => onChanged('closures'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SubnavButton(
              label: 'فترات عدم التوفر',
              icon: Icons.access_time_rounded,
              isActive: selectedTab == 'time_blocks',
              onTap: () => onChanged('time_blocks'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubnavButton extends StatelessWidget {
  const _SubnavButton({
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
    const Color activeColor = Color(0xFF9A5A38);

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

class _ClosureAddCard extends StatelessWidget {
  const _ClosureAddCard({
    required this.selectedDateLabel,
    required this.reasonController,
    required this.onPickDate,
    required this.onAdd,
    required this.onReset,
  });

  final String selectedDateLabel;
  final TextEditingController reasonController;
  final VoidCallback onPickDate;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return _AddCardShell(
      icon: Icons.add_rounded,
      title: 'إضافة يوم إغلاق',
      subtitle: 'أضف تاريخ الإغلاق مع السبب بطريقة مرتبة وواضحة',
      child: Column(
        children: [
          _PickerBox(
            label: 'تاريخ الإغلاق',
            value: selectedDateLabel,
            icon: Icons.calendar_month_rounded,
            onTap: onPickDate,
          ),
          const SizedBox(height: 14),
          _TextInputBox(
            label: 'سبب الإغلاق',
            hint: 'مثال: إجازة خاصة / ظرف طارئ',
            icon: Icons.info_rounded,
            controller: reasonController,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PrimaryButton(
                  label: 'إضافة يوم الإغلاق',
                  icon: Icons.add_rounded,
                  color: const Color(0xFFC47A3D),
                  onTap: onAdd,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryButton(
                  label: 'إعادة تعيين',
                  icon: Icons.refresh_rounded,
                  onTap: onReset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBlockAddCard extends StatelessWidget {
  const _TimeBlockAddCard({
    required this.selectedMode,
    required this.onModeChanged,
    required this.selectedDateLabel,
    required this.startTimeLabel,
    required this.endTimeLabel,
    required this.reasonController,
    required this.onPickDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onAdd,
    required this.onReset,
  });

  final String selectedMode;
  final ValueChanged<String> onModeChanged;
  final String selectedDateLabel;
  final String startTimeLabel;
  final String endTimeLabel;
  final TextEditingController reasonController;
  final VoidCallback onPickDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final VoidCallback onAdd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return _AddCardShell(
      icon: Icons.access_time_rounded,
      title: 'إضافة فترة عدم توفر',
      subtitle: 'استراحة متكررة أو فترة خاصة ليوم محدد داخل ساعات العمل',
      child: Column(
        children: [
          _ModeSwitch(
            selectedMode: selectedMode,
            onChanged: onModeChanged,
          ),
          const SizedBox(height: 14),
          if (selectedMode == 'specific')
            _PickerBox(
              label: 'التاريخ',
              value: selectedDateLabel,
              icon: Icons.calendar_month_rounded,
              onTap: onPickDate,
            )
          else
            const _InfoBox(
              text: 'تُطبَّق هذه الفترة تلقائيًا على كل يوم مفعّل في ساعات العمل.',
              icon: Icons.repeat_rounded,
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PickerBox(
                  label: 'من الساعة',
                  value: startTimeLabel,
                  icon: Icons.access_time_rounded,
                  onTap: onPickStartTime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PickerBox(
                  label: 'إلى الساعة',
                  value: endTimeLabel,
                  icon: Icons.access_time_rounded,
                  onTap: onPickEndTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _TextInputBox(
            label: 'السبب',
            hint: 'مثال: استراحة غداء',
            icon: Icons.info_rounded,
            controller: reasonController,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PrimaryButton(
                  label: 'إضافة الفترة',
                  icon: Icons.add_rounded,
                  color: const Color(0xFF6366F1),
                  onTap: onAdd,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryButton(
                  label: 'إعادة تعيين',
                  icon: Icons.refresh_rounded,
                  onTap: onReset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddCardShell extends StatelessWidget {
  const _AddCardShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFBFFFC),
            Color(0xFFF5FBF7),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE3EFE7),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF9A5A38),
                      Color(0xFFB8774A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3020532D),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF5C4030),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _ClosuresList extends StatelessWidget {
  const _ClosuresList({
    required this.closures,
    required this.onEdit,
    required this.onDelete,
  });

  final List<_ClosureDay> closures;
  final ValueChanged<_ClosureDay> onEdit;
  final ValueChanged<_ClosureDay> onDelete;

  @override
  Widget build(BuildContext context) {
    if (closures.isEmpty) {
      return const _EmptyState(
        text: 'لا توجد إغلاقات خاصة حاليًا',
      );
    }

    return Column(
      children: closures.map((closure) {
        return _ClosureCard(
          closure: closure,
          onEdit: () => onEdit(closure),
          onDelete: () => onDelete(closure),
        );
      }).toList(),
    );
  }
}

class _TimeBlocksList extends StatelessWidget {
  const _TimeBlocksList({
    required this.timeBlocks,
    required this.formatTime,
    required this.onEdit,
    required this.onDelete,
  });

  final List<_TimeBlock> timeBlocks;
  final String Function(String value) formatTime;
  final ValueChanged<_TimeBlock> onEdit;
  final ValueChanged<_TimeBlock> onDelete;

  @override
  Widget build(BuildContext context) {
    if (timeBlocks.isEmpty) {
      return const _EmptyState(
        text: 'لا توجد فترات عدم توفر مسجّلة بعد',
      );
    }

    return Column(
      children: timeBlocks.map((block) {
        return _TimeBlockCard(
          block: block,
          formatTime: formatTime,
          onEdit: () => onEdit(block),
          onDelete: () => onDelete(block),
        );
      }).toList(),
    );
  }
}

class _ClosureCard extends StatelessWidget {
  const _ClosureCard({
    required this.closure,
    required this.onEdit,
    required this.onDelete,
  });

  final _ClosureDay closure;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _RecordCardShell(
      icon: Icons.calendar_month_rounded,
      title: closure.dateLabel,
      subtitle: closure.reason,
      badge: 'إغلاق يوم كامل',
      badgeColor: const Color(0xFFEF4444),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _TimeBlockCard extends StatelessWidget {
  const _TimeBlockCard({
    required this.block,
    required this.formatTime,
    required this.onEdit,
    required this.onDelete,
  });

  final _TimeBlock block;
  final String Function(String value) formatTime;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isRecurring = block.type == 'recurring';

    return _RecordCardShell(
      icon: Icons.access_time_rounded,
      title: '${formatTime(block.startTime)} — ${formatTime(block.endTime)}',
      subtitle: block.reason,
      secondSubtitle:
          isRecurring ? 'يتكرر في أيام الدوام' : 'بتاريخ ${block.dateLabel}',
      badge: isRecurring ? 'متكرر' : 'ليوم محدد',
      badgeColor: isRecurring ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

class _RecordCardShell extends StatelessWidget {
  const _RecordCardShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onEdit,
    required this.onDelete,
    this.secondSubtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? secondSubtitle;
  final String badge;
  final Color badgeColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEDF1F3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: badgeColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF7F1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFDCEFE2),
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF5C4030),
              size: 21,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          if (secondSubtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              secondSubtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PrimaryButton(
                  label: 'تعديل',
                  icon: Icons.edit_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PrimaryButton(
                  label: 'حذف',
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFEF4444),
                  onTap: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.selectedMode,
    required this.onChanged,
  });

  final String selectedMode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeChip(
            label: 'يتكرر في أيام الدوام',
            isActive: selectedMode == 'recurring',
            onTap: () => onChanged('recurring'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ModeChip(
            label: 'ليوم محدد',
            isActive: selectedMode == 'specific',
            onTap: () => onChanged('specific'),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFFFF3C4) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  isActive ? const Color(0xFFC4A15F) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: isActive ? const Color(0xFF92400E) : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 9),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4ECE7),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF5C4030),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextInputBox extends StatelessWidget {
  const _TextInputBox({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF5C4030),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4ECE7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4ECE7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFC47A3D),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF475569),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.6,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 17,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
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

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF374151),
                size: 17,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF374151),
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

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFC47A3D).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFC47A3D).withValues(alpha: 0.18),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFC47A3D),
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Material(
          color: const Color(0xFFF5F5F4),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onClose,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDBE3EA),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _ClosureDay {
  const _ClosureDay({
    required this.id,
    required this.dateLabel,
    required this.reason,
  });

  final String id;
  final String dateLabel;
  final String reason;

  _ClosureDay copyWith({
    String? reason,
  }) {
    return _ClosureDay(
      id: id,
      dateLabel: dateLabel,
      reason: reason ?? this.reason,
    );
  }
}

class _TimeBlock {
  const _TimeBlock({
    required this.id,
    required this.type,
    required this.dateLabel,
    required this.startTime,
    required this.endTime,
    required this.reason,
  });

  final String id;
  final String type;
  final String? dateLabel;
  final String startTime;
  final String endTime;
  final String reason;

  _TimeBlock copyWith({
    String? type,
    String? dateLabel,
    String? startTime,
    String? endTime,
    String? reason,
  }) {
    return _TimeBlock(
      id: id,
      type: type ?? this.type,
      dateLabel: dateLabel,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reason: reason ?? this.reason,
    );
  }
}