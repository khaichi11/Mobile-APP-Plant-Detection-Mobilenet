import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../data/game_levels.dart';
import '../../../state/app_state.dart';
import '../../widgets/common.dart';
import 'puzzle_page.dart';

/// The original "Choose a Puzzle" grid.
class PuzzleLevelsPage extends StatelessWidget {
  const PuzzleLevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Puzzle'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Gap.lg),
            child: Center(child: PointsPill(points: state.data.points)),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(Gap.lg),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: Gap.lg,
          crossAxisSpacing: Gap.lg,
          childAspectRatio: 0.86,
        ),
        itemCount: puzzleLevels.length,
        itemBuilder: (context, index) {
          final level = puzzleLevels[index];
          final unlocked = state.isPuzzleUnlocked(level.number);
          final stars = state.data.puzzleStars[level.number] ?? 0;
          return Material(
            color: unlocked ? AppColors.mint : AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.md),
              side: BorderSide(
                color: unlocked ? AppColors.leaf : AppColors.line,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap:
                  unlocked
                      ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PuzzlePage(level: level),
                        ),
                      )
                      : () => showMessage(
                        context,
                        'Solve puzzle ${level.number - 1} to unlock this one.',
                      ),
              child:
                  unlocked
                      ? Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      level.imageAsset,
                                      fit: BoxFit.cover,
                                      cacheWidth: 400,
                                    ),
                                    Container(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    Center(
                                      child:
                                          stars > 0
                                              ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.45),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: StarRow(
                                                  stars: stars,
                                                  size: 20,
                                                ),
                                              )
                                              : Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.8),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Let\'s Play',
                                                  style: theme
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(Gap.sm),
                            child: Text(
                              'Level ${level.number}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.forestDark,
                              ),
                            ),
                          ),
                        ],
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            color: AppColors.inkMuted,
                            size: 44,
                          ),
                          const SizedBox(height: Gap.sm),
                          Text(
                            'Level ${level.number}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
            ),
          );
        },
      ),
    );
  }
}
