/// Attendance record model
class AttendanceRecord {
  final String id;
  final String studentId;
  final DateTime date;
  final bool present;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.present,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      date: DateTime.parse(json['date'] as String),
      present: json['present'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'present': present,
    };
  }
}

/// Attendance summary for display
class AttendanceSummary {
  final double percentage;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final List<AttendanceRecord> recentRecords;

  const AttendanceSummary({
    required this.percentage,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.recentRecords,
  });

  bool get isLow => percentage < 75;
}
