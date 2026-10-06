import 'dart:math';

/// A sliding tile puzzle. `tiles[position]` holds the tile that should end
/// up at that position; the last tile id is the empty slot.
///
/// The puzzle also tracks a path back to the solution, so hints are always
/// correct: it starts as the reverse of the scramble, and every move the
/// player makes is either a step along it or a detour that gets undone.
class SlidingPuzzle {
  SlidingPuzzle._(this.size, this.tiles, this._solution);

  /// Scrambles a solved board with [moves] random slides. The blank never
  /// steps straight back, and the result is never already solved.
  factory SlidingPuzzle.scrambled(int size, int moves, Random random) {
    assert(size >= 2 && moves >= 2);
    while (true) {
      final puzzle = SlidingPuzzle.solved(size);
      var previous = -1;
      for (var i = 0; i < moves; i++) {
        final blank = puzzle.blankIndex;
        final options = puzzle._neighbors(blank)..remove(previous);
        final target = options[random.nextInt(options.length)];
        puzzle._solution.add(blank);
        puzzle._swap(blank, target);
        previous = blank;
      }
      if (!puzzle.isSolved) return puzzle;
    }
  }

  factory SlidingPuzzle.solved(int size) =>
      SlidingPuzzle._(size, List<int>.generate(size * size, (i) => i), []);

  final int size;
  final List<int> tiles;

  /// Positions the blank must visit to solve the board; the next one is last.
  final List<int> _solution;

  int get blankTile => size * size - 1;
  int get blankIndex => tiles.indexOf(blankTile);

  bool get isSolved {
    for (var i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) return false;
    }
    return true;
  }

  /// Position of the tile to move next, or null when solved.
  int? get hintPosition =>
      isSolved || _solution.isEmpty ? null : _solution.last;

  /// Whether the tile at [position] shares a row or column with the blank.
  bool canSlide(int position) {
    final blank = blankIndex;
    if (position == blank || position < 0 || position >= tiles.length) {
      return false;
    }
    return position ~/ size == blank ~/ size || position % size == blank % size;
  }

  /// Slides the tile at [position], and every tile between it and the blank,
  /// one step toward the blank. Returns the number of tiles that moved.
  int slide(int position) {
    if (!canSlide(position)) return 0;
    final blank = blankIndex;
    final step =
        position ~/ size == blank ~/ size
            ? (position > blank ? 1 : -1)
            : (position > blank ? size : -size);
    var moved = 0;
    var current = blank;
    while (current != position) {
      final next = current + step;
      _stepBlankTo(next);
      current = next;
      moved++;
    }
    return moved;
  }

  void _stepBlankTo(int next) {
    final blank = blankIndex;
    if (_solution.isNotEmpty && _solution.last == next) {
      _solution.removeLast();
    } else {
      _solution.add(blank);
    }
    _swap(blank, next);
    if (isSolved) _solution.clear();
  }

  List<int> _neighbors(int index) {
    final row = index ~/ size;
    final col = index % size;
    return [
      if (row > 0) index - size,
      if (row < size - 1) index + size,
      if (col > 0) index - 1,
      if (col < size - 1) index + 1,
    ];
  }

  void _swap(int a, int b) {
    final temp = tiles[a];
    tiles[a] = tiles[b];
    tiles[b] = temp;
  }
}
