import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'services/app_services.dart';
import 'state/app_state.dart';
import 'ui/auth/welcome_page.dart';
import 'ui/onboarding/onboarding_page.dart';
import 'ui/shell/main_shell.dart';

class PandaiApp extends StatelessWidget {
  const PandaiApp({
    super.key,
    required this.state,
    required this.services,
    this.home,
  });

  final AppState state;
  final AppServices services;

  /// Replaces the normal start screen. Used by tests and screenshots.
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: state),
        Provider.value(value: services),
      ],
      child: MaterialApp(
        title: 'Pandai',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: home ?? const RootGate(),
      ),
    );
  }
}

/// Picks the first screen: onboarding, sign in, or the app itself.
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.onboardingDone) return const OnboardingPage();
    if (!state.isSignedIn) return const WelcomePage();
    return const MainShell();
  }
}
