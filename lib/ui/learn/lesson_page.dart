import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/lesson.dart';
import '../../state/app_state.dart';
import '../widgets/story_art_view.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  bool _done = false;

  Future<void> _finish() async {
    await context.read<AppState>().markLessonRead(widget.lesson.id);
    if (!mounted) return;
    setState(() => _done = true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lesson = widget.lesson;
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: StoryArtView(lesson.art, radius: Radii.lg),
          ),
          const SizedBox(height: Gap.xl),
          Text(lesson.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: Gap.xs),
          Text(
            lesson.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: Gap.xl),
          for (var i = 0; i < lesson.sections.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.forestDark,
                    ),
                  ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.sections[i].heading,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: Gap.xs),
                      Text(
                        lesson.sections[i].body,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.xl),
          ],
          FilledButton.icon(
            onPressed: _done ? null : _finish,
            icon: const Icon(Icons.check_rounded),
            label: const Text('I read it'),
          ),
        ],
      ),
    );
  }
}
