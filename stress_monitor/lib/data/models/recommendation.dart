/// Recommendation type
enum RecommendationType {
  advisor,
  planning,
  scheduling,
  wellness;

  String get icon {
    switch (this) {
      case RecommendationType.advisor:
        return '👨‍🏫';
      case RecommendationType.planning:
        return '📋';
      case RecommendationType.scheduling:
        return '📅';
      case RecommendationType.wellness:
        return '🧘';
    }
  }
}

/// Recommendation model
class Recommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationType type;
  final String? actionUrl;
  final String? relatedRuleId;

  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.actionUrl,
    this.relatedRuleId,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: RecommendationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RecommendationType.wellness,
      ),
      actionUrl: json['actionUrl'] as String?,
      relatedRuleId: json['relatedRuleId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'actionUrl': actionUrl,
      'relatedRuleId': relatedRuleId,
    };
  }
}

/// Predefined recommendations based on triggered rules
class RecommendationEngine {
  static List<Recommendation> getRecommendations(List<String> triggeredRuleIds) {
    final recommendations = <Recommendation>[];

    for (final ruleId in triggeredRuleIds) {
      switch (ruleId) {
        case 'attendance_drop':
          recommendations.add(const Recommendation(
            id: 'rec_advisor_attendance',
            title: 'Schedule Advisor Meeting',
            description:
                'Your attendance has dropped recently. Consider meeting with your academic advisor to discuss any challenges.',
            type: RecommendationType.advisor,
            relatedRuleId: 'attendance_drop',
          ));
          break;
        case 'late_submissions':
          recommendations.add(const Recommendation(
            id: 'rec_planning_deadlines',
            title: 'Improve Deadline Management',
            description:
                'You have had multiple late submissions. Try using a task management app or calendar reminders.',
            type: RecommendationType.planning,
            relatedRuleId: 'late_submissions',
          ));
          break;
        case 'workload_spike':
          recommendations.add(const Recommendation(
            id: 'rec_schedule_balance',
            title: 'Balance Your Schedule',
            description:
                'Your workload has increased significantly. Consider prioritizing tasks and taking breaks.',
            type: RecommendationType.scheduling,
            relatedRuleId: 'workload_spike',
          ));
          break;
        case 'missing_submission':
          recommendations.add(const Recommendation(
            id: 'rec_catch_up',
            title: 'Catch Up on Missing Work',
            description:
                'You have missing assignments. Reach out to your instructor about extensions or support.',
            type: RecommendationType.advisor,
            relatedRuleId: 'missing_submission',
          ));
          break;
        case 'behavior_change':
          recommendations.add(const Recommendation(
            id: 'rec_wellness',
            title: 'Check In on Yourself',
            description:
                'We noticed a sudden change in your patterns. Consider talking to a counselor if you\'re feeling overwhelmed.',
            type: RecommendationType.wellness,
            relatedRuleId: 'behavior_change',
          ));
          break;
      }
    }

    // Always add a general wellness recommendation
    if (recommendations.isEmpty) {
      recommendations.add(const Recommendation(
        id: 'rec_general',
        title: 'Keep Up the Good Work!',
        description:
            'You\'re on track. Remember to take breaks and maintain a healthy balance.',
        type: RecommendationType.wellness,
      ));
    }

    return recommendations;
  }
}
