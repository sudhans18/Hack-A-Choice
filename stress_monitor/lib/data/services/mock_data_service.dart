import 'dart:math';
import '../models/student.dart';
import '../models/attendance_record.dart';
import '../models/assignment.dart';
import '../models/workload.dart';
import '../models/risk_score.dart';
import '../models/recommendation.dart';

/// Mock data service for demo purposes
/// This can be easily swapped with real API calls when backend is ready
class MockDataService {
  static final _random = Random(42); // Fixed seed for consistent demo data

  // Sample student names
  static const _names = [
    'Alex Johnson',
    'Sarah Williams',
    'Michael Chen',
    'Emily Davis',
    'James Wilson',
    'Olivia Brown',
    'Daniel Martinez',
    'Sophia Garcia',
    'David Rodriguez',
    'Isabella Lopez',
    'William Anderson',
    'Emma Thomas',
    'Christopher Lee',
    'Ava Jackson',
    'Matthew White',
    'Mia Harris',
    'Anthony Clark',
    'Charlotte Lewis',
    'Joshua Walker',
    'Amelia Hall',
  ];

  static const _departments = [
    'Computer Science',
    'Electronics',
    'Mechanical',
    'Civil',
    'Biotechnology',
  ];

  /// Generate sample students
  static List<Student> generateStudents({int count = 20}) {
    return List.generate(count, (index) {
      final riskScore = _generateRiskScore(index);
      return Student(
        id: 'STU${(index + 1).toString().padLeft(3, '0')}',
        name: _names[index % _names.length],
        department: _departments[index % _departments.length],
        email: '${_names[index % _names.length].toLowerCase().replaceAll(' ', '.')}@university.edu',
        riskScore: riskScore,
        riskLevel: RiskLevel.fromScore(riskScore),
      );
    });
  }

  /// Generate a realistic risk score distribution
  static int _generateRiskScore(int index) {
    // Create a mix of risk levels for demo
    if (index < 5) {
      return 15 + _random.nextInt(15); // Low risk (15-30)
    } else if (index < 12) {
      return 35 + _random.nextInt(25); // Moderate risk (35-60)
    } else {
      return 65 + _random.nextInt(30); // High risk (65-95)
    }
  }

  /// Generate attendance records for a student
  static List<AttendanceRecord> generateAttendance(
    String studentId, {
    int days = 30,
    double attendanceRate = 0.75,
  }) {
    final records = <AttendanceRecord>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      // Skip weekends
      final date = now.subtract(Duration(days: i));
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }

