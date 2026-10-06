import 'dart:math';

import '../models/game_levels.dart';

class MemoryCard {
  MemoryCard({required this.plantId, required this.showsName});

  final String plantId;

  /// Shows the plant's name instead of its photo.
  final bool showsName;
  bool faceUp = false;
  bool matched = false;
}

enum FlipResult { ignored, first, match, mismatch }

class MemoryGame {
  MemoryGame(MemoryLevel level, Random random)
    : pairs = level.pairs,
      cards = [
        for (final id in level.plantIds) ...[
          MemoryCard(plantId: id, showsName: false),
          MemoryCard(
            plantId: id,
            showsName: level.mode == MemoryMode.photoToName,
          ),
        ],
      ]..shuffle(random);

  final int pairs;
  final List<MemoryCard> cards;

  /// Number of times two cards were turned over.
  int moves = 0;
  int? _first;
  int? _second;

  /// Two unmatched cards are face up and must be hidden first.
  bool get isBusy => _second != null;

  bool get isComplete => cards.every((card) => card.matched);

  FlipResult flip(int index) {
    final card = cards[index];
    if (isBusy || card.faceUp || card.matched) return FlipResult.ignored;
    card.faceUp = true;
    final first = _first;
    if (first == null) {
      _first = index;
      return FlipResult.first;
    }
    moves++;
    if (cards[first].plantId == card.plantId) {
      cards[first].matched = true;
      card.matched = true;
      _first = null;
      return FlipResult.match;
    }
    _second = index;
    return FlipResult.mismatch;
  }

  /// Turns the two mismatched cards face down again.
  void hideMismatch() {
    final first = _first;
    final second = _second;
    if (first == null || second == null) return;
    cards[first].faceUp = false;
    cards[second].faceUp = false;
    _first = null;
    _second = null;
  }
}
