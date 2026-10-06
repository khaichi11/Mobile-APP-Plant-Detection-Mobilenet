import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../games/quiz_builder.dart';
import '../../../models/story.dart';
import '../../../state/app_state.dart';
import '../../../state/game_rules.dart';
import '../../art/plant_diagram_painter.dart';
import '../../widgets/common.dart';
import '../level_complete.dart';
import '../quiz_option_button.dart';

enum PlantPart {
  flower(
    'Flower',
    'Attracts bees and butterflies and makes seeds.',
    Offset(0.5, 0.16),
  ),
  fruit('Fruit', 'Protects the seeds inside it.', Offset(0.74, 0.39)),
  leaf('Leaf', 'Makes food for the plant using sunlight.', Offset(0.33, 0.44)),
  stem(
    'Stem',
    'Holds the plant up and carries water to the leaves.',
    Offset(0.5, 0.66),
  ),
  root(
    'Root',
    'Drinks water from the soil and holds the plant in place.',
    Offset(0.5, 0.87),
  );

  const PlantPart(this.label, this.job, this.position);

  final String label;
  final String job;

  /// Where the label goes on the diagram, as fractions of its size.
  final Offset position;
}

/// Build a Plant: label the diagram, then match each part to its job.
class PlantPartsPage extends StatefulWidget {
  const PlantPartsPage({super.key});

  @override
  State<PlantPartsPage> createState() => _PlantPartsPageState();
}

class _PlantPartsPageState extends State<PlantPartsPage> {
  final _random = Random();
  final Set<PlantPart> _placed = {};
  PlantPart? _selected;
  PlantPart? _wrongTarget;
  Timer? _wrongTimer;
  int _mistakes = 0;

  /// Second round: questions about what each part does.
  List<(PlantPart, QuizQuestion)>? _questions;
  int _question = 0;
  final Set<int> _tried = {};
  bool _answered = false;
  bool _finished = false;

