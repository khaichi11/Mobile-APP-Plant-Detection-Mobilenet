import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/lessons.dart';
import '../../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/story_art_view.dart';
import 'lesson_page.dart';
import 'video_card.dart';

/// "Get to Know Plants!": every video and lesson.
class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final read = context.watch<AppState>().data.lessonsRead;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Get to Know Plants!')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
        children: [
          const SectionHeader('Videos'),
          for (final video in learningVideos) ...[
            AspectRatio(aspectRatio: 16 / 9, child: VideoCard(video: video)),
            const SizedBox(height: Gap.md),
          ],
          const SizedBox(height: Gap.md),
          const SectionHeader('Lessons'),
          for (final lesson in lessons)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: TapCard(
                padding: EdgeInsets.zero,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LessonPage(lesson: lesson),
                      ),
                    ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      height: 96,
                      child: StoryArtView(lesson.art, radius: 0),
                    ),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lesson.title, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            lesson.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            read.contains(lesson.id)
                                ? 'Read'
                                : '${lesson.minutes} min read',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color:
                                  read.contains(lesson.id)
                                      ? AppColors.leaf
                                      : AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Gap.md),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
