import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models/student.dart';
import '../../../data/services/mock_data_service.dart';
import '../../../data/services/email_service.dart';
import '../../student/widgets/stress_gauge_widget.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailProvider(studentId));
    final riskScoreAsync = ref.watch(studentRiskScoreProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/admin'),
        ),
        title: const Text('Student Details'),
      ),
      body: studentAsync.when(
        data: (student) {
          if (student == null) {
            return const Center(child: Text('Student not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            student.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.badge_rounded,
                                    size: 16,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    student.id,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondaryLight,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.school_rounded,
                                    size: 16,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    student.department,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondaryLight,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),

                // Risk Score Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: riskScoreAsync.when(
                      data: (riskScore) => Column(
                        children: [
                          Row(
                            children: [
                              StressGaugeWidget(
                                score: riskScore.score,
                                size: 140,
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.getRiskColor(riskScore.score)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${riskScore.level.displayName} Risk',
                                        style: TextStyle(
                                          color: AppColors.getRiskColor(riskScore.score),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Based on ${riskScore.triggeredRules.length} contributing factor${riskScore.triggeredRules.length != 1 ? 's' : ''}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textSecondaryLight,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      loading: () => const SizedBox(
                        height: 150,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const Text('Error loading risk score'),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 20),

                // Rule Explanation Panel
                Text(
                  'Rule Explanation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 12),

                riskScoreAsync.when(
                  data: (riskScore) {
                    if (riskScore.triggeredRules.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.riskLow.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.riskLow,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text('No risk factors triggered. Student is on track!'),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: riskScore.triggeredRules.asMap().entries.map((entry) {
                            final rule = entry.value;
                            final isLast = entry.key == riskScore.triggeredRules.length - 1;

                            return Column(
                              children: [
                                _RuleExplanationTile(
                                  ruleName: rule.ruleName,
                                  explanation: rule.explanation,
                                  points: rule.pointsAdded,
                                ),
                                if (!isLast)
                                  const Divider(height: 24),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
                  },
                  loading: () => const Card(
                    child: SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (_, __) => const Card(
                    child: Text('Error loading rules'),
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Stats
                Text(
                  'Quick Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                const SizedBox(height: 12),

                FutureBuilder(
                  future: Future.wait([
                    Future.value(MockDataService.generateAttendanceSummary(studentId)),
                    Future.value(MockDataService.generateAssignmentSummary(studentId)),
                    Future.value(MockDataService.generateWorkloadSummary(studentId)),
                  ]),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Card(
                        child: SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    final attendance = snapshot.data![0] as dynamic;
                    final assignments = snapshot.data![1] as dynamic;
                    final workload = snapshot.data![2] as dynamic;

                    return Row(
                      children: [
                        Expanded(
                          child: _QuickStatCard(
                            icon: Icons.calendar_today_rounded,
                            iconColor: attendance.isLow
                                ? AppColors.riskHigh
                                : AppColors.riskLow,
                            value: '${attendance.percentage.toStringAsFixed(0)}%',
                            label: 'Attendance',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickStatCard(
                            icon: Icons.assignment_rounded,
                            iconColor: assignments.missing > 0
                                ? AppColors.riskHigh
                                : AppColors.riskLow,
                            value: '${assignments.submitted}/${assignments.totalAssignments}',
                            label: 'Submitted',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickStatCard(
                            icon: Icons.trending_up_rounded,
                            iconColor: workload.hasSpike
                                ? AppColors.riskHigh
                                : AppColors.chartBlue,
                            value: '${workload.currentWeekTasks}',
                            label: 'Tasks/Week',
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                const SizedBox(height: 12),

                riskScoreAsync.when(
                  data: (riskScore) => Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final success = await EmailService.sendStudentAlert(
                              studentName: student.name,
                              studentId: student.id,
                              riskScore: riskScore.score,
                              riskLevel: riskScore.level.displayName,
                              triggeredRules: riskScore.triggeredRules
                                  .map((r) => r.ruleName)
                                  .toList(),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Opening email to ${EmailService.getStudentEmail(student.name) ?? "counselor"}...'
                                        : 'Could not open email client',
                                  ),
                                  backgroundColor:
                                      success ? AppColors.riskLow : AppColors.riskHigh,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.email_rounded),
                          label: Text(
                            EmailService.hasStudentEmail(student.name)
                                ? 'Email Alert'
                                : 'Contact Counselor',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Note feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.note_add_rounded),
                          label: const Text('Add Note'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading student')),
      ),
    );
  }
}

class _RuleExplanationTile extends StatelessWidget {
  final String ruleName;
  final String explanation;
  final int points;

  const _RuleExplanationTile({
    required this.ruleName,
    required this.explanation,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.riskModerate.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.riskModerate,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ruleName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.riskHigh.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+$points pts',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.riskHigh,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                explanation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _QuickStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
