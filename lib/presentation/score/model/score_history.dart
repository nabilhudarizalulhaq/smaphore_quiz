class ScoreHistory {
  const ScoreHistory({
    required this.level,
    required this.score,
    required this.maximumScore,
    required this.completedAt,
  });

  final int level;
  final int score;
  final int maximumScore;
  final DateTime completedAt;

  double get percentage =>
      maximumScore == 0 ? 0 : (score / maximumScore * 100).clamp(0, 100);

  Map<String, dynamic> toJson() => {
        'level': level,
        'score': score,
        'maximumScore': maximumScore,
        'completedAt': completedAt.toIso8601String(),
      };

  factory ScoreHistory.fromJson(Map<String, dynamic> json) {
    return ScoreHistory(
      level: (json['level'] as num?)?.toInt() ?? 1,
      score: (json['score'] as num?)?.toInt() ?? 0,
      maximumScore: (json['maximumScore'] as num?)?.toInt() ?? 0,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
