import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models/student.dart';
import '../widgets/stress_gauge_widget.dart';

class StressScoreScreen extends ConsumerWidget {
  const StressScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskScoreAsync = ref.watch(currentRiskScoreProvider);
    final historyAsync = ref.watch(riskScoreHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/student'),
        ),
        title: const Text('Stress Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Gauge
            Center(
              child: riskScoreAsync.when(
                data: (riskScore) => Column(
                  children: [
                    StressGaugeWidget(
                      score: riskScore.score,
                      size: 200,
                    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.getRiskColor(riskScore.score).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${riskScore.level.displayName} Risk Level',
                        style: TextStyle(
                          color: AppColors.getRiskColor(riskScore.score),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const Text('Error loading score'),
              ),
            ),
            const SizedBox(height: 32),

            // Trend Chart
            Text(
              'Stress Trend (Last 4 Weeks)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            const SizedBox(height: 16),

            historyAsync.when(
              data: (history) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= history.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  'W${index + 1}',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                              interval: 1,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              interval: 25,
                              reservedSize: 30,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: history
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      e.value.score.toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                radius: 5,
                                color: AppColors.getRiskColor(spot.y.toInt()),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.3),
                                  AppColors.primary.withOpacity(0.05),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              loading: () => const Card(
                child: SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const Card(
                child: SizedBox(
                  height: 200,
                  child: Center(child: Text('Error loading history')),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Triggered Rules
            Text(
              'Contributing Factors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            const SizedBox(height: 12),

            riskScoreAsync.when(
              data: (riskScore) {
                if (riskScore.triggeredRules.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
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
                            child: Text('No risk factors detected. Great job!'),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms);
                }

                return Column(
                  children: riskScore.triggeredRules.asMap().entries.map((entry) {
                    final rule = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RuleCard(
                        ruleName: rule.ruleName,
                        explanation: rule.explanation,
                        points: rule.pointsAdded,
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: 700 + entry.key * 100),
                            duration: 400.ms,
                          ),
                    );
                  }).toList(),
                );
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
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String ruleName;
  final String explanation;
  final int points;

  const _RuleCard({
    required this.ruleName,
    required this.explanation,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.riskModerate.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.riskModerate,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ruleName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.riskHigh.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+$points pts',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.riskHigh,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
        ),
      ),
    );
  }
}
