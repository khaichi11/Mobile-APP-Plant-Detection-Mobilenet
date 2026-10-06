import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/plant_catalog.dart';
import '../../services/app_services.dart';
import '../../services/classifier/classifier_math.dart';
import '../../services/classifier/plant_identifier.dart';
import '../../state/app_state.dart';
import '../../state/game_rules.dart';
import '../collection/plant_info.dart';
import '../widgets/common.dart';

/// Identifies the plant in [imagePath] and lets the player save it.
class ScanResultPage extends StatefulWidget {
  const ScanResultPage({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  IdentificationResult? _result;
  String? _error;

  /// The prediction the player is looking at; the best one by default.
  Prediction? _selected;
  bool _saving = false;
  bool _saved = false;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _identify();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _select(Prediction prediction) {
    setState(() => _selected = prediction);
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _identify() async {
    setState(() {
      _error = null;
      _result = null;
    });
    final services = context.read<AppServices>();
    final state = context.read<AppState>();
    try {
      final identifier = await services.identifier();
      final result = await identifier.identify(widget.imagePath);
      if (!mounted) return;
      setState(() {
        _result = result;
        _selected = result.best;
      });
      if (_isConfident(result.best)) await state.recordScan(result.best.label);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              e is IdentificationException
                  ? e.message
                  : 'Something went wrong while identifying this photo.';
        });
      }
    }
  }

  bool _isConfident(Prediction prediction) =>
      prediction.label != IdentificationResult.backgroundLabel &&
      prediction.confidence >= GameRules.scanConfidenceThreshold;

