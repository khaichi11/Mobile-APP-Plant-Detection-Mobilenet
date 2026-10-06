import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../data/story_levels.dart';
import '../../../models/story.dart';
import '../../../state/app_state.dart';
import '../../widgets/common.dart';
import 'story_player_page.dart';

class _MapLayout {
  _MapLayout(double width) {
    final centerX = width / 2;
    var y = 24.0;
    var index = 0;
    Offset? previous;
    for (final chapter in storyChapters) {
      chapterTops.add(y);
      // The trail runs into the chapter sign and out of it again.
      if (previous != null) segments.add((previous, Offset(centerX, y)));
      previous = Offset(centerX, y + bannerHeight);
      y += bannerHeight + 36;
      for (var i = 0; i < chapter.levelIds.length; i++) {
        // Zig-zag like the original map: right, left, right...
        final node = Offset(index.isEven ? width * 0.7 : width * 0.3, y + 56);
        nodes.add(node);
        segments.add((previous!, node));
        previous = node;
        y += 150;
        index++;
      }
      y += 4;
    }
    // Leave room so the last level scrolls clear of the leaves.
    height = y + 200;
  }

  static const bannerHeight = 64.0;

  final chapterTops = <double>[];
  final nodes = <Offset>[];
  final segments = <(Offset, Offset)>[];
  late final double height;
}

/// PETA (Petualangan Tanaman), the story adventure map.
class AdventureMapPage extends StatefulWidget {
  const AdventureMapPage({super.key});

  @override
  State<AdventureMapPage> createState() => _AdventureMapPageState();
}

class _AdventureMapPageState extends State<AdventureMapPage>
    with TickerProviderStateMixin {
  final _scroll = ScrollController();
  bool _scrolled = false;

  late final AnimationController _leaves = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  late final AnimationController _clouds = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _leaves.stop();
      _clouds.stop();
    } else {
      if (!_leaves.isAnimating) _leaves.repeat(reverse: true);
      if (!_clouds.isAnimating) _clouds.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _leaves.dispose();
    _clouds.dispose();
    super.dispose();
  }

  void _scrollToCurrent(_MapLayout layout, double viewport, int current) {
    if (_scrolled) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = (layout.nodes[current].dy - viewport / 2).clamp(
        0.0,
        _scroll.position.maxScrollExtent,
      );
      _scroll.jumpTo(target);
    });
  }

  Future<void> _openLevel(StoryLevel level, int index) async {
    final state = context.read<AppState>();
    if (!state.isStoryUnlocked(level.id)) {
      showMessage(context, 'Finish the previous level to unlock this one.');
      return;
    }
    final start = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => _LevelSheet(level: level, number: index + 1),
    );
    if (start == true && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => StoryPlayerPage(level: level)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('PETA: Plant Adventure'),
        backgroundColor: const Color(0xFF85B4AB),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Gap.lg),
            child: Center(child: PointsPill(points: state.data.points)),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF85B4AB), Color(0xFF86B963)],
          ),
        ),
        child: Stack(
          children: [
            _MovingClouds(animation: _clouds),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = math.min(constraints.maxWidth, 520.0);
                final layout = _MapLayout(width);
                final current = state.currentStoryIndex;
                _scrollToCurrent(layout, constraints.maxHeight, current);
                return SingleChildScrollView(
                  controller: _scroll,
                  child: Center(
                    child: SizedBox(
                      width: width,
                      height: layout.height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(painter: _TrailPainter(layout)),
                          ),
                          for (var c = 0; c < storyChapters.length; c++)
                            Positioned(
                              left: Gap.lg,
                              right: Gap.lg,
                              top: layout.chapterTops[c],
                              height: _MapLayout.bannerHeight,
                              child: _ChapterBanner(
                                number: c + 1,
                                chapter: storyChapters[c],
                              ),
                            ),
                          for (var i = 0; i < storyLevels.length; i++)
                            Positioned(
                              left: layout.nodes[i].dx - 75,
                              top: layout.nodes[i].dy - 49,
                              width: 150,
                              child: _LevelBubble(
                                number: i + 1,
                                title: storyLevels[i].title,
                                stars: state.storyStars(storyLevels[i].id),
                                unlocked: state.isStoryUnlocked(
                                  storyLevels[i].id,
                                ),
                                isCurrent:
                                    i == current &&
                                    state.storyStars(storyLevels[i].id) == 0,
                                onTap: () => _openLevel(storyLevels[i], i),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            _SwayingLeaves(animation: _leaves, left: true),
            _SwayingLeaves(animation: _leaves, left: false),
          ],
        ),
      ),
    );
  }
}

/// The dotted brown trail of the original map.
class _TrailPainter extends CustomPainter {
  _TrailPainter(this.layout);

