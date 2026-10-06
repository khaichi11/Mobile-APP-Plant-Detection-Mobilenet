import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../data/plant_catalog.dart';
import '../../models/plant.dart';
import '../../state/app_state.dart';
import '../scanner/scanner_page.dart';
import '../widgets/common.dart';
import '../widgets/images.dart';
import 'plant_detail_page.dart';

/// The player's own herbarium plus the guide of all catalog plants.
class HerbariumPage extends StatelessWidget {
  const HerbariumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Plant Collection'),
          bottom: const TabBar(
            tabs: [Tab(text: 'My plants'), Tab(text: 'Plant guide')],
          ),
        ),
        body: const TabBarView(children: [_MyPlants(), _PlantGuide()]),
      ),
    );
  }
}

class _MyPlants extends StatelessWidget {
  const _MyPlants();

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<AppState>().data.collection;
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return EmptyState(
        icon: Icons.local_florist_outlined,
        title: 'Your collection is empty',
        message:
            'Scan plants outside and save them here. Each new plant '
            'earns 30 points.',
        action: FilledButton.icon(
          onPressed: () => openScanner(context),
          icon: const Icon(Icons.center_focus_strong_rounded),
          label: const Text('Scan a plant'),
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              '${entries.length} ${entries.length == 1 ? 'plant' : 'plants'} '
              'collected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Gap.lg,
            Gap.lg,
            Gap.lg,
            kNavBarClearance,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: Gap.md,
              crossAxisSpacing: Gap.md,
              childAspectRatio: 0.78,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final profile = plantByScientificName(entry.scientificName);
              return _PlantCard(
                image: FilePhoto(entry.imagePath, radius: 0),
                title: profile?.commonName ?? entry.scientificName,
                subtitle: formatDate(entry.foundAt),
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PlantDetailPage.entry(entry.id),
                      ),
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlantGuide extends StatefulWidget {
  const _PlantGuide();

  @override
  State<_PlantGuide> createState() => _PlantGuideState();
}

class _PlantGuideState extends State<_PlantGuide> {
  PlantCategory? _category;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final query = _query.trim().toLowerCase();
    final plants =
        plantCatalog.where((plant) {
          if (_category != null && plant.category != _category) return false;
          if (query.isEmpty) return true;
          return plant.commonName.toLowerCase().contains(query) ||
              plant.localName.toLowerCase().contains(query) ||
              plant.scientificName.toLowerCase().contains(query);
        }).toList();
    final found = plantCatalog.where((p) => state.hasSpecies(p.scientificName));
    final categories =
        PlantCategory.values
            .where((c) => plantCatalog.any((p) => p.category == c))
            .toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You found ${found.length} of ${plantCatalog.length} guide '
                  'plants',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: Gap.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: found.length / plantCatalog.length,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: Gap.lg),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search plants',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: Gap.md),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'All',
                        selected: _category == null,
                        onTap: () => setState(() => _category = null),
                      ),
                      for (final category in categories)
                        _CategoryChip(
                          label: category.label,
                          selected: _category == category,
                          onTap: () => setState(() => _category = category),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (plants.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No plants found',
              message: 'Try another name or category.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Gap.lg,
              Gap.lg,
              Gap.lg,
              kNavBarClearance,
            ),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: Gap.md,
                crossAxisSpacing: Gap.md,
                childAspectRatio: 0.78,
              ),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                return _PlantCard(
                  image: PlantPhoto(plant.id, radius: 0),
                  title: plant.commonName,
                  subtitle: plant.localName,
                  found: state.hasSpecies(plant.scientificName),
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PlantDetailPage.catalog(plant.id),
                        ),
                      ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Gap.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.found = false,
  });

  final Widget image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool found;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TapCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                image,
                if (found)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Tag(
                      'Found',
                      icon: Icons.check_rounded,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.md, Gap.sm, Gap.md, Gap.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
