import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/story.dart';
import '../../state/app_state.dart';
import '../art/logo.dart';
import '../widgets/story_art_view.dart';

class _Slide {
  const _Slide(this.art, this.title, this.body);
  final StoryArt art;
  final String title;
  final String body;
}

const _slides = [
  _Slide(
    SceneArt(StoryScene.forest),
    'Plants are all around you',
    'Pandai helps you notice, name and love the plants you walk past every '
        'day.',
  ),
  _Slide(
    PhotoArt('hibiscus'),
    'Scan plants outside',
    'Point your camera at a leaf or flower. Pandai\'s on-device AI tells you '
        'what it is, even without internet.',
  ),
  _Slide(
    SceneArt(StoryScene.seedSprouting),
    'Play, learn and grow',
    'Go on the PETA adventure, solve puzzles, complete missions and fill your '
        'own herbarium.',
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _slides.length - 1) {
      context.read<AppState>().completeOnboarding();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.sm, 0),
              child: Row(
                children: [
                  const PandaiLogo(size: 32),
                  const SizedBox(width: Gap.sm),
                  Text(
                    'PANDAI',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.brandEmerald,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Visibility(
                    visible: !last,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed:
                          () => context.read<AppState>().completeOnboarding(),
                      child: const Text('Skip'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: StoryArtView(slide.art, radius: Radii.lg),
                            ),
                          ),
                        ),
                        const SizedBox(height: Gap.xl),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: Gap.md),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Gap.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.forest : AppColors.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(Gap.xl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(last ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
