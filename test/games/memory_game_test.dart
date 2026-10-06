import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/data/game_levels.dart';
import 'package:pandai/games/memory_game.dart';
import 'package:pandai/models/game_levels.dart';

void main() {
  const level = MemoryLevel(
    number: 1,
    pairs: 2,
    mode: MemoryMode.photoToName,
    plantIds: ['sunflower', 'tomato'],
  );

  int indexOf(MemoryGame game, String plantId, {required bool name}) =>
      game.cards.indexWhere((c) => c.plantId == plantId && c.showsName == name);

  test('builds two cards per plant, one of them a name card', () {
    final game = MemoryGame(level, Random(1));
    expect(game.cards, hasLength(4));
    expect(game.cards.where((c) => c.showsName), hasLength(2));
  });

  test('photo pair levels only use photo cards', () {
    final game = MemoryGame(memoryLevels.first, Random(1));
    expect(game.cards.every((c) => !c.showsName), isTrue);
  });

  test('matching cards stay face up and count one move', () {
    final game = MemoryGame(level, Random(2));
    expect(
      game.flip(indexOf(game, 'sunflower', name: false)),
      FlipResult.first,
    );
    expect(game.flip(indexOf(game, 'sunflower', name: true)), FlipResult.match);
    expect(game.moves, 1);
    expect(game.cards.where((c) => c.matched), hasLength(2));
  });

  test('a mismatch blocks flips until the cards are hidden', () {
    final game = MemoryGame(level, Random(3));
    final sun = indexOf(game, 'sunflower', name: false);
    final tomato = indexOf(game, 'tomato', name: true);
    game.flip(sun);
    expect(game.flip(tomato), FlipResult.mismatch);
    expect(game.isBusy, isTrue);
    expect(game.flip(indexOf(game, 'tomato', name: false)), FlipResult.ignored);
    game.hideMismatch();
    expect(game.cards[sun].faceUp, isFalse);
    expect(game.cards[tomato].faceUp, isFalse);
    expect(game.isBusy, isFalse);
  });

  test('flipping the same card twice is ignored', () {
    final game = MemoryGame(level, Random(4));
    game.flip(0);
    expect(game.flip(0), FlipResult.ignored);
    expect(game.moves, 0);
  });

  test('the game completes when all pairs are found', () {
    final game = MemoryGame(level, Random(5));
    for (final id in level.plantIds) {
      game.flip(indexOf(game, id, name: false));
      game.flip(indexOf(game, id, name: true));
    }
    expect(game.isComplete, isTrue);
    expect(game.moves, 2);
  });
}
