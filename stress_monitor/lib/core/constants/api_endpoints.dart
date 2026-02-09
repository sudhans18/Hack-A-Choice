/// API endpoint configuration
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Change this when backend is ready
  static const String baseUrl = 'http://localhost:8000';

  // Endpoints
  static const String ingestAttendance = '/ingest/attendance';
  static const String ingestAssignment = '/ingest/assignment';
  static String risk(String studentId) => '/risk/$studentId';
  static const String atRiskStudents = '/students/at-risk';
  static const String allStudents = '/students';
}
