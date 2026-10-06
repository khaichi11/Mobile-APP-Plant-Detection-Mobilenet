import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/games/sliding_puzzle.dart';

/// Counts inversions to check that a board can still be solved.
bool isSolvable(SlidingPuzzle puzzle) {
  final size = puzzle.size;
  final values = puzzle.tiles.where((t) => t != puzzle.blankTile).toList();
  var inversions = 0;
  for (var i = 0; i < values.length; i++) {
    for (var j = i + 1; j < values.length; j++) {
      if (values[i] > values[j]) inversions++;
    }
  }
  if (size.isOdd) return inversions.isEven;
  final blankRowFromBottom = size - puzzle.blankIndex ~/ size;
  return blankRowFromBottom.isEven ? inversions.isOdd : inversions.isEven;
}

void main() {
  test('a solved board reports solved and has no hint', () {
    final puzzle = SlidingPuzzle.solved(3);
    expect(puzzle.isSolved, isTrue);
    expect(puzzle.hintPosition, isNull);
    expect(puzzle.blankIndex, 8);
  });

  test('scrambled boards are never solved and always solvable', () {
    for (var seed = 0; seed < 200; seed++) {
      for (final size in [3, 4]) {
        final puzzle = SlidingPuzzle.scrambled(size, 30, Random(seed));
        expect(puzzle.isSolved, isFalse, reason: 'seed $seed size $size');
        expect(isSolvable(puzzle), isTrue, reason: 'seed $seed size $size');
        expect(puzzle.tiles.toSet().length, size * size);
      }
    }
  });

  test('only tiles in the blank row or column can slide', () {
    final puzzle = SlidingPuzzle.solved(3); // blank at 8
    expect(puzzle.canSlide(7), isTrue);
    expect(puzzle.canSlide(6), isTrue);
    expect(puzzle.canSlide(2), isTrue);
    expect(puzzle.canSlide(4), isFalse);
    expect(puzzle.canSlide(8), isFalse);
    expect(puzzle.canSlide(-1), isFalse);
    expect(puzzle.canSlide(9), isFalse);
  });

  test('sliding a far tile moves the whole row', () {
    final puzzle = SlidingPuzzle.solved(3);
    expect(puzzle.slide(6), 2);
    expect(puzzle.tiles.sublist(6), [8, 6, 7]);
    expect(puzzle.blankIndex, 6);
    expect(puzzle.slide(4), 0);
  });

  test('following hints always solves the board', () {
    for (var seed = 0; seed < 50; seed++) {
      final random = Random(seed);
      final puzzle = SlidingPuzzle.scrambled(4, 60, random);
      // Make some random detours first.
      for (var i = 0; i < 25; i++) {
        final movable = [
          for (var p = 0; p < 16; p++)
            if (puzzle.canSlide(p)) p,
        ];
        puzzle.slide(movable[random.nextInt(movable.length)]);
      }
      var guard = 0;
      while (!puzzle.isSolved) {
        final hint = puzzle.hintPosition!;
        expect(puzzle.slide(hint), 1);
        expect(guard++ < 10000, isTrue);
      }
      expect(puzzle.hintPosition, isNull);
    }
  });
}
