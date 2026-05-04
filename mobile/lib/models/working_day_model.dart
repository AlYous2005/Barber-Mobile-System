class WorkingDay {
  const WorkingDay({
    required this.dayKey,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  final String dayKey;
  final String dayName;
  final String startTime;
  final String endTime;
  final bool isActive;

  WorkingDay copyWith({
    String? startTime,
    String? endTime,
    bool? isActive,
  }) {
    return WorkingDay(
      dayKey: dayKey,
      dayName: dayName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
    );
  }
}