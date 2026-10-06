import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/formatting.dart';
import '../../../core/theme.dart';
import '../../../data/game_levels.dart';
import '../../../data/plant_catalog.dart';
import '../../../games/memory_game.dart';
import '../../../models/game_levels.dart';
import '../../../state/app_state.dart';
import '../../../state/game_rules.dart';
import '../../art/logo.dart';
import '../../widgets/common.dart';
import '../../widgets/images.dart';
import '../level_complete.dart';

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key, required this.level, this.random});

  final MemoryLevel level;

  /// Lets tests use a fixed card order.
  final Random? random;

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  late MemoryGame _game;
  Timer? _hideTimer;
  Timer? _clock;
  int _seconds = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _clock?.cancel();
    super.dispose();
  }

  void _start() {
    _hideTimer?.cancel();
    _clock?.cancel();
    _clock = null;
    _game = MemoryGame(widget.level, widget.random ?? Random());
    _seconds = 0;
    _finished = false;
  }

  void _flip(int index) {
    _clock ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
    final result = _game.flip(index);
    if (result == FlipResult.ignored) return;
    setState(() {});
    if (result == FlipResult.mismatch) {
      _hideTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(_game.hideMismatch);
      });
    } else if (result == FlipResult.match && _game.isComplete) {
      _onComplete();
    }
  }

  Future<void> _onComplete() async {
    _clock?.cancel();
    setState(() => _finished = true);
    final level = widget.level;
    final stars = GameRules.memoryStars(moves: _game.moves, pairs: level.pairs);
    final earned = await context.read<AppState>().completeMemory(
      level.number,
      stars,
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final next =
        level.number < memoryLevels.length ? memoryLevels[level.number] : null;
    final action = await showLevelComplete(
      context,
      title: 'All pairs found!',
      stars: stars,
      points: earned,
      stats: [
        (Icons.touch_app_outlined, '${_game.moves} moves'),
        (Icons.timer_outlined, formatDuration(_seconds)),
      ],
      hasNext: next != null,
    );
    if (!mounted) return;
    switch (action) {
      case LevelCompleteAction.next:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => MemoryGamePage(level: next!)),
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
    final level = widget.level;
    final started = _game.moves > 0 || _game.cards.any((c) => c.faceUp);
    return PopScope(
      canPop: !started || _finished,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await confirmLeaveGame(context)) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Memory · Level ${level.number}')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Gap.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        level.mode == MemoryMode.photoToName
                            ? 'Match each photo with its name'
                            : 'Find the matching photos',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Tag('${_game.moves} moves', icon: Icons.touch_app_outlined),
                    const SizedBox(width: Gap.sm),
                    Tag(formatDuration(_seconds), icon: Icons.timer_outlined),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = Gap.sm;
                      final columns = level.columns;
                      final rows = (level.cardCount / columns).ceil();
                      final width =
                          (constraints.maxWidth - gap * (columns - 1)) /
                          columns;
                      final maxHeight =
                          (constraints.maxHeight - gap * (rows - 1)) / rows;
                      final height = min(maxHeight, width * 1.3);
                      return Center(
                        child: Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (var i = 0; i < _game.cards.length; i++)
                              SizedBox(
                                width: width,
                                height: height,
                                child: _MemoryCardView(
                                  card: _game.cards[i],
                                  onTap: () => _flip(i),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryCardView extends StatelessWidget {
  const _MemoryCardView({required this.card, required this.onTap});

  final MemoryCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visible = card.faceUp || card.matched;
    final plant = plantById(card.plantId);
    return Semantics(
      container: true,
      button: true,
      excludeSemantics: true,
      label:
          visible
              ? (card.showsName
                  ? plant.commonName
                  : 'Photo of ${plant.commonName}')
              : 'Hidden card',
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: visible ? 1 : 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          builder: (context, value, _) {
            final showFront = value >= 0.5;
            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(pi * value),
              child:
                  showFront
                      ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: _front(
                          context,
                          plant.commonName,
                          plant.localName,
                        ),
                      )
                      : _back(),
            );
          },
        ),
      ),
    );
  }

  Widget _back() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      alignment: Alignment.center,
      child: const PandaiLogo(size: 44, monochrome: Colors.white),
    );
  }

  Widget _front(BuildContext context, String name, String localName) {
    final theme = Theme.of(context);
    final border = Border.all(
      color: card.matched ? AppColors.leaf : AppColors.line,
      width: card.matched ? 3 : 1.5,
    );
    if (card.showsName) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(Radii.md),
          border: border,
        ),
        padding: const EdgeInsets.all(6),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.forestDark,
                  ),
                ),
                Text(
                  localName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.md),
        border: border,
      ),
      child: PlantPhoto(card.plantId, radius: Radii.md - 2),
    );
  }
}
