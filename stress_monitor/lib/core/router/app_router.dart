import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/student/screens/student_home_screen.dart';
import '../../features/student/screens/stress_score_screen.dart';
import '../../features/student/screens/workload_screen.dart';
import '../../features/student/screens/attendance_screen.dart';
import '../../features/student/screens/recommendations_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/at_risk_students_screen.dart';
import '../../features/admin/screens/student_detail_screen.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      // Login / Role Selection
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Student Routes
      ShellRoute(
        builder: (context, state, child) => StudentShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/student',
            name: 'studentHome',
            builder: (context, state) => const StudentHomeScreen(),
            routes: [
              GoRoute(
                path: 'stress',
                name: 'stressScore',
                builder: (context, state) => const StressScoreScreen(),
              ),
              GoRoute(
                path: 'workload',
                name: 'workload',
                builder: (context, state) => const WorkloadScreen(),
              ),
              GoRoute(
                path: 'attendance',
                name: 'attendance',
                builder: (context, state) => const AttendanceScreen(),
              ),
              GoRoute(
                path: 'recommendations',
                name: 'recommendations',
                builder: (context, state) => const RecommendationsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'at-risk',
            name: 'atRiskStudents',
            builder: (context, state) => const AtRiskStudentsScreen(),
          ),
          GoRoute(
            path: 'student/:id',
            name: 'studentDetail',
            builder: (context, state) {
              final studentId = state.pathParameters['id']!;
              return StudentDetailScreen(studentId: studentId);
            },
          ),
        ],
      ),
    ],
  );
});

/// Shell screen for student with bottom navigation
class StudentShellScreen extends StatelessWidget {
  final Widget child;

  const StudentShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
