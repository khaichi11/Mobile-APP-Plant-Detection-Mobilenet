import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/state/game_rules.dart';

void main() {
  test('stars drop with mistakes', () {
    expect(GameRules.starsForMistakes(0), 3);
    expect(GameRules.starsForMistakes(1), 2);
    expect(GameRules.starsForMistakes(4), 1);
  });

  test('puzzle stars compare moves with the scramble length', () {
    expect(GameRules.puzzleStars(moves: 50, par: 30), 3);
    expect(GameRules.puzzleStars(moves: 100, par: 30), 2);
    expect(GameRules.puzzleStars(moves: 500, par: 30), 1);
  });

  test('memory stars reward few moves', () {
    expect(GameRules.memoryStars(moves: 3, pairs: 3), 3);
    expect(GameRules.memoryStars(moves: 8, pairs: 3), 2);
    expect(GameRules.memoryStars(moves: 20, pairs: 3), 1);
  });

  test('points are only given for new stars', () {
    expect(GameRules.pointsForImprovement(0, 2), 20);
    expect(GameRules.pointsForImprovement(2, 3), 10);
    expect(GameRules.pointsForImprovement(3, 1), 0);
  });

  test('ranks follow the points', () {
    expect(RankProgress.fromPoints(0).rank.title, 'Seedling');
    expect(RankProgress.fromPoints(150).rank.title, 'Sprout');
    expect(RankProgress.fromPoints(200).progress, closeTo(0.5, 0.001));
    expect(RankProgress.fromPoints(200).pointsToNext, 100);
    final top = RankProgress.fromPoints(5000);
    expect(top.next, isNull);
    expect(top.progress, 1);
    expect(top.level, ranks.length);
  });
}
