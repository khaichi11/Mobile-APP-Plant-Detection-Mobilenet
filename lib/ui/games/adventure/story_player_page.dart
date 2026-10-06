import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../data/story_levels.dart';
import '../../../games/quiz_builder.dart';
import '../../../models/story.dart';
import '../../../state/app_state.dart';
import '../../../state/game_rules.dart';
import '../../widgets/common.dart';
import '../../widgets/story_art_view.dart';
import '../level_complete.dart';
import '../quiz_option_button.dart';

/// Plays one PETA level: story pages with questions in between.
class StoryPlayerPage extends StatefulWidget {
  const StoryPlayerPage({super.key, required this.level});

  final StoryLevel level;

  @override
  State<StoryPlayerPage> createState() => _StoryPlayerPageState();
}

class _StoryPlayerPageState extends State<StoryPlayerPage> {
  late List<StoryStep> _steps;
  int _index = 0;
  int _mistakes = 0;

  /// Options already tried for the current question.
  final Set<int> _tried = {};
  bool _answered = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  void _prepare() {
    final random = Random();
    _steps = [
      for (final step in widget.level.steps)
        if (step is QuestionStep)
          QuestionStep(step.art, shuffleOptions(step.question, random))
        else
          step,
    ];
    _index = 0;
    _mistakes = 0;
    _tried.clear();
    _answered = false;
    _finishing = false;
  }

  StoryStep get _step => _steps[_index];

  bool get _inProgress => _index > 0 && !_finishing;

  void _answer(int option) {
    final question = (_step as QuestionStep).question;
    setState(() {
      _tried.add(option);
      if (option == question.answer) {
        _answered = true;
      } else {
        _mistakes++;
      }
    });
  }

  Future<void> _continue() async {
    if (_index < _steps.length - 1) {
      setState(() {
        _index++;
        _tried.clear();
        _answered = false;
      });
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    setState(() => _finishing = true);
    final state = context.read<AppState>();
    final stars = GameRules.starsForMistakes(_mistakes);
    final earned = await state.completeStoryLevel(widget.level.id, stars);
    if (!mounted) return;
    final index = storyLevels.indexOf(widget.level);
    final next = index + 1 < storyLevels.length ? storyLevels[index + 1] : null;
    final action = await showLevelComplete(
      context,
      title: stars == 3 ? 'Perfect!' : 'Level complete!',
      stars: stars,
      points: earned,
      message:
          _mistakes == 0
              ? 'You answered every question right the first time.'
              : 'You made $_mistakes ${_mistakes == 1 ? 'mistake' : 'mistakes'}. '
                  'Play again for more stars!',
      hasNext: next != null,
      nextLabel: 'Next: ${next?.title ?? ''}',
    );
    if (!mounted) return;
    switch (action) {
      case LevelCompleteAction.next:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => StoryPlayerPage(level: next!),
          ),
        );
      case LevelCompleteAction.replay:
        setState(_prepare);
      case LevelCompleteAction.close:
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _step;
    final canContinue = step is NarrationStep || _answered;

    return PopScope(
      canPop: !_inProgress,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await confirmLeaveGame(context)) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(widget.level.title),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_index + 1) / _steps.length,
                  minHeight: 8,
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.lg,
                    Gap.lg,
                    Gap.lg,
                    Gap.lg,
                  ),
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: StoryArtView(step.art, radius: Radii.lg),
                    ),
                    const SizedBox(height: Gap.xl),
                    ...switch (step) {
                      NarrationStep(:final text) => [
                        Text(
                          text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            height: 1.55,
                          ),
                        ),
                      ],
                      QuestionStep(:final question) => _questionView(
                        theme,
                        question,
                      ),
                    },
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canContinue && !_finishing ? _continue : null,
                    child: Text(
                      _index == _steps.length - 1 ? 'Finish level' : 'Continue',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _questionView(ThemeData theme, QuizQuestion question) {
    final wrongOnly = _tried.isNotEmpty && !_answered;
    return [
      const Tag('Question', icon: Icons.quiz_outlined),
      const SizedBox(height: Gap.sm),
      Text(question.prompt, style: theme.textTheme.titleLarge),
      const SizedBox(height: Gap.lg),
      for (var i = 0; i < question.options.length; i++)
        QuizOptionButton(
          label: question.options[i],
          state:
              _answered
                  ? (i == question.answer
                      ? OptionState.correct
                      : OptionState.disabled)
                  : _tried.contains(i)
                  ? OptionState.wrong
                  : OptionState.idle,
          onTap: () => _answer(i),
        ),
      if (wrongOnly)
        const NoticeBox(
          icon: Icons.refresh_rounded,
          text: 'Not quite. Have another look and try again!',
          color: AppColors.berrySoft,
          iconColor: AppColors.berry,
        ),
      if (_answered)
        NoticeBox(
          icon: Icons.lightbulb_outline_rounded,
          title: _tried.length == 1 ? 'Correct!' : 'You got it!',
          text: question.explanation,
          color: AppColors.mint,
          iconColor: AppColors.forest,
        ),
    ];
  }
}
