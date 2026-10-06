import 'dart:math' as math;

/// Scoring rules shared by every game. Points are only given for
/// improvements, so replaying a finished level cannot farm points.
abstract final class GameRules {
  static const pointsPerStar = 10;
  static const newSpeciesPoints = 30;
  static const quizPointsPerCorrect = 5;
  static const dailyHints = 3;
  static const scanConfidenceThreshold = 0.35;

  /// Stars for quiz-style games: no mistakes earns 3 stars.
  static int starsForMistakes(int mistakes) {
    if (mistakes <= 0) return 3;
    if (mistakes == 1) return 2;
    return 1;
  }

  /// [par] is the number of scramble moves, an upper bound of the best
  /// solution.
  static int puzzleStars({required int moves, required int par}) {
    if (moves <= par * 2) return 3;
    if (moves <= par * 4) return 2;
    return 1;
  }

  /// A move is one attempt of turning over two cards.
  static int memoryStars({required int moves, required int pairs}) {
    if (moves <= (pairs * 1.7).ceil()) return 3;
    if (moves <= (pairs * 2.5).ceil()) return 2;
    return 1;
  }

  /// Points earned when a level goes from [previousStars] to [newStars].
  static int pointsForImprovement(int previousStars, int newStars) {
    return math.max(0, newStars - previousStars) * pointsPerStar;
  }
}

class Rank {
  const Rank(this.title, this.minPoints);
  final String title;
  final int minPoints;
}

const ranks = <Rank>[
  Rank('Seedling', 0),
  Rank('Sprout', 100),
  Rank('Sapling', 300),
  Rank('Young Tree', 600),
  Rank('Mighty Tree', 1000),
  Rank('Forest Guardian', 1600),
];

class RankProgress {
  const RankProgress({
    required this.rank,
    required this.next,
    required this.points,
  });

  factory RankProgress.fromPoints(int points) {
    var index = 0;
    for (var i = 0; i < ranks.length; i++) {
      if (points >= ranks[i].minPoints) index = i;
    }
    return RankProgress(
      rank: ranks[index],
      next: index + 1 < ranks.length ? ranks[index + 1] : null,
      points: points,
    );
  }

  final Rank rank;
  final Rank? next;
  final int points;

  int get level => ranks.indexOf(rank) + 1;

  /// Progress from 0 to 1 toward the next rank.
  double get progress {
    final upcoming = next;
    if (upcoming == null) return 1;
    final span = upcoming.minPoints - rank.minPoints;
    return ((points - rank.minPoints) / span).clamp(0.0, 1.0);
  }

  int get pointsToNext => next == null ? 0 : next!.minPoints - points;
}
