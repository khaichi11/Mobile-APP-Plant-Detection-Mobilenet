import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../data/game_levels.dart';
import '../../../models/game_levels.dart';
import '../../../state/app_state.dart';
import '../../widgets/common.dart';
import 'memory_game_page.dart';

class MemoryLevelsPage extends StatelessWidget {
  const MemoryLevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Gap.lg),
            child: Center(child: PointsPill(points: state.data.points)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(Gap.lg),
        itemCount: memoryLevels.length,
        separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
        itemBuilder: (context, index) {
          final level = memoryLevels[index];
          final unlocked = state.isMemoryUnlocked(level.number);
          final stars = state.data.memoryStars[level.number] ?? 0;
          final names = level.mode == MemoryMode.photoToName;
          return TapCard(
            onTap:
                unlocked
                    ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MemoryGamePage(level: level),
                      ),
                    )
                    : () => showMessage(
                      context,
                      'Finish level ${level.number - 1} to unlock this one.',
                    ),
            child: Row(
              children: [
                IconTile(
                  icon:
                      unlocked
                          ? (names
                              ? Icons.text_fields_rounded
                              : Icons.photo_rounded)
                          : Icons.lock_rounded,
                  color: unlocked ? AppColors.berrySoft : AppColors.background,
                  foreground: unlocked ? AppColors.berry : AppColors.inkMuted,
                ),
                const SizedBox(width: Gap.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${level.number}',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        '${level.pairs} pairs · '
                        '${names ? 'Match the photo with its name' : 'Match two photos'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (stars > 0) StarRow(stars: stars),
              ],
            ),
          );
        },
      ),
    );
  }
}
