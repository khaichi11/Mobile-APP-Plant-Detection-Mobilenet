import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'services/app_services.dart';
import 'state/app_state.dart';
import 'ui/art/logo_intro.dart';
import 'ui/auth/welcome_page.dart';
import 'ui/onboarding/onboarding_page.dart';
import 'ui/shell/main_shell.dart';

class PandaiApp extends StatefulWidget {
  const PandaiApp({
    super.key,
    required this.state,
    required this.services,
    this.home,
    this.intro = true,
  });

  final AppState state;
  final AppServices services;

  /// Replaces the normal start screen. Used by tests and screenshots.
  final Widget? home;

  /// Shows the logo opening when the app starts (off in widget tests).
  final bool intro;

  @override
  State<PandaiApp> createState() => _PandaiAppState();
}

class _PandaiAppState extends State<PandaiApp> {
  late bool _introDone = !widget.intro || widget.home != null;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.state),
        Provider.value(value: widget.services),
      ],
      child: MaterialApp(
        title: 'Pandai',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          child:
              _introDone
                  ? (widget.home ?? const RootGate())
                  : LogoIntro(onDone: () => setState(() => _introDone = true)),
        ),
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
