import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/app_services.dart';
import '../../services/leaderboard_repository.dart';
import '../../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/images.dart';

/// Loads the ranking and reloads it when the player's points or name change.
class LeaderboardBuilder extends StatefulWidget {
  const LeaderboardBuilder({super.key, required this.builder});

  final Widget Function(BuildContext, List<LeaderboardEntry>?) builder;

  @override
  State<LeaderboardBuilder> createState() => _LeaderboardBuilderState();
}

class _LeaderboardBuilderState extends State<LeaderboardBuilder> {
  Future<List<LeaderboardEntry>>? _future;
  (int, String)? _loadedFor;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return widget.builder(context, null);
    final key = (state.data.points, user.name);
    if (_future == null || _loadedFor != key) {
      _loadedFor = key;
      _future = context.read<AppServices>().leaderboard.fetch(
        me: user,
        myPoints: state.data.points,
      );
    }
    return FutureBuilder<List<LeaderboardEntry>>(
      future: _future,
      builder: (context, snapshot) => widget.builder(context, snapshot.data),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDemo = context.read<AppServices>().leaderboard.isDemo;
    return Scaffold(
      appBar: AppBar(title: const Text('Class ranking')),
      body: LeaderboardBuilder(
        builder: (context, entries) {
          if (entries == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xl),
            children: [
              if (isDemo)
                const Padding(
                  padding: EdgeInsets.only(bottom: Gap.lg),
                  child: NoticeBox(
                    icon: Icons.info_outline_rounded,
                    text:
                        'These classmates are sample players. Your own '
                        'points are real and grow as you play.',
                    color: AppColors.skySoft,
                    iconColor: Color(0xFF2F7FA6),
                  ),
                ),
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
      ),
    );
  }
}

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium(this.top, {super.key});

  final List<LeaderboardEntry> top;

  @override
  Widget build(BuildContext context) {
    if (top.length < 3) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _PodiumColumn(top[1], height: 84)),
        const SizedBox(width: Gap.sm),
        Expanded(child: _PodiumColumn(top[0], height: 112)),
        const SizedBox(width: Gap.sm),
        Expanded(child: _PodiumColumn(top[2], height: 64)),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn(this.entry, {required this.height});

  final LeaderboardEntry entry;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<AppState>().user;
    final medal = switch (entry.rank) {
      1 => const Color(0xFFF2B33D),
      2 => const Color(0xFFB8C2C8),
      _ => const Color(0xFFD49A6A),
    };
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: medal, shape: BoxShape.circle),
          child:
              entry.isMe
                  ? UserAvatar(user: user, radius: 26)
                  : CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.surface,
                    child: Text(
                      entry.name.characters.first,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
        ),
        const SizedBox(height: Gap.sm),
        Text(
          entry.isMe ? 'You' : entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall,
        ),
        Text('${entry.points} pts', style: theme.textTheme.bodySmall),
        const SizedBox(height: Gap.sm),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: entry.isMe ? AppColors.forest : AppColors.mint,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          alignment: Alignment.center,
          child: Text(
            '${entry.rank}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: entry.isMe ? Colors.white : AppColors.forestDark,
            ),
          ),
        ),
      ],
    );
  }
}

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow(this.entry, {super.key});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<AppState>().user;
    return Container(
      color: entry.isMe ? AppColors.mint : null,
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${entry.rank}', style: theme.textTheme.titleSmall),
          ),
          entry.isMe
              ? UserAvatar(user: user, radius: 18)
              : CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.background,
                child: Text(
                  entry.name.characters.first,
                  style: theme.textTheme.titleSmall,
                ),
              ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(
              entry.isMe ? '${entry.name} (you)' : entry.name,
              style: theme.textTheme.titleSmall,
            ),
          ),
          PointsPill(points: entry.points, compact: true),
        ],
      ),
    );
  }
}