  Future<void> _save(Prediction prediction) async {
    setState(() => _saving = true);
    try {
      final result = await context.read<AppState>().addToCollection(
        scientificName: prediction.label,
        sourceImagePath: widget.imagePath,
        confidence: prediction.confidence,
      );
      if (!mounted) return;
      setState(() => _saved = true);
      if (result.isNewSpecies) {
        await showDialog<void>(
          context: context,
          builder:
              (_) => _NewSpeciesDialog(
                name: _displayName(prediction.label),
                points: result.points,
              ),
        );
      } else {
        showMessage(context, 'Photo updated in your herbarium.');
      }
    } catch (_) {
      if (mounted) showMessage(context, 'Could not save the photo. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _displayName(String label) =>
      plantByScientificName(label)?.commonName ?? label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: IconButton.filledTonal(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                cacheWidth: 1080,
                errorBuilder: (_, _, _) => Container(color: AppColors.mint),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.lg,
                Gap.xl,
                Gap.lg,
                Gap.xxl,
              ),
              child: _body(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    if (_error != null) {
      return Column(
        children: [
          NoticeBox(
            icon: Icons.error_outline_rounded,
            text: _error!,
            color: AppColors.berrySoft,
            iconColor: AppColors.berry,
          ),
          const SizedBox(height: Gap.lg),
          FilledButton(onPressed: _identify, child: const Text('Try again')),
        ],
      );
    }
    final result = _result;
    if (result == null) {
      return Column(
        children: [
          const SizedBox(height: Gap.lg),
          const CircularProgressIndicator(),
          const SizedBox(height: Gap.lg),
          Text(
            'Looking closely at your plant...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'The AI runs on your phone, so this works offline too.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      );
    }
    if (!_isConfident(result.best)) return _notSure(context, result);
    return _identified(context, result);
  }

  Widget _notSure(BuildContext context, IdentificationResult result) {
    final theme = Theme.of(context);
    final guesses =
        [
          if (!result.isBackground) result.best,
          ...result.alternatives,
        ].take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Hmm, I am not sure', style: theme.textTheme.headlineSmall),
        const SizedBox(height: Gap.sm),
        Text(
          result.isBackground
              ? 'I could not find a plant in this photo.'
              : 'This plant is hard to recognise from this photo.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: Gap.lg),
        const NoticeBox(
          icon: Icons.tips_and_updates_outlined,
          title: 'Tips for a better scan',
          text:
              'Get close to one leaf or flower, use daylight, keep the phone '
              'still and avoid a busy background.',
        ),
        if (guesses.isNotEmpty) ...[
          const SizedBox(height: Gap.xl),
          Text('Best guesses', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.sm),
          for (final guess in guesses)
            _GuessTile(prediction: guess, name: _displayName(guess.label)),
        ],
        const SizedBox(height: Gap.xl),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.center_focus_strong_rounded),
          label: const Text('Scan again'),
        ),
      ],
    );
  }

  Widget _identified(BuildContext context, IdentificationResult result) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final prediction = _selected ?? result.best;
    final profile = plantByScientificName(prediction.label);
    final alreadyFound = state.hasSpecies(prediction.label);
    final alternatives =
        [
          result.best,
          ...result.alternatives,
        ].where((p) => p.label != prediction.label).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          profile?.commonName ?? prediction.label,
          style: theme.textTheme.headlineMedium,
        ),
        if (profile != null)
          Text(
            prediction.label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.inkMuted,
            ),
          ),
        const SizedBox(height: Gap.lg),
        _ConfidenceBar(confidence: prediction.confidence),
        const SizedBox(height: Gap.xl),
        FilledButton.icon(
          onPressed: _saving || _saved ? null : () => _save(prediction),
          icon: Icon(
            _saved ? Icons.check_rounded : Icons.bookmark_add_outlined,
          ),
          label: Text(
            _saved
                ? 'Saved in your herbarium'
                : alreadyFound
                ? 'Update photo in herbarium'
                : 'Add to herbarium  +${GameRules.newSpeciesPoints}',
          ),
        ),
        const SizedBox(height: Gap.sm),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.center_focus_strong_rounded),
          label: const Text('Scan another plant'),
        ),
        const SizedBox(height: Gap.xl),
        if (profile != null)
          PlantProfileView(plant: profile)
        else
          WikiSummaryView(
            key: ValueKey(prediction.label),
            scientificName: prediction.label,
          ),
        if (alternatives.isNotEmpty) ...[
          const SizedBox(height: Gap.xl),
          Text('Could also be', style: theme.textTheme.titleMedium),
          const SizedBox(height: Gap.sm),
          for (final alternative in alternatives)
            _GuessTile(
              prediction: alternative,
              name: _displayName(alternative.label),
              onTap: _saved ? null : () => _select(alternative),
            ),
        ],
      ],
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (confidence * 100).round();
    final label =
        confidence >= 0.7
            ? 'Very sure'
            : confidence >= 0.5
            ? 'Quite sure'
            : 'A little unsure';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.titleSmall),
            const Spacer(),
            Text('$percent%', style: theme.textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence.clamp(0.0, 1.0),
            minHeight: 8,
            color: confidence >= 0.5 ? AppColors.leaf : AppColors.sun,
          ),
        ),
      ],
    );
  }
}

class _GuessTile extends StatelessWidget {
  const _GuessTile({required this.prediction, required this.name, this.onTap});

  final Prediction prediction;
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: TapCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.lg,
          vertical: Gap.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleSmall),
                  if (name != prediction.label)
                    Text(
                      prediction.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '${(prediction.confidence * 100).round()}%',
              style: theme.textTheme.labelMedium,
            ),
            if (onTap != null) ...[
              const SizedBox(width: Gap.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NewSpeciesDialog extends StatelessWidget {
  const _NewSpeciesDialog({required this.name, required this.points});

  final String name;
  final int points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: const Icon(
        Icons.local_florist_rounded,
        color: AppColors.forest,
        size: 40,
      ),
      title: const Text('New plant discovered!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$name is now in your herbarium.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: Gap.lg),
          PointsPill(points: points),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Great!'),
        ),
      ],
    );
  }
}
