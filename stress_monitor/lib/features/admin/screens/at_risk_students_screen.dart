import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/providers.dart';
import '../../../data/models/student.dart';

class AtRiskStudentsScreen extends ConsumerStatefulWidget {
  const AtRiskStudentsScreen({super.key});

  @override
  ConsumerState<AtRiskStudentsScreen> createState() => _AtRiskStudentsScreenState();
}

class _AtRiskStudentsScreenState extends ConsumerState<AtRiskStudentsScreen> {
  String _searchQuery = '';
  RiskLevel? _filterLevel;
  String? _filterDepartment;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(atRiskStudentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/admin'),
        ),
        title: const Text('At-Risk Students'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (value) {
              setState(() {
                if (value == 'all') {
                  _filterLevel = null;
                } else if (value == 'high') {
                  _filterLevel = RiskLevel.high;
                } else if (value == 'moderate') {
                  _filterLevel = RiskLevel.moderate;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Risk Levels')),
              const PopupMenuItem(value: 'high', child: Text('High Risk Only')),
              const PopupMenuItem(value: 'moderate', child: Text('Moderate Risk Only')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Filter chips
          if (_filterLevel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text('${_filterLevel!.displayName} Risk'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => setState(() => _filterLevel = null),
                    backgroundColor: AppColors.getRiskColor(
                      _filterLevel == RiskLevel.high ? 80 : 50,
                    ).withOpacity(0.1),
                  ),
                ],
              ),
            ),

          // Students list
          Expanded(
            child: studentsAsync.when(
              data: (students) {
                var filtered = students;

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered
                      .where((s) =>
                          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          s.department.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          s.id.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // Apply risk level filter
                if (_filterLevel != null) {
                  filtered = filtered.where((s) => s.riskLevel == _filterLevel).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _StudentCard(
                        student: student,
                        onTap: () => context.go('/admin/student/${student.id}'),
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: index * 50),
                            duration: 300.ms,
                          ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error loading students')),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;

  const _StudentCard({
    required this.student,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = AppColors.getRiskColor(student.riskScore ?? 0);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: riskColor.withOpacity(0.1),
                child: Text(
                  student.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          student.department,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.badge_rounded,
                          size: 14,
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
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.riskLevel?.displayName ?? 'Unknown',
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