      records.add(AttendanceRecord(
        id: 'ATT_${studentId}_$i',
        studentId: studentId,
        date: date,
        present: _random.nextDouble() < attendanceRate,
      ));
    }

    return records;
  }

  /// Generate attendance summary
  static AttendanceSummary generateAttendanceSummary(String studentId) {
    final records = generateAttendance(studentId);
    final presentCount = records.where((r) => r.present).length;
    final totalCount = records.length;
    final percentage = totalCount > 0 ? (presentCount / totalCount) * 100 : 0.0;

    return AttendanceSummary(
      percentage: percentage,
      totalDays: totalCount,
      presentDays: presentCount,
      absentDays: totalCount - presentCount,
      recentRecords: records.take(7).toList(),
    );
  }

  /// Generate assignments for a student
  static List<Assignment> generateAssignments(
    String studentId, {
    int count = 10,
  }) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      final dueDate = now.subtract(Duration(days: (index - 3) * 5));
      DateTime? submittedDate;

      // Vary submission patterns
      if (index < 3) {
        // Upcoming - not submitted yet
        submittedDate = null;
      } else if (_random.nextDouble() < 0.7) {
        // Most are submitted
        final daysOffset = _random.nextInt(4) - 1; // -1 to 2 days
        submittedDate = dueDate.add(Duration(days: daysOffset));
      }

      return Assignment(
        id: 'ASN_${studentId}_$index',
        studentId: studentId,
        title: 'Assignment ${count - index}: ${_assignmentTitles[index % _assignmentTitles.length]}',
        dueDate: dueDate,
        submittedDate: submittedDate,
      );
    });
  }

  static const _assignmentTitles = [
    'Data Structures Lab',
    'Algorithm Analysis',
    'Database Design',
    'Network Security',
    'Machine Learning Project',
    'Web Development',
    'Mobile App Design',
    'System Analysis',
    'Cloud Computing',
    'AI Research Paper',
  ];

  /// Generate assignment summary
  static AssignmentSummary generateAssignmentSummary(String studentId) {
    final assignments = generateAssignments(studentId);
    final submitted = assignments.where((a) => a.isSubmitted).length;
    final late = assignments.where((a) => a.isLate).length;
    final missing = assignments.where((a) => a.isMissing).length;
    final pending = assignments.where((a) => !a.isSubmitted && !a.isMissing).length;

    return AssignmentSummary(
      totalAssignments: assignments.length,
      submitted: submitted,
      pending: pending,
      late: late,
      missing: missing,
      recentAssignments: assignments.take(5).toList(),
    );
  }

  /// Generate workload data
  static List<Workload> generateWorkload(String studentId, {int weeks = 8}) {
    final now = DateTime.now();
    return List.generate(weeks, (index) {
      // Create a spike in recent weeks for demo
      int tasks;
      if (index == 0) {
        tasks = 8 + _random.nextInt(4); // Current week: 8-12 tasks
      } else if (index == 1) {
        tasks = 5 + _random.nextInt(3); // Last week: 5-8 tasks
      } else {
        tasks = 3 + _random.nextInt(4); // Older weeks: 3-7 tasks
      }

      return Workload(
        id: 'WL_${studentId}_$index',
        studentId: studentId,
        weekStart: now.subtract(Duration(days: index * 7)),
        tasksCount: tasks,
      );
    });
  }

  /// Generate workload summary
  static WorkloadSummary generateWorkloadSummary(String studentId) {
    final workloadData = generateWorkload(studentId);
    return WorkloadSummary.fromWeeklyData(workloadData);
  }

  /// Generate risk score with triggered rules
  static RiskScore generateRiskScore(String studentId, int score) {
    final rules = <RuleTriggered>[];

    // Add rules based on score ranges
    if (score > 20) {
      rules.add(const RuleTriggered(
        ruleId: 'attendance_drop',
        ruleName: 'Attendance Drop',
        explanation: 'Attendance fell below 75% over the last 2 weeks',
        pointsAdded: 20,
      ));
    }

    if (score > 40) {
      rules.add(const RuleTriggered(
        ruleId: 'late_submissions',
        ruleName: 'Late Submissions',
        explanation: '2 or more consecutive late submissions detected',
        pointsAdded: 25,
      ));
    }

    if (score > 55) {
      rules.add(const RuleTriggered(
        ruleId: 'workload_spike',
        ruleName: 'Workload Spike',
        explanation: 'Workload increased by more than 40% this week',
        pointsAdded: 15,
      ));
    }

    if (score > 70) {
      rules.add(const RuleTriggered(
        ruleId: 'missing_submission',
        ruleName: 'Missing Submission',
        explanation: 'One or more assignments past due without submission',
        pointsAdded: 25,
      ));
    }

    if (score > 85) {
      rules.add(const RuleTriggered(
        ruleId: 'behavior_change',
        ruleName: 'Sudden Behavior Change',
        explanation: 'Attendance dropped more than 20% compared to previous period',
        pointsAdded: 15,
      ));
    }

    return RiskScore(
      score: score,
      level: RiskLevel.fromScore(score),
      triggeredRules: rules,
      calculatedAt: DateTime.now(),
    );
  }

  /// Generate risk score history for trend chart
  static List<RiskScoreHistory> generateRiskScoreHistory(
    String studentId,
    int currentScore, {
    int weeks = 4,
  }) {
    final now = DateTime.now();
    return List.generate(weeks, (index) {
      // Show gradual increase to current score
      final weekScore = currentScore -
          ((weeks - index - 1) * (5 + _random.nextInt(5)));
      return RiskScoreHistory(
        date: now.subtract(Duration(days: index * 7)),
        score: weekScore.clamp(0, 100),
      );
    }).reversed.toList();
  }

  /// Generate recommendations based on risk score
  static List<Recommendation> generateRecommendations(RiskScore riskScore) {
    final ruleIds = riskScore.triggeredRules.map((r) => r.ruleId).toList();
    return RecommendationEngine.getRecommendations(ruleIds);
  }

  /// Get at-risk students (moderate and high risk)
  static List<Student> getAtRiskStudents() {
    return generateStudents()
        .where((s) => s.riskScore != null && s.riskScore! > 30)
        .toList()
      ..sort((a, b) => (b.riskScore ?? 0).compareTo(a.riskScore ?? 0));
  }

  /// Get a single student by ID
  static Student? getStudentById(String id) {
    final students = generateStudents();
    try {
      return students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
