import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/student'),
        ),
        title: const Text('Attendance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: attendanceAsync.when(
          data: (attendance) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main attendance circle
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 90,
                          lineWidth: 14,
                          percent: (attendance.percentage / 100).clamp(0, 1),
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${attendance.percentage.toStringAsFixed(0)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Attendance',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                            ],
                          ),
                          progressColor: attendance.isLow
                              ? AppColors.riskHigh
                              : AppColors.riskLow,
                          backgroundColor: (attendance.isLow
                                  ? AppColors.riskHigh
                                  : AppColors.riskLow)
                              .withOpacity(0.2),
                          circularStrokeCap: CircularStrokeCap.round,
                          animation: true,
                          animationDuration: 1000,
                        ),
                        const SizedBox(height: 20),
                        if (attendance.isLow)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.riskHigh.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.riskHigh,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Below 75% threshold',
                                  style: TextStyle(
                                    color: AppColors.riskHigh,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
              ),
              const SizedBox(height: 24),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.riskLow,
                      value: attendance.presentDays.toString(),
                      label: 'Present',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.cancel_rounded,
                      iconColor: AppColors.riskHigh,
                      value: attendance.absentDays.toString(),
                      label: 'Absent',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_month_rounded,
                      iconColor: AppColors.chartBlue,
                      value: attendance.totalDays.toString(),
                      label: 'Total',
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 24),

              // Recent attendance
              Text(
                'Recent Attendance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: attendance.recentRecords.asMap().entries.map((entry) {
                      final record = entry.value;
                      final isFirst = entry.key == 0;
                      final isLast = entry.key == attendance.recentRecords.length - 1;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: record.present
                                        ? AppColors.riskLow.withOpacity(0.1)
                                        : AppColors.riskHigh.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    record.present
                                        ? Icons.check_rounded
                                        : Icons.close_rounded,
                                    color: record.present
                                        ? AppColors.riskLow
                                        : AppColors.riskHigh,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE').format(record.date),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(record.date),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondaryLight,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: record.present
                                        ? AppColors.riskLow.withOpacity(0.1)
                                        : AppColors.riskHigh.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    record.present ? 'Present' : 'Absent',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: record.present
                                          ? AppColors.riskLow
                                          : AppColors.riskHigh,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              const SizedBox(height: 80),
            ],
          ),
          loading: () => const SizedBox(
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const Center(child: Text('Error loading attendance')),
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

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