  late List<PlantPart> _bank;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _wrongTimer?.cancel();
    super.dispose();
  }

  void _reset() {
    _wrongTimer?.cancel();
    _placed.clear();
    _selected = null;
    _wrongTarget = null;
    _mistakes = 0;
    _questions = null;
    _question = 0;
    _tried.clear();
    _answered = false;
    _finished = false;
    _bank = [...PlantPart.values]..shuffle(_random);
  }

  bool get _started =>
      _placed.isNotEmpty || _mistakes > 0 || _questions != null;

  void _drop(PlantPart part, PlantPart target) {
    if (part == target) {
      setState(() {
        _placed.add(part);
        _selected = null;
      });
      if (_placed.length == PlantPart.values.length) {
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(_startQuestions);
        });
      }
    } else {
      setState(() {
        _mistakes++;
        _wrongTarget = target;
      });
      _wrongTimer?.cancel();
      _wrongTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _wrongTarget = null);
      });
    }
  }

  void _startQuestions() {
    final parts = [...PlantPart.values]..shuffle(_random);
    _questions = [
      for (final part in parts)
        (
          part,
          shuffleOptions(
            QuizQuestion(
              prompt: 'What does the ${part.label.toLowerCase()} do?',
              options: [
                part.job,
                ...(PlantPart.values.where((p) => p != part).toList()
                      ..shuffle(_random))
                    .take(2)
                    .map((p) => p.job),
              ],
              answer: 0,
              explanation: '',
            ),
            _random,
          ),
        ),
    ];
    _question = 0;
    _tried.clear();
    _answered = false;
  }

  void _answer(int option) {
    final (_, question) = _questions![_question];
    setState(() {
      _tried.add(option);
      if (option == question.answer) {
        _answered = true;
      } else {
        _mistakes++;
      }
    });
  }

  Future<void> _next() async {
    if (_question < _questions!.length - 1) {
      setState(() {
        _question++;
        _tried.clear();
        _answered = false;
      });
      return;
    }
    setState(() => _finished = true);
    final stars = GameRules.starsForMistakes(_mistakes);
    final earned = await context.read<AppState>().completePlantParts(stars);
    if (!mounted) return;
    final action = await showLevelComplete(
      context,
      title: 'You built a plant!',
      stars: stars,
      points: earned,
      message:
          'Roots drink, stems carry, leaves cook, flowers invite and '
          'fruits protect the seeds.',
    );
    if (!mounted) return;
    if (action == LevelCompleteAction.replay) {
      setState(_reset);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_started || _finished,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await confirmLeaveGame(context)) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Build a Plant'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value:
                      _questions == null
                          ? _placed.length / (PlantPart.values.length * 2)
                          : 0.5 +
                              (_question + (_answered ? 1 : 0)) /
                                  (_questions!.length * 2),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: _questions == null ? _labelRound(context) : _jobRound(context),
        ),
      ),
    );
  }

  Widget _labelRound(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = _bank.where((p) => !_placed.contains(p)).toList();
    return Padding(
      padding: const EdgeInsets.all(Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Label the plant', style: theme.textTheme.titleLarge),
          Text(
            'Drag each word to the right spot, or tap a word and then a spot.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: Gap.lg),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.85,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Positioned.fill(
                          child: CustomPaint(painter: PlantDiagramPainter()),
                        ),
                        for (final part in PlantPart.values)
                          Positioned(
                            left: part.position.dx * w - 50,
                            top: part.position.dy * h - 20,
                            width: 100,
                            height: 40,
                            child: _Target(
                              part: part,
                              placed: _placed.contains(part),
                              wrong: _wrongTarget == part,
                              onAccept: (dropped) => _drop(dropped, part),
                              onTap:
                                  _selected == null || _placed.contains(part)
                                      ? null
                                      : () => _drop(_selected!, part),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final part in remaining)
                Draggable<PlantPart>(
                  data: part,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _WordChip(label: part.label, selected: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _WordChip(label: part.label, selected: false),
                  ),
                  child: GestureDetector(
                    onTap:
                        () => setState(
                          () => _selected = _selected == part ? null : part,
                        ),
                    child: _WordChip(
                      label: part.label,
                      selected: _selected == part,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.sm),
        ],
      ),
    );
  }

  Widget _jobRound(BuildContext context) {
    final theme = Theme.of(context);
    final (part, question) = _questions![_question];
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(Gap.lg),
            children: [
              Tag(
                'Question ${_question + 1} of ${_questions!.length}',
                icon: Icons.quiz_outlined,
              ),
              const SizedBox(height: Gap.md),
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
              if (_tried.isNotEmpty && !_answered)
                const NoticeBox(
                  icon: Icons.refresh_rounded,
                  text: 'Not quite. Try another answer!',
                  color: AppColors.berrySoft,
                  iconColor: AppColors.berry,
                ),
              if (_answered)
                NoticeBox(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Correct!',
                  text: 'The ${part.label.toLowerCase()}: ${part.job}',
                  color: AppColors.mint,
                  iconColor: AppColors.forest,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _answered && !_finished ? _next : null,
              child: Text(
                _question == _questions!.length - 1 ? 'Finish' : 'Continue',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Target extends StatelessWidget {
  const _Target({
    required this.part,
    required this.placed,
    required this.wrong,
    required this.onAccept,
    required this.onTap,
  });

  final PlantPart part;
  final bool placed;
  final bool wrong;
  final ValueChanged<PlantPart> onAccept;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<PlantPart>(
      onWillAcceptWithDetails: (_) => !placed,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        final Color fill =
            placed
                ? AppColors.forest
                : wrong
                ? AppColors.berry
                : hovering
                ? AppColors.sunSoft
                : Colors.white.withValues(alpha: 0.92);
        return Semantics(
          container: true,
          excludeSemantics: true,
          button: onTap != null,
          label: placed ? part.label : 'Empty label spot',
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: placed || wrong ? Colors.white : AppColors.forest,
                  width: 2,
                ),
              ),
              child: Text(
                placed ? part.label : '?',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: placed || wrong ? Colors.white : AppColors.forest,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.forest : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? AppColors.forest : AppColors.line,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: selected ? Colors.white : AppColors.ink,
        ),
      ),
    );
  }
}
