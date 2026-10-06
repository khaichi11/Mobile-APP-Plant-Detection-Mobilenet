import '../models/user_profile.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    this.isMe = false,
  });

  final int rank;
  final String name;
  final int points;
  final bool isMe;
}

abstract interface class LeaderboardRepository {
  /// Whether the entries are sample data rather than real players.
  bool get isDemo;

  Future<List<LeaderboardEntry>> fetch({
    required UserProfile me,
    required int myPoints,
  });
}

/// Sample classmates, used until an online leaderboard is set up.
class DemoLeaderboardRepository implements LeaderboardRepository {
  const DemoLeaderboardRepository();

  static const classmates = <(String, int)>[
    ('Ayu', 1240),
    ('Bima', 980),
    ('Citra', 860),
    ('Dimas', 720),
    ('Eka', 610),
    ('Fajar', 450),
    ('Gita', 380),
    ('Hana', 240),
    ('Indra', 150),
    ('Joko', 90),
  ];

  @override
  bool get isDemo => true;

  @override
  Future<List<LeaderboardEntry>> fetch({
    required UserProfile me,
    required int myPoints,
  }) async {
    final rows = [
      for (final (name, points) in classmates) (name, points, false),
      (me.name, myPoints, true),
    ];
    // Ties are won by the player, which feels fair to young learners.
    rows.sort((a, b) {
      final byPoints = b.$2.compareTo(a.$2);
      if (byPoints != 0) return byPoints;
      return (b.$3 ? 1 : 0).compareTo(a.$3 ? 1 : 0);
    });
    return [
      for (var i = 0; i < rows.length; i++)
        LeaderboardEntry(
          rank: i + 1,
          name: rows[i].$1,
          points: rows[i].$2,
          isMe: rows[i].$3,
        ),
    ];
  }
}
