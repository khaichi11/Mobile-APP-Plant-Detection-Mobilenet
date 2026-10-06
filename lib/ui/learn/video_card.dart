import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme.dart';

class LearningVideo {
  const LearningVideo({
    required this.asset,
    required this.cover,
    required this.title,
    required this.subtitle,
  });

  final String asset;
  final String cover;
  final String title;
  final String subtitle;
}

/// Videos made by Team Terang Bulan.
const learningVideos = [
  LearningVideo(
    asset: 'assets/videos/growing_carrots_part1.mp4',
    cover: 'assets/images/story/video_cover.jpg',
    title: 'Part 1: Growing carrots',
    subtitle: 'Learn how to plant and care for carrots',
  ),
];

/// Shows the cover first and starts the player only when tapped, so the
/// home screen stays light.
class VideoCard extends StatefulWidget {
  const VideoCard({super.key, required this.video, this.radius = Radii.md});

  final LearningVideo video;
  final double radius;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  VideoPlayerController? _video;
  ChewieController? _chewie;
  bool _loading = false;
  bool _failed = false;

  Future<void> _play() async {
    if (_loading) return;
    setState(() => _loading = true);
    final video = VideoPlayerController.asset(widget.video.asset);
    try {
      await video.initialize();
      if (!mounted) {
        await video.dispose();
        return;
      }
      setState(() {
        _video = video;
        _chewie = ChewieController(
          videoPlayerController: video,
          autoPlay: true,
          aspectRatio: video.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.leaf,
            handleColor: AppColors.leaf,
          ),
        );
      });
    } catch (_) {
      await video.dispose();
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chewie = _chewie;
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: ColoredBox(
        color: Colors.black,
        child:
            chewie != null
                ? Chewie(controller: chewie)
                : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(widget.video.cover, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xAA000000)],
                          stops: [0.45, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      right: Gap.md,
                      bottom: Gap.md,
                      child: Semantics(
                        button: true,
                        label: 'Play video: ${widget.video.title}',
                        child: InkWell(
                          onTap: _failed ? null : _play,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                            ),
                            child:
                                _loading
                                    ? const Padding(
                                      padding: EdgeInsets.all(18),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    )
                                    : Icon(
                                      _failed
                                          ? Icons.videocam_off_outlined
                                          : Icons.play_arrow_rounded,
                                      size: 32,
                                      color: AppColors.forest,
                                    ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: Gap.md,
                      right: 76,
                      bottom: Gap.md,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _failed
                                ? 'This video cannot play on this device.'
                                : widget.video.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
