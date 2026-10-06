import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/lessons.dart';
import '../../state/app_state.dart';
import '../games/adventure/adventure_map_page.dart';
import '../games/memory/memory_levels_page.dart';
import '../games/plant_parts/plant_parts_page.dart';
import '../games/puzzle/puzzle_levels_page.dart';
import '../games/quiz/daily_quiz_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../learn/learn_page.dart';
import '../learn/lesson_page.dart';
import '../learn/video_card.dart';
import '../missions/mission_tile.dart';
import '../notifications/notifications_page.dart';
import '../shell/main_shell.dart';
import '../widgets/common.dart';
import '../widgets/images.dart';
import '../widgets/story_art_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<AppState, int>((s) => s.unreadNotifications);
    void open(Widget page) => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => open(const NotificationsPage()),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 9 ? '9+' : '$unread'),
              backgroundColor: AppColors.berry,
              child: const Icon(Icons.notifications_none_rounded, size: 28),
            ),
          ),
          const SizedBox(width: Gap.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Gap.lg,
          Gap.sm,
          Gap.lg,
          kNavBarClearance,
        ),
        children: [
          const _WelcomeCard(),
          const SizedBox(height: Gap.xl),
          SectionHeader(
            'Get to Know Plants!',
            actionLabel: 'See All',
            onAction: () => open(const LearnPage()),
          ),
          const _LearnCarousel(),
          const SizedBox(height: Gap.xl),
          ActionCard(
            icon: Icons.map_outlined,
            title: 'PETA (Plant Adventure)',
            subtitle: 'Join a fun adventure in the world of plants',
            onTap: () => open(const AdventureMapPage()),
          ),
          ActionCard(
            icon: Icons.extension_outlined,
            title: 'Plant Puzzle',
            subtitle: 'Sharpen your mind by rearranging plant pictures',
            onTap: () => open(const PuzzleLevelsPage()),
          ),
          ActionCard(
            icon: Icons.style_outlined,
            title: 'Memory Match',
            subtitle: 'Find the pairs and learn plant names',
            onTap: () => open(const MemoryLevelsPage()),
          ),
          ActionCard(
            icon: Icons.yard_outlined,
            title: 'Build a Plant',
            subtitle: 'Label the parts of a plant and what they do',
            onTap: () => open(const PlantPartsPage()),
          ),
          ActionCard(
            icon: Icons.quiz_outlined,
            title: 'Daily Quiz',
            subtitle: 'Five new plant questions every day',
            onTap: () => open(const DailyQuizPage()),
          ),
          const SizedBox(height: Gap.lg),
          const SectionHeader('Today\'s missions'),
          const MissionsCard(),
          const SizedBox(height: Gap.xl),
          const _ScrollHint(),
          const SizedBox(height: Gap.lg),
          SectionHeader(
            'Leaderboard',
            actionLabel: 'See All',
            onAction: () => open(const LeaderboardPage()),
          ),
          const _HomeLeaderboard(),
        ],
      ),
    );
  }
}

/// The original greeting card, with the player's points and progress.
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final rank = state.rank;
    final next = rank.next;
    final muted = Colors.white.withValues(alpha: 0.8);

    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(Radii.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: UserAvatar(user: state.user, radius: 25),
              ),
              const SizedBox(width: Gap.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello!',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      state.user?.name ?? 'Explorer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Ready to find a new plant today?',
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${state.data.points}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'points',
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const Spacer(),
              Flexible(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Lv ${rank.level} · ${rank.rank.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rank.progress,
              minHeight: 8,
              color: AppColors.sun,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next == null
                ? 'You reached the highest rank. Amazing!'
                : '${rank.pointsToNext} points to ${next.title}',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              _Stat(
                icon: Icons.local_fire_department_rounded,
                value: '${state.data.streak}',
                label: 'day streak',
              ),
              _Stat(
                icon: Icons.local_florist_rounded,
                value: '${state.data.collection.length}',
                label: 'plants found',
                onTap:
                    () => MainShell.of(context)?.openTab(ShellTab.collection),
              ),
              _Stat(
                icon: Icons.military_tech_rounded,
                value: '${state.data.badges.length}',
                label: 'badges',
                onTap: () => MainShell.of(context)?.openTab(ShellTab.profile),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.sun),
              const SizedBox(width: 6),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The original "Get to Know Plants!" carousel: videos, then lessons.
class _LearnCarousel extends StatefulWidget {
  const _LearnCarousel();

  @override
  State<_LearnCarousel> createState() => _LearnCarouselState();
}

class _LearnCarouselState extends State<_LearnCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featured = lessons.take(3).toList();
    final count = learningVideos.length + featured.length;
    final theme = Theme.of(context);
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: count,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final Widget child;
              if (index < learningVideos.length) {
                child = VideoCard(video: learningVideos[index]);
              } else {
                final lesson = featured[index - learningVideos.length];
                child = GestureDetector(
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LessonPage(lesson: lesson),
                        ),
                      ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Radii.md),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        StoryArtView(lesson.art, radius: 0),
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
                          left: Gap.md,
                          right: Gap.md,
                          bottom: Gap.md,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${lesson.minutes} min read',
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
              return Padding(
                padding: const EdgeInsets.only(right: Gap.sm),
                child: child,
              );
            },
          ),
        ),
        const SizedBox(height: Gap.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                height: 6,
                width: i == _page ? 20 : 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.leaf : AppColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The original game buttons from the prototype home screen.
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Material(
        color: AppColors.mint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: AppColors.forest.withValues(alpha: 0.22)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Gap.lg),
            child: Row(
              children: [
                Icon(icon, size: 36, color: AppColors.forest),
                const SizedBox(width: Gap.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScrollHint extends StatefulWidget {
  const _ScrollHint();

  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _bounce.stop();
    } else if (!_bounce.isAnimating) {
      _bounce.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Swipe down to see the leaderboard',
          style: theme.textTheme.bodySmall,
        ),
        SlideTransition(
          position: Tween(
            begin: Offset.zero,
            end: const Offset(0, 0.25),
          ).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeInOut)),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.inkMuted,
          ),
        ),
      ],
    );
  }
}

class _HomeLeaderboard extends StatelessWidget {
  const _HomeLeaderboard();

  @override
  Widget build(BuildContext context) {
    return LeaderboardBuilder(
      builder: (context, entries) {
        if (entries == null) return const SizedBox(height: 200);
        return Column(
          children: [
            const SizedBox(height: Gap.sm),
            LeaderboardPodium(entries.take(3).toList()),
            const SizedBox(height: Gap.lg),
            Card(
              child: Column(
                children: [
                  for (final entry in entries.skip(3)) LeaderboardRow(entry),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
