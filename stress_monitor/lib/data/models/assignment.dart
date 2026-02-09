/// Assignment model
class Assignment {
  final String id;
  final String studentId;
  final String title;
  final DateTime dueDate;
  final DateTime? submittedDate;

  const Assignment({
    required this.id,
    required this.studentId,
    required this.title,
    required this.dueDate,
    this.submittedDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      submittedDate: json['submittedDate'] != null
          ? DateTime.parse(json['submittedDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'submittedDate': submittedDate?.toIso8601String(),
    };
  }

  /// Check if assignment is submitted
  bool get isSubmitted => submittedDate != null;

  /// Check if assignment was submitted late
  bool get isLate =>
      submittedDate != null && submittedDate!.isAfter(dueDate);

  /// Check if assignment is missing (past due and not submitted)
  bool get isMissing =>
      submittedDate == null && DateTime.now().isAfter(dueDate);

  /// Days late (negative if early or on time)
  int get daysLateOrEarly {
    if (submittedDate == null) return 0;
    return submittedDate!.difference(dueDate).inDays;
  }
}

/// Assignment summary for display
class AssignmentSummary {
  final int totalAssignments;
  final int submitted;
  final int pending;
  final int late;
  final int missing;
  final List<Assignment> recentAssignments;

  const AssignmentSummary({
    required this.totalAssignments,
    required this.submitted,
    required this.pending,
    required this.late,
    required this.missing,
    required this.recentAssignments,
  });
}
