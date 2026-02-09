import 'package:dio/dio.dart';
import '../models/student.dart';
import '../models/risk_score.dart';
import '../../core/constants/api_endpoints.dart';
import 'mock_data_service.dart';

/// API Service for backend communication
/// Currently uses mock data, but ready for real API integration
class ApiService {
  final Dio _dio;
  final bool useMockData;

  ApiService({
    Dio? dio,
    this.useMockData = true, // Set to false when backend is ready
  }) : _dio = dio ?? Dio(BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
          },
        ));

  /// Get all students
  Future<List<Student>> getAllStudents() async {
    if (useMockData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      return MockDataService.generateStudents();
    }

    try {
      final response = await _dio.get(ApiEndpoints.allStudents);
      final List<dynamic> data = response.data;
      return data.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  /// Get at-risk students
  Future<List<Student>> getAtRiskStudents() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockDataService.getAtRiskStudents();
    }

    try {
      final response = await _dio.get(ApiEndpoints.atRiskStudents);
      final List<dynamic> data = response.data;
      return data.map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch at-risk students: $e');
    }
  }

  /// Get risk score for a student
  Future<RiskScore> getRiskScore(String studentId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final student = MockDataService.getStudentById(studentId);
      if (student == null) {
        throw Exception('Student not found');
      }
      return MockDataService.generateRiskScore(studentId, student.riskScore ?? 25);
    }

    try {
      final response = await _dio.get(ApiEndpoints.risk(studentId));
      return RiskScore.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch risk score: $e');
    }
  }

  /// Get student by ID
  Future<Student?> getStudentById(String studentId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockDataService.getStudentById(studentId);
    }

    try {
      final response = await _dio.get('${ApiEndpoints.allStudents}/$studentId');
      return Student.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Ingest attendance data
  Future<void> ingestAttendance(Map<String, dynamic> data) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    try {
      await _dio.post(ApiEndpoints.ingestAttendance, data: data);
    } catch (e) {
      throw Exception('Failed to ingest attendance: $e');
    }
  }

  /// Ingest assignment data
  Future<void> ingestAssignment(Map<String, dynamic> data) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    try {
      await _dio.post(ApiEndpoints.ingestAssignment, data: data);
    } catch (e) {
      throw Exception('Failed to ingest assignment: $e');
    }
  }
}
