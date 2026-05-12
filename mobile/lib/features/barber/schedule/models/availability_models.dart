class ClosureDay {
  const ClosureDay({
    required this.id,
    required this.dateLabel,
    required this.reason,
  });

  final String id;
  final String dateLabel;
  final String reason;

  ClosureDay copyWith({String? reason}) {
    return ClosureDay(
      id: id,
      dateLabel: dateLabel,
      reason: reason ?? this.reason,
    );
  }
}

class TimeBlock {
  const TimeBlock({
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

  TimeBlock copyWith({
    String? type,
    String? dateLabel,
    String? startTime,
    String? endTime,
    String? reason,
  }) {
    return TimeBlock(
      id: id,
      type: type ?? this.type,
      dateLabel: dateLabel,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reason: reason ?? this.reason,
    );
  }
}
