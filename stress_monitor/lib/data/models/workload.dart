/// Workload data model
class Workload {
  final String id;
  final String studentId;
  final DateTime weekStart;
  final int tasksCount;

  const Workload({
    required this.id,
    required this.studentId,
    required this.weekStart,
    required this.tasksCount,
  });

  factory Workload.fromJson(Map<String, dynamic> json) {
    return Workload(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      tasksCount: json['tasksCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'weekStart': weekStart.toIso8601String(),
      'tasksCount': tasksCount,
    };
  }
}

/// Workload summary with trend analysis
class WorkloadSummary {
  final List<Workload> weeklyData;
  final int currentWeekTasks;
  final int previousWeekTasks;
  final double changePercentage;
  final bool hasSpike;

  const WorkloadSummary({
    required this.weeklyData,
    required this.currentWeekTasks,
    required this.previousWeekTasks,
    required this.changePercentage,
    required this.hasSpike,
  });

  factory WorkloadSummary.fromWeeklyData(List<Workload> data) {
    if (data.isEmpty) {
      return const WorkloadSummary(
        weeklyData: [],
        currentWeekTasks: 0,
        previousWeekTasks: 0,
        changePercentage: 0,
        hasSpike: false,
      );
    }

    final sorted = List<Workload>.from(data)
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));

    final current = sorted.isNotEmpty ? sorted.first.tasksCount : 0;
    final previous = sorted.length > 1 ? sorted[1].tasksCount : current;

    final change = previous > 0 ? ((current - previous) / previous) * 100 : 0.0;

    return WorkloadSummary(
      weeklyData: sorted,
      currentWeekTasks: current,
      previousWeekTasks: previous,
      changePercentage: change,
      hasSpike: change > 40, // 40% increase triggers spike warning
    );
  }
}
