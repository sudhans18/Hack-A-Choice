import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models/student.dart';
import '../widgets/stress_gauge_widget.dart';
import '../widgets/quick_stat_card.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskScoreAsync = ref.watch(currentRiskScoreProvider);
    final attendanceAsync = ref.watch(attendanceSummaryProvider);
    final assignmentAsync = ref.watch(assignmentSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentRiskScoreProvider);
          ref.invalidate(attendanceSummaryProvider);
          ref.invalidate(assignmentSummaryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Hello, Student! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 4),
              Text(
                'Here\'s your wellness overview',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 24),

              // Stress Score Card
              riskScoreAsync.when(
                data: (riskScore) => GestureDetector(
                  onTap: () => context.go('/student/stress'),
                  child: _StressScoreCard(
                    score: riskScore.score,
                    level: riskScore.level,
                    triggeredRulesCount: riskScore.triggeredRules.length,
                  ),
                ),
                loading: () => const _StressScoreCardLoading(),
                error: (_, __) => const _StressScoreCardError(),
              ),
              const SizedBox(height: 20),

              // Quick Stats
              Text(
                'Quick Stats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: attendanceAsync.when(
                      data: (attendance) => QuickStatCard(
                        icon: Icons.calendar_today_rounded,
                        iconColor: attendance.isLow
                            ? AppColors.riskHigh
                            : AppColors.riskLow,
                        title: 'Attendance',
                        value: '${attendance.percentage.toStringAsFixed(0)}%',
                        onTap: () => context.go('/student/attendance'),
                      ),
                      loading: () => const QuickStatCard(
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.chartBlue,
                        title: 'Attendance',
                        value: '...',
                      ),
                      error: (_, __) => const QuickStatCard(
                        icon: Icons.calendar_today_rounded,
                        iconColor: AppColors.riskHigh,
                        title: 'Attendance',
                        value: 'Error',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: assignmentAsync.when(
                      data: (assignment) => QuickStatCard(
                        icon: Icons.assignment_rounded,
                        iconColor: assignment.missing > 0
                            ? AppColors.riskHigh
                            : AppColors.riskLow,
                        title: 'Assignments',
                        value: '${assignment.submitted}/${assignment.totalAssignments}',
                        subtitle: assignment.missing > 0
                            ? '${assignment.missing} missing'
                            : null,
                        onTap: () => context.go('/student/workload'),
                      ),
                      loading: () => const QuickStatCard(
                        icon: Icons.assignment_rounded,
                        iconColor: AppColors.chartBlue,
                        title: 'Assignments',
                        value: '...',
                      ),
                      error: (_, __) => const QuickStatCard(
                        icon: Icons.assignment_rounded,
                        iconColor: AppColors.riskHigh,
                        title: 'Assignments',
                        value: 'Error',
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 24),

              // Navigation Cards
              Text(
                'Explore',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              const SizedBox(height: 12),

              _NavigationCard(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.chartBlue,
                title: 'Workload Trends',
                subtitle: 'View your weekly task distribution',
                onTap: () => context.go('/student/workload'),
              ).animate().fadeIn(delay: 550.ms, duration: 400.ms),
              const SizedBox(height: 12),

              _NavigationCard(
                icon: Icons.lightbulb_outline_rounded,
                iconColor: AppColors.chartOrange,
                title: 'Recommendations',
                subtitle: 'Personalized suggestions for you',
                onTap: () => context.go('/student/recommendations'),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.go('/student/stress');
              break;
            case 2:
              context.go('/student/recommendations');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_rounded),
            label: 'Stress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_rounded),
            label: 'Tips',
          ),
        ],
      ),
    );
  }
}

class _StressScoreCard extends StatelessWidget {
  final int score;
  final RiskLevel level;
  final int triggeredRulesCount;

  const _StressScoreCard({
    required this.score,
    required this.level,
    required this.triggeredRulesCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getRiskColor(score);

    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            StressGaugeWidget(
              score: score,
              size: 120,
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
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${level.displayName} Risk',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    level.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (triggeredRulesCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$triggeredRulesCount factor${triggeredRulesCount > 1 ? 's' : ''} detected',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _StressScoreCardLoading extends StatelessWidget {
  const _StressScoreCardLoading();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _StressScoreCardError extends StatelessWidget {
  const _StressScoreCardError();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text('Failed to load stress score'),
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _NavigationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
