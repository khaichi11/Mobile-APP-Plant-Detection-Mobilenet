import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/formatting.dart';
import '../../../core/theme.dart';
import '../../../data/game_levels.dart';
import '../../../games/sliding_puzzle.dart';
import '../../../models/game_levels.dart';
import '../../../state/app_state.dart';
import '../../../state/game_rules.dart';
import '../../widgets/common.dart';
import '../level_complete.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key, required this.level, this.random});

  final PuzzleLevel level;

  /// Lets tests use a fixed scramble.
  final Random? random;

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  late SlidingPuzzle _puzzle;
  int _moves = 0;
  int _seconds = 0;
  Timer? _clock;
  Timer? _hintTimer;
  bool _showNumbers = true;
  bool _peeking = false;
  bool _solved = false;

  /// Tile id that the hint points at.
  int? _hintTile;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _clock?.cancel();
    _hintTimer?.cancel();
    super.dispose();
  }

  void _start() {
    _clock?.cancel();
    _hintTimer?.cancel();
    _puzzle = SlidingPuzzle.scrambled(
      widget.level.gridSize,
      widget.level.shuffleMoves,
      widget.random ?? Random(),
    );
    _moves = 0;
    _seconds = 0;
    _clock = null;
    _hintTile = null;
    _solved = false;
  }

  void _tap(int position) {
    if (_solved || !_puzzle.canSlide(position)) return;
    _clock ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
    HapticFeedback.selectionClick();
    setState(() {
      _moves += _puzzle.slide(position);
      _hintTile = null;
    });
    if (_puzzle.isSolved) _onSolved();
  }

  Future<void> _hint() async {
    final position = _puzzle.hintPosition;
    if (position == null) return;
    final allowed = await context.read<AppState>().useHint();
    if (!mounted) return;
    if (!allowed) {
      showMessage(context, 'No hints left today. Come back tomorrow!');
      return;
    }
    setState(() => _hintTile = _puzzle.tiles[position]);
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _hintTile = null);
    });
  }

  Future<void> _onSolved() async {
    _clock?.cancel();
    setState(() => _solved = true);
    final level = widget.level;
    final stars = GameRules.puzzleStars(moves: _moves, par: level.shuffleMoves);
    final earned = await context.read<AppState>().completePuzzle(
      level.number,
      stars: stars,
      moves: _moves,
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final next =
        level.number < puzzleLevels.length ? puzzleLevels[level.number] : null;
    final action = await showLevelComplete(
      context,
      title: 'You revealed the ${level.title}!',
      stars: stars,
      points: earned,
      message: level.fact,
      stats: [
        (Icons.swap_horiz_rounded, '$_moves moves'),
        (Icons.timer_outlined, formatDuration(_seconds)),
      ],
      hasNext: next != null,
      nextLabel: 'Next puzzle',
    );
    if (!mounted) return;
    switch (action) {
      case LevelCompleteAction.next:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => PuzzlePage(level: next!)),
        );
      case LevelCompleteAction.replay:
        setState(_start);
      case LevelCompleteAction.close:
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintsLeft = context.watch<AppState>().hintsLeft;

    return PopScope(
      canPop: _moves == 0 || _solved,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await confirmLeaveGame(context)) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Puzzle ${widget.level.number}'),
          actions: [
            IconButton(
              tooltip: _showNumbers ? 'Hide numbers' : 'Show numbers',
              onPressed: () => setState(() => _showNumbers = !_showNumbers),
              icon: Icon(
                _showNumbers
                    ? Icons.looks_one_rounded
                    : Icons.looks_one_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Shuffle again',
              onPressed: _solved ? null : () => setState(_start),
              icon: const Icon(Icons.restart_alt_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Gap.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rebuild the photo',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            'Tap a tile next to the empty space to slide it.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Tag('$_moves moves', icon: Icons.swap_horiz_rounded),
                    const SizedBox(width: Gap.sm),
                    Tag(formatDuration(_seconds), icon: Icons.timer_outlined),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _Board(
                        puzzle: _puzzle,
                        asset: widget.level.imageAsset,
                        showNumbers: _showNumbers,
                        peeking: _peeking || _solved,
                        hintTile: _hintTile,
                        onTap: _tap,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Gap.lg),
                Row(
                  children: [
                    Expanded(
                      child: Listener(
                        onPointerDown: (_) => setState(() => _peeking = true),
                        onPointerUp: (_) => setState(() => _peeking = false),
                        onPointerCancel:
                            (_) => setState(() => _peeking = false),
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Hold to peek'),
                        ),
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _solved || hintsLeft == 0 ? null : _hint,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.sun,
                          foregroundColor: AppColors.ink,
                        ),
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        label: Text('Hint ($hintsLeft)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({
    required this.puzzle,
    required this.asset,
    required this.showNumbers,
    required this.peeking,
    required this.hintTile,
    required this.onTap,
  });

  final SlidingPuzzle puzzle;
  final String asset;
  final bool showNumbers;
  final bool peeking;
  final int? hintTile;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final board = constraints.maxWidth;
        final size = puzzle.size;
        final tile = board / size;
        final image = ResizeImage(
          AssetImage(asset),
          width: (board * MediaQuery.devicePixelRatioOf(context)).round(),
        );
        return ClipRRect(
          borderRadius: BorderRadius.circular(Radii.md),
          child: Container(
            color: AppColors.forestDark.withValues(alpha: 0.12),
            child: Stack(
              children: [
                for (
                  var position = 0;
                  position < puzzle.tiles.length;
                  position++
                )
                  if (puzzle.tiles[position] != puzzle.blankTile)
                    AnimatedPositioned(
                      key: ValueKey(puzzle.tiles[position]),
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOut,
                      left: (position % size) * tile,
                      top: (position ~/ size) * tile,
                      width: tile,
                      height: tile,
                      child: GestureDetector(
                        onTap: () => onTap(position),
                        child: _Tile(
                          id: puzzle.tiles[position],
                          size: size,
                          board: board,
                          image: image,
                          showNumber: showNumbers,
                          highlighted: hintTile == puzzle.tiles[position],
                        ),
                      ),
                    ),
                IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: peeking ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Image(
                      image: image,
                      width: board,
                      height: board,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.id,
    required this.size,
    required this.board,
    required this.image,
    required this.showNumber,
    required this.highlighted,
  });

  final int id;
  final int size;
  final double board;
  final ImageProvider image;
  final bool showNumber;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final tile = board / size;
    final row = id ~/ size;
    final col = id % size;
    return Semantics(
      container: true,
      button: true,
      label: 'Tile ${id + 1}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: board,
                maxWidth: board,
                minHeight: board,
                maxHeight: board,
                child: Transform.translate(
                  offset: Offset(-col * tile - 1.5, -row * tile - 1.5),
                  child: Image(
                    image: image,
                    width: board,
                    height: board,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              if (showNumber)
                Positioned(
                  left: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${id + 1}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (highlighted)
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.sun, width: 4),
                    color: AppColors.sun.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
