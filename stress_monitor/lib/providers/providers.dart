import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/api_service.dart';
import '../data/services/mock_data_service.dart';
import '../data/models/student.dart';
import '../data/models/risk_score.dart';
import '../data/models/attendance_record.dart';
import '../data/models/assignment.dart';
import '../data/models/workload.dart';
import '../data/models/recommendation.dart';

/// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(useMockData: true);
});

/// Current user role provider
enum UserRole { student, admin }

final currentUserRoleProvider = StateProvider<UserRole?>((ref) => null);

/// Current student ID provider (for student view)
final currentStudentIdProvider = StateProvider<String>((ref) => 'STU001');

/// All students provider
final allStudentsProvider = FutureProvider<List<Student>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getAllStudents();
});

/// At-risk students provider
final atRiskStudentsProvider = FutureProvider<List<Student>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getAtRiskStudents();
});

/// Current student provider
final currentStudentProvider = FutureProvider<Student?>((ref) async {
  final studentId = ref.watch(currentStudentIdProvider);
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getStudentById(studentId);
});

/// Risk score provider for current student
final currentRiskScoreProvider = FutureProvider<RiskScore>((ref) async {
  final studentId = ref.watch(currentStudentIdProvider);
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getRiskScore(studentId);
});

/// Student risk score provider (for admin view)
final studentRiskScoreProvider =
    FutureProvider.family<RiskScore, String>((ref, studentId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getRiskScore(studentId);
});

/// Attendance summary provider
final attendanceSummaryProvider = FutureProvider<AttendanceSummary>((ref) async {
  final studentId = ref.watch(currentStudentIdProvider);
  // Simulate async fetch
  await Future.delayed(const Duration(milliseconds: 300));
  return MockDataService.generateAttendanceSummary(studentId);
});

/// Assignment summary provider
final assignmentSummaryProvider = FutureProvider<AssignmentSummary>((ref) async {
  final studentId = ref.watch(currentStudentIdProvider);
  await Future.delayed(const Duration(milliseconds: 300));
  return MockDataService.generateAssignmentSummary(studentId);
});

/// Workload summary provider
final workloadSummaryProvider = FutureProvider<WorkloadSummary>((ref) async {
  final studentId = ref.watch(currentStudentIdProvider);
  await Future.delayed(const Duration(milliseconds: 300));
  return MockDataService.generateWorkloadSummary(studentId);
});

/// Risk score history provider
final riskScoreHistoryProvider = FutureProvider<List<RiskScoreHistory>>((ref) async {
  final studentId = ref.watch(currentStudentIdProvider);
  final riskScore = await ref.watch(currentRiskScoreProvider.future);
  await Future.delayed(const Duration(milliseconds: 200));
  return MockDataService.generateRiskScoreHistory(studentId, riskScore.score);
});

/// Recommendations provider
final recommendationsProvider = FutureProvider<List<Recommendation>>((ref) async {
  final riskScore = await ref.watch(currentRiskScoreProvider.future);
  await Future.delayed(const Duration(milliseconds: 200));
  return MockDataService.generateRecommendations(riskScore);
});

/// Student detail provider (for admin view)
final studentDetailProvider =
    FutureProvider.family<Student?, String>((ref, studentId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getStudentById(studentId);
});

/// Dashboard statistics provider
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final students = await ref.watch(allStudentsProvider.future);
  
  final lowRisk = students.where((s) => s.riskLevel == RiskLevel.low).length;
  final moderateRisk = students.where((s) => s.riskLevel == RiskLevel.moderate).length;
  final highRisk = students.where((s) => s.riskLevel == RiskLevel.high).length;
  
  return DashboardStats(
    totalStudents: students.length,
    lowRiskCount: lowRisk,
    moderateRiskCount: moderateRisk,
    highRiskCount: highRisk,
  );
});

/// Dashboard statistics model
class DashboardStats {
  final int totalStudents;
  final int lowRiskCount;
  final int moderateRiskCount;
  final int highRiskCount;

  const DashboardStats({
    required this.totalStudents,
    required this.lowRiskCount,
    required this.moderateRiskCount,
    required this.highRiskCount,
  });

  int get atRiskCount => moderateRiskCount + highRiskCount;
}
