class PuzzleLevel {
  const PuzzleLevel({
    required this.number,
    required this.gridSize,
    required this.imageAsset,
    required this.title,
    required this.fact,
  });

  final int number;
  final int gridSize;
  final String imageAsset;

  /// Name of the plant in the picture, revealed when solved.
  final String title;

  /// Shown after the puzzle is solved.
  final String fact;

  /// Random moves used to scramble the board. Also the par for stars, since
  /// undoing the scramble always solves it.
  int get shuffleMoves => gridSize == 3 ? 30 : 60;
}

enum MemoryMode {
  /// Match two identical photos.
  photoPairs,

  /// Match a photo with the plant's name.
  photoToName,
}

class MemoryLevel {
  const MemoryLevel({
    required this.number,
    required this.pairs,
    required this.mode,
    required this.plantIds,
  });

  final int number;
  final int pairs;
  final MemoryMode mode;
  final List<String> plantIds;

  int get cardCount => pairs * 2;

  int get columns => cardCount <= 8 ? 2 : (cardCount <= 12 ? 3 : 4);
}
