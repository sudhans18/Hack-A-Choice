import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models/recommendation.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsProvider);
    final riskScoreAsync = ref.watch(currentRiskScoreProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/student'),
        ),
        title: const Text('Recommendations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            riskScoreAsync.when(
              data: (riskScore) => Card(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primaryLight.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personalized Tips',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              riskScore.triggeredRules.isEmpty
                                  ? 'You\'re doing great! Here are some wellness tips.'
                                  : 'Based on ${riskScore.triggeredRules.length} factor${riskScore.triggeredRules.length > 1 ? 's' : ''} we detected',
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
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              loading: () => const Card(
                child: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Recommendations list
            Text(
              'Your Recommendations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 12),

            recommendationsAsync.when(
              data: (recommendations) => Column(
                children: recommendations.asMap().entries.map((entry) {
                  final recommendation = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecommendationCard(recommendation: recommendation)
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 300 + entry.key * 100),
                          duration: 400.ms,
                        )
                        .slideX(begin: 0.1, end: 0),
                  );
                }).toList(),
              ),
              loading: () => const Card(
                child: SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, __) => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Error loading recommendations'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Wellness tips section
            Text(
              'General Wellness Tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            const SizedBox(height: 12),

            ..._wellnessTips.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _WellnessTipCard(
                  icon: entry.value['icon'] as IconData,
                  title: entry.value['title'] as String,
                  description: entry.value['description'] as String,
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 700 + entry.key * 100),
                      duration: 400.ms,
                    ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;

    switch (recommendation.type) {
      case RecommendationType.advisor:
        typeColor = AppColors.chartPurple;
        typeIcon = Icons.person_rounded;
        break;
      case RecommendationType.planning:
        typeColor = AppColors.chartBlue;
        typeIcon = Icons.checklist_rounded;
        break;
      case RecommendationType.scheduling:
        typeColor = AppColors.chartOrange;
        typeIcon = Icons.calendar_today_rounded;
        break;
      case RecommendationType.wellness:
        typeColor = AppColors.riskLow;
        typeIcon = Icons.spa_rounded;
        break;
    }

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
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  recommendation.type.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recommendation.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                  ),
                  if (recommendation.actionUrl != null) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(typeIcon, size: 18),
                      label: const Text('Take Action'),
                      style: TextButton.styleFrom(
                        foregroundColor: typeColor,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WellnessTipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _WellnessTipCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.riskLow.withOpacity(0.05),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.riskLow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.riskLow, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
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

const _wellnessTips = [
  {
    'icon': Icons.bedtime_rounded,
    'title': 'Get Enough Sleep',
    'description': 'Aim for 7-9 hours of quality sleep each night.',
  },
  {
    'icon': Icons.self_improvement_rounded,
    'title': 'Take Regular Breaks',
    'description': 'Use the Pomodoro technique: 25 min work, 5 min break.',
  },
  {
    'icon': Icons.group_rounded,
    'title': 'Connect with Others',
    'description': 'Social support helps reduce stress and anxiety.',
  },
  {
    'icon': Icons.directions_walk_rounded,
    'title': 'Stay Active',
    'description': 'Even a short walk can boost your mood and focus.',
  },
];
