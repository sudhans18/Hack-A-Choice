import 'student.dart';

/// Triggered rule details
class RuleTriggered {
  final String ruleId;
  final String ruleName;
  final String explanation;
  final int pointsAdded;

  const RuleTriggered({
    required this.ruleId,
    required this.ruleName,
    required this.explanation,
    required this.pointsAdded,
  });

  factory RuleTriggered.fromJson(Map<String, dynamic> json) {
    return RuleTriggered(
      ruleId: json['ruleId'] as String,
      ruleName: json['ruleName'] as String,
      explanation: json['explanation'] as String,
      pointsAdded: json['pointsAdded'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ruleId': ruleId,
      'ruleName': ruleName,
      'explanation': explanation,
      'pointsAdded': pointsAdded,
    };
  }
}

/// Risk score with explanation
class RiskScore {
  final int score;
  final RiskLevel level;
  final List<RuleTriggered> triggeredRules;
  final DateTime calculatedAt;

  const RiskScore({
    required this.score,
    required this.level,
    required this.triggeredRules,
    required this.calculatedAt,
  });

  factory RiskScore.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as int;
    return RiskScore(
      score: score,
      level: RiskLevel.fromScore(score),
      triggeredRules: (json['triggeredRules'] as List<dynamic>?)
              ?.map((e) => RuleTriggered.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'triggeredRules': triggeredRules.map((e) => e.toJson()).toList(),
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  /// Check if any rules were triggered
  bool get hasTriggeredRules => triggeredRules.isNotEmpty;

  /// Get total points from triggered rules
  int get totalPointsFromRules =>
      triggeredRules.fold(0, (sum, rule) => sum + rule.pointsAdded);
}

/// Historical risk score for trend chart
class RiskScoreHistory {
  final DateTime date;
  final int score;

  const RiskScoreHistory({
    required this.date,
    required this.score,
  });

  factory RiskScoreHistory.fromJson(Map<String, dynamic> json) {
    return RiskScoreHistory(
      date: DateTime.parse(json['date'] as String),
      score: json['score'] as int,
    );
  }
}
