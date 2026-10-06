import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../games/quiz_builder.dart';
import '../../../state/app_state.dart';
import '../../../state/game_rules.dart';
import '../../widgets/common.dart';
import '../../widgets/story_art_view.dart';
import '../level_complete.dart';
import '../quiz_option_button.dart';

/// Five questions a day. Only the first try of the day earns points.
class DailyQuizPage extends StatefulWidget {
  const DailyQuizPage({super.key});

  @override
  State<DailyQuizPage> createState() => _DailyQuizPageState();
}

class _DailyQuizPageState extends State<DailyQuizPage> {
  late final List<QuizItem> _items;
  late bool _practice;
  int _index = 0;
  int _correct = 0;
  int? _choice;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _items = buildDailyQuiz(state.dayIndex);
    _practice = state.dailyQuizScore != null;
  }

  void _choose(int option) {
    final item = _items[_index];
    setState(() {
      _choice = option;
      if (option == item.question.answer) _correct++;
    });
  }

  Future<void> _next() async {
    if (_index < _items.length - 1) {
      setState(() {
        _index++;
        _choice = null;
      });
      return;
    }
    setState(() => _finishing = true);
    final earned = await context.read<AppState>().completeDailyQuiz(
      _correct,
      _items.length,
    );
    if (!mounted) return;
    final mistakes = _items.length - _correct;
    final action = await showLevelComplete(
      context,
      title: '$_correct of ${_items.length} correct',
      stars: GameRules.starsForMistakes(mistakes),
      points: earned,
      message:
          _practice
              ? 'Practice round. Points are given for the first quiz of the day.'
              : 'Come back tomorrow for new questions!',
    );
    if (!mounted) return;
    if (action == LevelCompleteAction.replay) {
      setState(() {
        _index = 0;
        _correct = 0;
        _choice = null;
        _finishing = false;
        _practice = true;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = _items[_index];
    final question = item.question;
    final answered = _choice != null;
    final right = _choice == question.answer;

    return PopScope(
      canPop: (_index == 0 && !answered) || _finishing,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await confirmLeaveGame(context)) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_practice ? 'Quiz practice' : 'Daily quiz'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: (_index + (answered ? 1 : 0)) / _items.length,
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
                  padding: const EdgeInsets.all(Gap.lg),
                  children: [
                    if (_practice && _index == 0 && !answered) ...[
                      const NoticeBox(
                        icon: Icons.info_outline_rounded,
                        text:
                            'You already finished today\'s quiz. This is a '
                            'practice round without points.',
                        color: AppColors.skySoft,
                        iconColor: Color(0xFF2F7FA6),
                      ),
                      const SizedBox(height: Gap.lg),
                    ],
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: StoryArtView(item.art, radius: Radii.lg),
                    ),
                    const SizedBox(height: Gap.lg),
                    Text(
                      'Question ${_index + 1} of ${_items.length}',
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(question.prompt, style: theme.textTheme.titleLarge),
                    const SizedBox(height: Gap.lg),
                    for (var i = 0; i < question.options.length; i++)
                      QuizOptionButton(
                        label: question.options[i],
                        state:
                            !answered
                                ? OptionState.idle
                                : i == question.answer
                                ? OptionState.correct
                                : i == _choice
                                ? OptionState.wrong
                                : OptionState.disabled,
                        onTap: () => _choose(i),
                      ),
                    if (answered)
                      NoticeBox(
                        icon:
                            right
                                ? Icons.check_circle_outline_rounded
                                : Icons.lightbulb_outline_rounded,
                        title: right ? 'Correct!' : 'Good try!',
                        text: question.explanation,
                        color: right ? AppColors.mint : AppColors.sunSoft,
                        iconColor:
                            right ? AppColors.forest : const Color(0xFFB7791F),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: answered && !_finishing ? _next : null,
                    child: Text(
                      _index == _items.length - 1
                          ? 'See results'
                          : 'Next question',
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
}
