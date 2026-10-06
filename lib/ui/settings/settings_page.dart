import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../profile/edit_profile_page.dart';
import 'about_page.dart';
import 'credits_page.dart';
import 'legal_page.dart';

const appVersion = '1.0.0';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    final state = context.read<AppState>();
    final guest = state.user?.isGuest ?? false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign out?'),
            content: Text(
              guest
                  ? 'You are exploring as a guest. Signing out deletes your points, '
                      'badges and herbarium.'
                  : 'Your progress stays saved on this device. Sign in again to '
                      'continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style:
                    guest
                        ? FilledButton.styleFrom(
                          backgroundColor: AppColors.berry,
                        )
                        : null,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sign out'),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    await state.signOut();
  }

  Future<void> _reset(BuildContext context) async {
    final state = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset all progress?'),
            content: const Text(
              'This deletes your points, stars, badges and herbarium photos. It '
              'cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.berry),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    await state.resetProgress();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress reset. A fresh start!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    void open(Widget page) => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(top: Gap.sm, bottom: kNavBarClearance),
        children: [
          const _Header('Account'),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit profile'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => open(const EditProfilePage()),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign out'),
            onTap: () => _signOut(context),
          ),
          const _Header('Data'),
          ListTile(
            leading: const Icon(
              Icons.restart_alt_rounded,
              color: AppColors.berry,
            ),
            title: Text(
              'Reset progress',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.berry,
              ),
            ),
            subtitle: const Text('Start again from zero points'),
            onTap: () => _reset(context),
          ),
          const _Header('About'),
          ListTile(
            leading: const Icon(Icons.eco_outlined),
            title: const Text('About Pandai'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => open(const AboutPage()),
          ),
          ListTile(
            leading: const Icon(Icons.copyright_outlined),
            title: const Text('Credits and licenses'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => open(const CreditsPage()),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy policy'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => open(const LegalPage.privacy()),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of use'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => open(const LegalPage.terms()),
          ),
          Padding(
            padding: const EdgeInsets.all(Gap.xl),
            child: Text(
              'Pandai $appVersion · Made by Team Terang Bulan',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.xs),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
