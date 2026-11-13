class UserStats {
  final List<String> activeDays;
  final int streakCount;
  final int longestStreak;
  final double totalPlaytimeMinutes;
  final int totalSessions;
  final Map<String, int> activityCounts;

  const UserStats({
    required this.activeDays,
    required this.streakCount,
    required this.longestStreak,
    required this.totalPlaytimeMinutes,
    required this.totalSessions,
    required this.activityCounts,
  });

  factory UserStats.empty() {
    return const UserStats(
      activeDays: [],
      streakCount: 0,
      longestStreak: 0,
      totalPlaytimeMinutes: 0.0,
      totalSessions: 0,
      activityCounts: {
        'balls': 0,
        'popit': 0,
        'spiders': 0,
        'sound_therapy': 0,
        'cockroach': 0,
        'rmp': 0,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeDays': activeDays,
      'streakCount': streakCount,
      'longestStreak': longestStreak,
      'totalPlaytimeMinutes': totalPlaytimeMinutes,
      'totalSessions': totalSessions,
      'activityCounts': activityCounts,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      activeDays: List<String>.from(json['activeDays'] ?? []),
      streakCount: json['streakCount'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalPlaytimeMinutes: (json['totalPlaytimeMinutes'] ?? 0.0).toDouble(),
      totalSessions: json['totalSessions'] ?? 0,
      activityCounts: Map<String, int>.from(
        json['activityCounts'] ??
            {
              'balls': 0,
              'popit': 0,
              'spiders': 0,
              'sound_therapy': 0,
              'cockroach': 0,
              'rmp': 0,
            },
      ),
    );
  }

  UserStats copyWith({
    List<String>? activeDays,
    int? streakCount,
    int? longestStreak,
    double? totalPlaytimeMinutes,
    int? totalSessions,
    Map<String, int>? activityCounts,
  }) {
    return UserStats(
      activeDays: activeDays ?? this.activeDays,
      streakCount: streakCount ?? this.streakCount,
      longestStreak: longestStreak ?? this.longestStreak,
      totalPlaytimeMinutes: totalPlaytimeMinutes ?? this.totalPlaytimeMinutes,
      totalSessions: totalSessions ?? this.totalSessions,
      activityCounts: activityCounts ?? this.activityCounts,
    );
  }
}
