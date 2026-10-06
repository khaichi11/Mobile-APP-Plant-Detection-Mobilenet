import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/plant.dart';
import '../../services/app_services.dart';
import '../../services/wiki_service.dart';
import '../widgets/common.dart';

IconData categoryIcon(PlantCategory category) => switch (category) {
  PlantCategory.flower => Icons.local_florist_rounded,
  PlantCategory.tree => Icons.park_rounded,
  PlantCategory.fruit => Icons.eco_rounded,
  PlantCategory.vegetable => Icons.agriculture_rounded,
  PlantCategory.herb => Icons.grass_rounded,
  PlantCategory.aquatic => Icons.water_rounded,
  PlantCategory.succulent => Icons.spa_rounded,
  PlantCategory.shrub => Icons.forest_rounded,
  PlantCategory.vine => Icons.energy_savings_leaf_rounded,
};

/// Names, tags and the hand-written sections of a catalog plant.
class PlantProfileView extends StatelessWidget {
  const PlantProfileView({super.key, required this.plant});

  final PlantProfile plant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            Tag(plant.category.label, icon: categoryIcon(plant.category)),
            Tag(
              plant.habitat,
              icon: Icons.place_outlined,
              color: AppColors.skySoft,
              foreground: const Color(0xFF2F6F8F),
            ),
          ],
        ),
        if (plant.caution != null) ...[
          const SizedBox(height: Gap.lg),
          NoticeBox(
            icon: Icons.warning_amber_rounded,
            title: 'Be careful',
            text: plant.caution!,
            color: AppColors.berrySoft,
            iconColor: AppColors.berry,
          ),
        ],
        const SizedBox(height: Gap.xl),
        _Section(title: 'About', body: plant.description),
        _Section(
          title: 'Fun fact',
          body: plant.funFact,
          icon: Icons.lightbulb_outline_rounded,
        ),
        _Section(
          title: 'How it helps',
          body: plant.uses,
          icon: Icons.volunteer_activism_outlined,
        ),
        Text(
          'Local name: ${plant.localName}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body, this.icon});

  final String title;
  final String body;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.forest),
                const SizedBox(width: 6),
              ],
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Text(body, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// A Wikipedia summary for plants without hand-written content.
class WikiSummaryView extends StatefulWidget {
  const WikiSummaryView({super.key, required this.scientificName});

  final String scientificName;

  @override
  State<WikiSummaryView> createState() => _WikiSummaryViewState();
}

class _WikiSummaryViewState extends State<WikiSummaryView> {
  late Future<WikiSummary?> _summary;

  @override
  void initState() {
    super.initState();
    _summary = context.read<AppServices>().wiki.summary(widget.scientificName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<WikiSummary?>(
      future: _summary,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: Gap.lg),
            child: LinearProgressIndicator(),
          );
        }
        final summary = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NoticeBox(
              icon: Icons.menu_book_outlined,
              text:
                  'This plant is not in the Pandai guide yet, but you can '
                  'still add it to your herbarium.',
              color: AppColors.skySoft,
              iconColor: Color(0xFF2F7FA6),
            ),
            const SizedBox(height: Gap.lg),
            if (summary == null)
              Text(
                'Connect to the internet to read more about this plant.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
              )
            else ...[
              Text('About', style: theme.textTheme.titleMedium),
              const SizedBox(height: Gap.xs),
              Text(summary.extract, style: theme.textTheme.bodyLarge),
              const SizedBox(height: Gap.xs),
              Text(
                'Source: Wikipedia, CC BY-SA 4.0',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        );
      },
    );
  }
}
