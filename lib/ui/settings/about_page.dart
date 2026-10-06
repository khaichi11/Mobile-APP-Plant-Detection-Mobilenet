import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../art/logo.dart';
import '../widgets/common.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Pandai')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
        children: [
          const Center(child: PandaiWordmark(markSize: 104)),
          const SizedBox(height: Gap.lg),
          Text(
            'Learn plants. Play outside.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: Gap.xl),
          const _Block(
            title: 'Why Pandai?',
            body:
                'Many children walk past plants every day without noticing '
                'them. Scientists call this plant blindness. School science '
                'often talks more about animals than plants, and city children '
                'spend less time in nature. Pandai turns learning about plants '
                'into an outdoor game.',
          ),
          const _Block(
            title: 'How it works',
            body:
                'Scan plants with on-device AI image classification, then '
                'save them to your herbarium. Learn through the PETA story '
                'adventure, plant puzzles, memory games, Build a Plant and a '
                'daily quiz. Missions, points, streaks and badges keep you '
                'exploring.',
          ),
          const SizedBox(height: Gap.sm),
          Text('Our goals', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.md),
          const _GoalCard(
            number: '4',
            title: 'Quality Education',
            body:
                'Fun, inclusive science learning for every elementary school '
                'student.',
            color: Color(0xFFC5192D),
          ),
          const SizedBox(height: Gap.md),
          const _GoalCard(
            number: '15',
            title: 'Life on Land',
            body:
                'Children who know plants grow up caring for forests and '
                'nature.',
            color: Color(0xFF56C02B),
          ),
          const SizedBox(height: Gap.xl),
          const NoticeBox(
            icon: Icons.groups_rounded,
            title: 'Made by Team Terang Bulan',
            text:
                'Built with Flutter. Plant identification runs fully on the '
                'phone with TensorFlow Lite, so it also works offline.',
            color: AppColors.mint,
            iconColor: AppColors.forest,
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.xs),
          Text(body, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.number,
    required this.title,
    required this.body,
    required this.color,
  });

  final String number;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.lg),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                number,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: Gap.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SDG $number · $title',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(body, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
