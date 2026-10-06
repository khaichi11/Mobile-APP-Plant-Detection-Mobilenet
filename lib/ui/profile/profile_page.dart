import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/missions.dart';
import '../../data/plant_catalog.dart';
import '../../data/story_levels.dart';
import '../../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/images.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _changePhoto(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from photos'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                const SizedBox(height: Gap.sm),
              ],
            ),
          ),
    );
    if (source == null || !context.mounted) return;
    final state = context.read<AppState>();
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.front,
      );
      if (picked == null) return;
      await state.updateProfile(avatarSourcePath: picked.path);
    } on PlatformException {
      if (context.mounted) {
        showMessage(context, 'Could not open the camera or photos.');
      }
    } catch (_) {
      if (context.mounted) showMessage(context, 'Could not save the photo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final user = state.user;
    final data = state.data;
    final rank = state.rank;
    final guideFound =
        plantCatalog.where((p) => state.hasSpecies(p.scientificName)).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Gap.lg,
          Gap.lg,
          Gap.lg,
          kNavBarClearance,
        ),
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.leaf,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: UserAvatar(user: user, radius: 54),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      tooltip: 'Change photo',
                      onPressed: () => _changePhoto(context),
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.forest,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          Text(
            user?.name ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          Text(
            [
              'Grade ${user?.grade ?? '-'}',
              if (user?.isGuest ?? false)
                'Guest explorer'
              else
                user?.email ?? '',
            ].join(' · '),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: Gap.md),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${data.points} Points',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.forestDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.md),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EditProfilePage(),
                    ),
                  ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit profile'),
            ),
          ),
          const SizedBox(height: Gap.xl),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Gap.lg),
              child: Row(
                children: [
                  const Icon(
                    Icons.sports_esports_rounded,
                    color: AppColors.forest,
                    size: 30,
                  ),
                  const SizedBox(width: Gap.lg),
                  Expanded(
                    child: Text(
                      'Climb the leaderboard by finishing the games!',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gap.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Gap.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Level ${rank.level}',
                        style: theme.textTheme.labelSmall,
                      ),
                      const Spacer(),
                      PointsPill(points: data.points, compact: true),
                    ],
                  ),
                  Text(rank.rank.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: Gap.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rank.progress,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rank.next == null
                        ? 'Highest rank reached'
                        : '${rank.pointsToNext} points to ${rank.next!.title}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gap.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Gap.md,
            crossAxisSpacing: Gap.md,
            childAspectRatio: 1.9,
            children: [
              _StatTile(
                icon: Icons.local_florist_rounded,
                value: '${data.collection.length}',
                label: 'Plants found',
              ),
              _StatTile(
                icon: Icons.menu_book_rounded,
                value: '$guideFound/${plantCatalog.length}',
                label: 'Guide plants',
              ),
              _StatTile(
                icon: Icons.map_rounded,
                value: '${data.storyStars.length}/${storyLevels.length}',
                label: 'Levels done',
              ),
              _StatTile(
                icon: Icons.local_fire_department_rounded,
                value: '${data.bestStreak}',
                label: 'Best streak',
              ),
            ],
          ),
          const SizedBox(height: Gap.xl),
          SectionHeader('Badges  ${data.badges.length}/${badges.length}'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              mainAxisSpacing: Gap.md,
              crossAxisSpacing: Gap.md,
              childAspectRatio: 0.82,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              final earned = data.badges.contains(badge.id);
              return Tooltip(
                message: badge.description,
                triggerMode: TooltipTriggerMode.tap,
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            earned ? AppColors.sunSoft : AppColors.background,
                        border: Border.all(
                          color: earned ? AppColors.sun : AppColors.line,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        earned
                            ? Icons.military_tech_rounded
                            : Icons.lock_outline_rounded,
                        color:
                            earned
                                ? const Color(0xFFB7791F)
                                : AppColors.inkMuted,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(
                      badge.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: earned ? AppColors.ink : AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.md),
        child: Row(
          children: [
            IconTile(icon: icon, size: 40),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: theme.textTheme.titleMedium),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
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
