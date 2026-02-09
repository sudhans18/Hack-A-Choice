/// Risk level enumeration
enum RiskLevel {
  low,
  moderate,
  high;

  static RiskLevel fromScore(int score) {
    if (score <= 30) return RiskLevel.low;
    if (score <= 60) return RiskLevel.moderate;
    return RiskLevel.high;
  }

  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.moderate:
        return 'Moderate';
      case RiskLevel.high:
        return 'High';
    }
  }

  String get description {
    switch (this) {
      case RiskLevel.low:
        return 'You\'re doing great! Keep up the good work.';
      case RiskLevel.moderate:
        return 'Some areas need attention. Check recommendations.';
      case RiskLevel.high:
        return 'Action needed. Please review and seek support.';
    }
  }
}

/// Student model
class Student {
  final String id;
  final String name;
  final String department;
  final String? email;
  final String? avatarUrl;
  final int? riskScore;
  final RiskLevel? riskLevel;

  const Student({
    required this.id,
    required this.name,
    required this.department,
    this.email,
    this.avatarUrl,
    this.riskScore,
    this.riskLevel,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    final score = json['riskScore'] as int?;
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      riskScore: score,
      riskLevel: score != null ? RiskLevel.fromScore(score) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'email': email,
      'avatarUrl': avatarUrl,
      'riskScore': riskScore,
    };
  }

  Student copyWith({
    String? id,
    String? name,
    String? department,
    String? email,
    String? avatarUrl,
    int? riskScore,
    RiskLevel? riskLevel,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      riskScore: riskScore ?? this.riskScore,
      riskLevel: riskLevel ?? this.riskLevel,
    );
  }
}
