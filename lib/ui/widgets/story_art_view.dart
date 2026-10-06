import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/story.dart';
import '../art/scene_painter.dart';
import 'images.dart';

/// Shows a drawn scene or a plant photo for a story step, lesson or quiz.
class StoryArtView extends StatelessWidget {
  const StoryArtView(this.art, {super.key, this.radius = Radii.md});

  final StoryArt art;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return switch (art) {
      SceneArt(:final scene) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedScene(scene),
      ),
      PhotoArt(:final plantId) => PlantPhoto(plantId, radius: radius),
      IllustrationArt(:final asset) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: LayoutBuilder(
          builder:
              (context, constraints) => Image.asset(
                asset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                cacheWidth:
                    constraints.hasBoundedWidth
                        ? (constraints.maxWidth *
                                MediaQuery.devicePixelRatioOf(context))
                            .round()
                        : null,
              ),
        ),
      ),
    };
  }
}

/// Loops the scene animation, unless the system asks for reduced motion.
class AnimatedScene extends StatefulWidget {
  const AnimatedScene(this.scene, {super.key});

  final StoryScene scene;

  @override
  State<AnimatedScene> createState() => _AnimatedSceneState();
}

class _AnimatedSceneState extends State<AnimatedScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder:
            (context, _) => CustomPaint(
              painter: ScenePainter(widget.scene, _controller.value),
              size: Size.infinite,
            ),
      ),
    );
  }
}
