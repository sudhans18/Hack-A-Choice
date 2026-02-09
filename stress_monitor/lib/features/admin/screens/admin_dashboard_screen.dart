import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models/student.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final atRiskAsync = ref.watch(atRiskStudentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(atRiskStudentsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(atRiskStudentsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Welcome, Admin! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 4),
              Text(
                'Monitor student wellness at a glance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 24),

              // Stats Cards
              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people_rounded,
                            iconColor: AppColors.chartBlue,
                            value: stats.totalStudents.toString(),
                            label: 'Total Students',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.warning_amber_rounded,
                            iconColor: AppColors.riskHigh,
                            value: stats.atRiskCount.toString(),
                            label: 'At Risk',
                            onTap: () => context.go('/admin/at-risk'),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle_rounded,
                            iconColor: AppColors.riskLow,
                            value: stats.lowRiskCount.toString(),
                            label: 'Low Risk',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.warning_rounded,
                            iconColor: AppColors.riskModerate,
                            value: stats.moderateRiskCount.toString(),
                            label: 'Moderate',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.error_rounded,
                            iconColor: AppColors.riskHigh,
                            value: stats.highRiskCount.toString(),
                            label: 'High Risk',
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const Text('Error loading stats'),
              ),
              const SizedBox(height: 24),

              // Risk Distribution Chart
              Text(
                'Risk Distribution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 12),

              statsAsync.when(
                data: (stats) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  value: stats.lowRiskCount.toDouble(),
                                  color: AppColors.riskLow,
                                  title: '',
                                  radius: 30,
                                ),
                                PieChartSectionData(
                                  value: stats.moderateRiskCount.toDouble(),
                                  color: AppColors.riskModerate,
                                  title: '',
                                  radius: 30,
                                ),
                                PieChartSectionData(
                                  value: stats.highRiskCount.toDouble(),
                                  color: AppColors.riskHigh,
                                  title: '',
                                  radius: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LegendItem(
                                color: AppColors.riskLow,
                                label: 'Low Risk',
                                value: stats.lowRiskCount,
                              ),
                              const SizedBox(height: 12),
                              _LegendItem(
                                color: AppColors.riskModerate,
                                label: 'Moderate Risk',
                                value: stats.moderateRiskCount,
                              ),
                              const SizedBox(height: 12),
                              _LegendItem(
                                color: AppColors.riskHigh,
                                label: 'High Risk',
                                value: stats.highRiskCount,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                loading: () => const Card(
                  child: SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (_, __) => const Card(
                  child: Text('Error loading chart'),
                ),
              ),
              const SizedBox(height: 24),

              // At-Risk Students Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'At-Risk Students',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/admin/at-risk'),
                    child: const Text('View All'),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              const SizedBox(height: 8),

              atRiskAsync.when(
                data: (students) {
                  final preview = students.take(5).toList();
                  return Column(
                    children: preview.asMap().entries.map((entry) {
                      final student = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _StudentPreviewCard(
                          student: student,
                          onTap: () => context.go('/admin/student/${student.id}'),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 700 + entry.key * 80),
                              duration: 400.ms,
                            ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const Text('Error loading students'),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _StudentPreviewCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;

  const _StudentPreviewCard({
    required this.student,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = student.riskLevel != null
        ? AppColors.getRiskColor(student.riskScore ?? 0)
        : AppColors.textSecondaryLight;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: riskColor.withOpacity(0.1),
                child: Text(
                  student.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      student.department,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${student.riskScore ?? 0}',
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