  final _MapLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (final (a, b) in layout.segments) {
      final midY = (a.dy + b.dy) / 2;
      path
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
    }
    final paint =
        Paint()
          ..color = const Color(0xFF5A402B).withValues(alpha: 0.7)
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    for (final ui.PathMetric metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 15) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) =>
      oldDelegate.layout.height != layout.height;
}

class _MovingClouds extends StatelessWidget {
  const _MovingClouds({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          SlideTransition(
            position: Tween(
              begin: const Offset(-0.5, 0),
              end: const Offset(1.5, 0),
            ).animate(animation),
            child: Align(
              alignment: const Alignment(-0.8, -0.75),
              child: Icon(
                Icons.cloud,
                color: Colors.white.withValues(alpha: 0.5),
                size: 100,
              ),
            ),
          ),
          SlideTransition(
            position: Tween(
              begin: const Offset(1.5, 0),
              end: const Offset(-0.5, 0),
            ).animate(
              CurvedAnimation(parent: animation, curve: const Interval(0.5, 1)),
            ),
            child: Align(
              alignment: const Alignment(0.8, -0.55),
              child: Icon(
                Icons.cloud_queue,
                color: Colors.white.withValues(alpha: 0.6),
                size: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Layered leaves in the bottom corners that sway in the wind.
class _SwayingLeaves extends StatelessWidget {
  const _SwayingLeaves({required this.animation, required this.left});

  final Animation<double> animation;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final sway = Tween(
      begin: left ? -0.2 : 0.2,
      end: left ? 0.2 : -0.2,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
    const layers = [
      (Color(0xFF2E7D32), 230.0, 0.6),
      (Color(0xFF43A047), 210.0, 0.8),
      (Color(0xFF65BA69), 190.0, 1.0),
    ];
    return Positioned(
      bottom: -40,
      left: left ? -70 : null,
      right: left ? null : -70,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: sway,
          builder:
              (context, _) => SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    for (final (color, size, speed) in layers)
                      Transform.rotate(
                        angle: sway.value * speed,
                        alignment: Alignment.bottomCenter,
                        child: Transform.flip(
                          flipX: !left,
                          child: Icon(Icons.eco, color: color, size: size),
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

/// The original round level bubble, with stars and a pulse on the next level.
class _LevelBubble extends StatefulWidget {
  const _LevelBubble({
    required this.number,
    required this.title,
    required this.stars,
    required this.unlocked,
    required this.isCurrent,
    required this.onTap,
  });

  final int number;
  final String title;
  final int stars;
  final bool unlocked;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  State<_LevelBubble> createState() => _LevelBubbleState();
}

class _LevelBubbleState extends State<_LevelBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(_LevelBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final animate =
        widget.isCurrent && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!animate && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = widget.unlocked;
    return Semantics(
      button: true,
      label:
          'Level ${widget.number}: ${widget.title}'
          '${unlocked ? '' : ', locked'}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.08).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 98,
                height: 98,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      widget.isCurrent
                          ? AppColors.sun
                          : unlocked
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.2),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        unlocked
                            ? const Color(0xFFC8E6C9)
                            : const Color(0xFFBDBDBD),
                    border: Border.all(
                      color:
                          unlocked
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF757575),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child:
                      unlocked
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Level ${widget.number}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: const Color(0xFF1B5E20),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Icon(
                                Icons.eco,
                                color: Color(0xFF4CAF50),
                                size: 28,
                              ),
                            ],
                          )
                          : const Icon(
                            Icons.lock,
                            color: Color(0xFF616161),
                            size: 36,
                          ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (widget.stars > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: StarRow(stars: widget.stars, size: 16),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: unlocked ? AppColors.ink : AppColors.inkMuted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChapterBanner extends StatelessWidget {
  const _ChapterBanner({required this.number, required this.chapter});

  final int number;
  final StoryChapter chapter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$number',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            // The sign has a fixed height so the trail can meet it, so large
            // text sizes shrink instead of overflowing.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapter.title, style: theme.textTheme.titleSmall),
                  Text(chapter.subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelSheet extends StatelessWidget {
  const _LevelSheet({required this.level, required this.number});

  final StoryLevel level;
  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stars = context.watch<AppState>().storyStars(level.id);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level $number', style: theme.textTheme.labelSmall),
            const SizedBox(height: 2),
            Text(level.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Gap.sm),
            Text(level.summary, style: theme.textTheme.bodyLarge),
            const SizedBox(height: Gap.lg),
            Row(
              children: [
                Tag(
                  '${level.questionCount} questions',
                  icon: Icons.quiz_outlined,
                ),
                const SizedBox(width: Gap.sm),
                if (stars > 0) StarRow(stars: stars, size: 20),
              ],
            ),
            const SizedBox(height: Gap.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(stars > 0 ? 'Play again' : 'Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
