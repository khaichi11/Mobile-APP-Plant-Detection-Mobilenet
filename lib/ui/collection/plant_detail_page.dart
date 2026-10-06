import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../data/plant_catalog.dart';
import '../../models/collection_entry.dart';
import '../../models/plant.dart';
import '../../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/images.dart';
import 'plant_info.dart';

/// Details of a herbarium entry or of a plant in the guide.
class PlantDetailPage extends StatelessWidget {
  const PlantDetailPage.entry(String this.entryId, {super.key})
    : plantId = null;

  const PlantDetailPage.catalog(String this.plantId, {super.key})
    : entryId = null;

  final String? entryId;
  final String? plantId;

  Future<void> _delete(BuildContext context, CollectionEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove this plant?'),
            content: const Text(
              'Its photo will be deleted from your herbarium. Your points stay.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.berry),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    final state = context.read<AppState>();
    Navigator.of(context).pop();
    await state.removeFromCollection(entry.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final entry =
        entryId == null
            ? null
            : state.data.collection.where((e) => e.id == entryId).firstOrNull;
    final PlantProfile? profile =
        plantId != null
            ? plantById(plantId!)
            : entry == null
            ? null
            : plantByScientificName(entry.scientificName);

    if (entry == null && profile == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }

    final scientificName = entry?.scientificName ?? profile!.scientificName;
    final found = state.hasSpecies(scientificName);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: IconButton.filledTonal(
                tooltip: 'Back',
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            actions: [
              if (entry != null)
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: IconButton.filledTonal(
                    tooltip: 'Remove from herbarium',
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () => _delete(context, entry),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background:
                  entry != null
                      ? FilePhoto(entry.imagePath, radius: 0)
                      : PlantPhoto(profile!.id, radius: 0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.commonName ?? scientificName,
                    style: theme.textTheme.headlineMedium,
                  ),
                  if (profile != null)
                    Text(
                      scientificName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  const SizedBox(height: Gap.lg),
                  if (entry != null)
                    NoticeBox(
                      icon: Icons.event_available_rounded,
                      text:
                          'You found this plant on '
                          '${formatDate(entry.foundAt)}. Pandai was '
                          '${(entry.confidence * 100).round()}% sure.',
                      color: AppColors.mint,
                      iconColor: AppColors.forest,
                    )
                  else if (!found)
                    const NoticeBox(
                      icon: Icons.travel_explore_rounded,
                      text:
                          'Not found yet. Look for it outside and scan it '
                          'to add it to your herbarium.',
                      color: AppColors.skySoft,
                      iconColor: Color(0xFF2F7FA6),
                    ),
                  const SizedBox(height: Gap.xl),
                  if (profile != null)
                    PlantProfileView(plant: profile)
                  else
                    WikiSummaryView(scientificName: scientificName),
                  if (entry == null && profile != null) ...[
                    const SizedBox(height: Gap.md),
                    _PhotoCredit(plantId: profile.id),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Author and license of a catalog photo.
class _PhotoCredit extends StatelessWidget {
  const _PhotoCredit({required this.plantId});

  final String plantId;

  static Future<Map<String, dynamic>>? _credits;

  static Future<Map<String, dynamic>> load() {
    return _credits ??= rootBundle
        .loadString('assets/images/plants/credits.json')
        .then((raw) => jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: load(),
      builder: (context, snapshot) {
        final credit = snapshot.data?[plantId] as Map<String, dynamic>?;
        if (credit == null) return const SizedBox.shrink();
        return Text(
          'Photo: ${credit['author']} · ${credit['license']} · Wikimedia Commons',
          style: Theme.of(context).textTheme.bodySmall,
        );
      },
    );
  }
}

/// Loads the photo credits, shared with the credits screen.
Future<Map<String, dynamic>> loadPhotoCredits() => _PhotoCredit.load();
