import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../widgets/common.dart';

enum LevelCompleteAction { next, replay, close }

/// Bottom sheet shown after a level: stars, points and what to do next.
Future<LevelCompleteAction> showLevelComplete(
  BuildContext context, {
  required String title,
  required int stars,
  required int points,
  String? message,
  List<(IconData, String)> stats = const [],
  bool hasNext = false,
  String nextLabel = 'Next level',
}) async {
  final action = await showModalBottomSheet<LevelCompleteAction>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (context) {
      final theme = Theme.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StarRow(stars: stars, size: 44),
              const SizedBox(height: Gap.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              if (message != null) ...[
                const SizedBox(height: Gap.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
              const SizedBox(height: Gap.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Gap.sm,
                runSpacing: Gap.sm,
                children: [
                  if (points > 0)
                    PointsPill(points: points)
                  else
                    const Tag('No new points', color: AppColors.background),
                  for (final (icon, label) in stats)
                    Tag(
                      label,
                      icon: icon,
                      color: AppColors.background,
                      foreground: AppColors.ink,
                    ),
                ],
              ),
              const SizedBox(height: Gap.xl),
              if (hasNext) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        () =>
                            Navigator.of(context).pop(LevelCompleteAction.next),
                    child: Text(nextLabel),
                  ),
                ),
                const SizedBox(height: Gap.sm),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          () => Navigator.of(
                            context,
                          ).pop(LevelCompleteAction.replay),
                      child: const Text('Play again'),
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  Expanded(
                    child:
                        hasNext
                            ? OutlinedButton(
                              onPressed:
                                  () => Navigator.of(
                                    context,
                                  ).pop(LevelCompleteAction.close),
                              child: const Text('Done'),
                            )
                            : FilledButton(
                              onPressed:
                                  () => Navigator.of(
                                    context,
                                  ).pop(LevelCompleteAction.close),
                              child: const Text('Done'),
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return action ?? LevelCompleteAction.close;
}

/// Asks before leaving a game that is in progress.
Future<bool> confirmLeaveGame(BuildContext context) async {
  final leave = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Leave this game?'),
          content: const Text('Your progress in this level will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep playing'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave'),
            ),
          ],
        ),
  );
  return leave ?? false;
}
