import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../models/app_notification.dart';
import '../../state/app_state.dart';
import '../widgets/common.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static (IconData, Color, Color) _style(NotificationKind kind) =>
      switch (kind) {
        NotificationKind.badge => (
          Icons.military_tech_rounded,
          AppColors.sunSoft,
          const Color(0xFFB7791F),
        ),
        NotificationKind.unlock => (
          Icons.lock_open_rounded,
          AppColors.skySoft,
          const Color(0xFF2F7FA6),
        ),
        NotificationKind.mission => (
          Icons.flag_rounded,
          AppColors.mint,
          AppColors.forest,
        ),
        NotificationKind.discovery => (
          Icons.local_florist_rounded,
          AppColors.mint,
          AppColors.forest,
        ),
        NotificationKind.info => (
          Icons.waving_hand_rounded,
          AppColors.berrySoft,
          AppColors.berry,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final items = state.data.notifications;
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadNotifications > 0)
            TextButton(
              onPressed: state.markAllNotificationsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body:
          items.isEmpty
              ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications yet',
                message:
                    'Badges, unlocked levels and finished missions show '
                    'up here.',
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(indent: 76),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final (icon, bg, fg) = _style(item.kind);
                  return ListTile(
                    onTap:
                        item.read
                            ? null
                            : () => state.markNotificationRead(item.id),
                    leading: IconTile(
                      icon: icon,
                      color: bg,
                      foreground: fg,
                      size: 44,
                    ),
                    title: Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            item.read ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${item.body}\n${timeAgo(item.createdAt, now)}',
                      ),
                    ),
                    isThreeLine: true,
                    trailing:
                        item.read
                            ? null
                            : Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.berry,
                                shape: BoxShape.circle,
                              ),
                            ),
                  );
                },
              ),
    );
  }
}
