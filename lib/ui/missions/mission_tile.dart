import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/mission.dart';
import '../../state/app_state.dart';
import '../widgets/common.dart';

IconData missionIcon(GameEvent event) => switch (event) {
  GameEvent.scan => Icons.center_focus_strong_rounded,
  GameEvent.newSpecies => Icons.local_florist_rounded,
  GameEvent.storyLevel => Icons.map_rounded,
  GameEvent.puzzle => Icons.extension_rounded,
  GameEvent.memory => Icons.style_rounded,
  GameEvent.plantParts => Icons.yard_rounded,
  GameEvent.dailyQuiz => Icons.quiz_rounded,
  GameEvent.lesson => Icons.menu_book_rounded,
};

class MissionTile extends StatelessWidget {
  const MissionTile({super.key, required this.mission});

  final Mission mission;

  Future<void> _claim(BuildContext context) async {
    final reward = await context.read<AppState>().claimMission(mission.id);
    if (reward > 0 && context.mounted) {
      showMessage(context, 'Mission reward: +$reward points');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final progress = state.missionProgress(mission);
    final complete = state.isMissionComplete(mission);
    final claimed = state.isMissionClaimed(mission);

    final Widget trailing;
    if (claimed) {
      trailing = const Icon(
        Icons.check_circle_rounded,
        color: AppColors.leaf,
        semanticLabel: 'Claimed',
      );
    } else if (complete) {
      trailing = FilledButton(
        onPressed: () => _claim(context),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor: AppColors.sun,
          foregroundColor: AppColors.ink,
        ),
        child: Text('+${mission.reward}'),
      );
    } else {
      trailing = Text(
        '$progress/${mission.target}',
        style: theme.textTheme.labelMedium?.copyWith(color: AppColors.inkMuted),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.sm),
      child: Row(
        children: [
          IconTile(
            icon: missionIcon(mission.event),
            size: 42,
            color: mission.isOutdoor ? AppColors.sunSoft : AppColors.mint,
            foreground:
                mission.isOutdoor ? const Color(0xFFB7791F) : AppColors.forest,
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        mission.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          decoration:
                              claimed ? TextDecoration.lineThrough : null,
                          color: claimed ? AppColors.inkMuted : null,
                        ),
                      ),
                    ),
                    if (mission.isOutdoor) ...[
                      const SizedBox(width: 6),
                      const Tag(
                        'Outdoor',
                        color: AppColors.sunSoft,
                        foreground: Color(0xFF8A5A0E),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(mission.description, style: theme.textTheme.bodySmall),
                if (!complete) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / mission.target,
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: Gap.md),
          trailing,
        ],
      ),
    );
  }
}

class MissionsCard extends StatelessWidget {
  const MissionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final missions = context.watch<AppState>().todaysMissions;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.sm),
        child: Column(
          children: [
            for (var i = 0; i < missions.length; i++) ...[
              if (i > 0) const Divider(),
              MissionTile(mission: missions[i]),
            ],
          ],
        ),
      ),
    );
  }
}
