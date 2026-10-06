import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../collection/herbarium_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../scanner/scanner_page.dart';
import '../settings/settings_page.dart';

enum ShellTab { home, settings, collection, profile }

/// The original Pandai layout: four tabs in a floating bar with the big
/// camera button in the middle.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// Lets screens inside the shell switch tabs.
  static MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  ShellTab _tab = ShellTab.home;

  void openTab(ShellTab tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _tab.index,
        children: const [
          HomePage(),
          SettingsPage(),
          HerbariumPage(),
          ProfilePage(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 14),
        child: SizedBox.square(
          dimension: 70,
          child: FloatingActionButton(
            tooltip: 'Scan a plant',
            heroTag: 'scan',
            onPressed: () => openScanner(context),
            backgroundColor: AppColors.forest,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.camera_alt_rounded, size: 34),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.sm, 0, Gap.sm, Gap.sm),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  selected: _tab == ShellTab.home,
                  onTap: () => openTab(ShellTab.home),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: 'Settings',
                  selected: _tab == ShellTab.settings,
                  onTap: () => openTab(ShellTab.settings),
                ),
                const SizedBox(width: 84),
                _NavItem(
                  icon: Icons.collections_bookmark_outlined,
                  selectedIcon: Icons.collections_bookmark_rounded,
                  label: 'Collection',
                  selected: _tab == ShellTab.collection,
                  onTap: () => openTab(ShellTab.collection),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  selected: _tab == ShellTab.profile,
                  onTap: () => openTab(ShellTab.profile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.forest : AppColors.inkMuted;
    return Expanded(
      key: ValueKey('nav-$label'),
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, size: 28, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
