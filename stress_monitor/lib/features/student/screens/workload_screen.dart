import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';

class WorkloadScreen extends ConsumerWidget {
  const WorkloadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workloadAsync = ref.watch(workloadSummaryProvider);
    final assignmentAsync = ref.watch(assignmentSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/student'),
        ),
        title: const Text('Workload'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Week Summary
            workloadAsync.when(
              data: (workload) => _CurrentWeekCard(
                currentTasks: workload.currentWeekTasks,
                previousTasks: workload.previousWeekTasks,
                changePercentage: workload.changePercentage,
                hasSpike: workload.hasSpike,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              loading: () => const Card(
                child: SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const Card(
                child: SizedBox(
                  height: 120,
                  child: Center(child: Text('Error loading workload')),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Chart
            Text(
              'Weekly Tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 16),

            workloadAsync.when(
              data: (workload) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 15,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.toInt()} tasks',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'];
                                final index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const SizedBox.shrink();
                                }
                                final isRecent = index >= workload.weeklyData.length - 2;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    labels[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isRecent ? FontWeight.bold : FontWeight.normal,
                                      color: isRecent ? AppColors.primary : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              interval: 5,
                              reservedSize: 25,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: workload.weeklyData.reversed
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                          final isSpike = entry.key == workload.weeklyData.length - 1 &&
                              workload.hasSpike;
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.tasksCount.toDouble(),
                                color: isSpike ? AppColors.riskHigh : AppColors.chartBlue,
                                width: 24,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              loading: () => const Card(
                child: SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const Card(
                child: SizedBox(
                  height: 220,
                  child: Center(child: Text('Error loading chart')),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Upcoming Assignments
            Text(
              'Recent Assignments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            const SizedBox(height: 12),

            assignmentAsync.when(
              data: (summary) => Column(
                children: summary.recentAssignments.asMap().entries.map((entry) {
                  final assignment = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AssignmentCard(
                      title: assignment.title,
                      dueDate: assignment.dueDate,
                      isSubmitted: assignment.isSubmitted,
                      isLate: assignment.isLate,
                      isMissing: assignment.isMissing,
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: 500 + entry.key * 100),
                          duration: 400.ms,
                        ),
                  );
                }).toList(),
              ),
              loading: () => const Card(
                child: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const Card(
                child: Text('Error loading assignments'),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _CurrentWeekCard extends StatelessWidget {
  final int currentTasks;
  final int previousTasks;
  final double changePercentage;
  final bool hasSpike;

  const _CurrentWeekCard({
    required this.currentTasks,
    required this.previousTasks,
    required this.changePercentage,
    required this.hasSpike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: hasSpike
                    ? AppColors.riskHigh.withOpacity(0.1)
                    : AppColors.chartBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                hasSpike ? Icons.trending_up_rounded : Icons.assignment_rounded,
                color: hasSpike ? AppColors.riskHigh : AppColors.chartBlue,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  Row(
                    children: [
                      Text(
                        '$currentTasks tasks',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      if (changePercentage != 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: changePercentage > 0
                                ? AppColors.riskHigh.withOpacity(0.1)
                                : AppColors.riskLow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                changePercentage > 0
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 14,
                                color: changePercentage > 0
                                    ? AppColors.riskHigh
                                    : AppColors.riskLow,
                              ),
                              Text(
                                '${changePercentage.abs().toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: changePercentage > 0
                                      ? AppColors.riskHigh
                                      : AppColors.riskLow,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (hasSpike)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '⚠️ Workload spike detected',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.riskHigh,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final String title;
  final DateTime dueDate;
  final bool isSubmitted;
  final bool isLate;
  final bool isMissing;

  const _AssignmentCard({
    required this.title,
    required this.dueDate,
    required this.isSubmitted,
    required this.isLate,
    required this.isMissing,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isMissing) {
      statusColor = AppColors.riskHigh;
      statusText = 'Missing';
      statusIcon = Icons.error_outline_rounded;
    } else if (isLate) {
      statusColor = AppColors.riskModerate;
      statusText = 'Late';
      statusIcon = Icons.warning_amber_rounded;
    } else if (isSubmitted) {
      statusColor = AppColors.riskLow;
      statusText = 'Submitted';
      statusIcon = Icons.check_circle_outline_rounded;
    } else {
      statusColor = AppColors.chartBlue;
      statusText = 'Pending';
      statusIcon = Icons.schedule_rounded;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Due: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
