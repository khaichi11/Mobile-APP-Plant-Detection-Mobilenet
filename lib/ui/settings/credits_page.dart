import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/plant_catalog.dart';
import '../collection/plant_detail_page.dart';
import 'settings_page.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Credits and licenses')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadPhotoCredits(),
        builder: (context, snapshot) {
          final credits = snapshot.data ?? const {};
          return ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
            children: [
              const _Credit(
                title: 'Plant identification model',
                body:
                    'AIY Vision Classifier Plants V1 by Google, based on '
                    'MobileNet. Apache License 2.0.',
              ),
              const _Credit(
                title: 'Fonts',
                body:
                    'Poppins by Indian Type Foundry and Inter by Rasmus '
                    'Andersson. SIL Open Font License 1.1.',
              ),
              const _Credit(
                title: 'Plant summaries',
                body:
                    'Plants outside the Pandai guide show a summary from '
                    'Wikipedia, licensed CC BY-SA 4.0.',
              ),
              const _Credit(
                title: 'Logo, illustrations and video',
                body:
                    'The Pandai logo, the Biji the seed illustrations, the '
                    'carrot artwork and the learning video are made by Team '
                    'Terang Bulan. Other story scenes are drawn in code.',
              ),
              const SizedBox(height: Gap.md),
              Text('Plant photos', style: theme.textTheme.titleMedium),
              const SizedBox(height: Gap.xs),
              Text(
                'From Wikimedia Commons. Thank you to every photographer.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: Gap.md),
              for (final plant in plantCatalog)
                if (credits[plant.id] case final Map<String, dynamic> credit)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.md),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${plant.commonName}: ',
                            style: theme.textTheme.titleSmall,
                          ),
                          TextSpan(
                            text: '${credit['author']}, ${credit['license']}\n',
                          ),
                          TextSpan(
                            text: '${credit['source']}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              const SizedBox(height: Gap.lg),
              OutlinedButton(
                onPressed:
                    () => showLicensePage(
                      context: context,
                      applicationName: 'Pandai',
                      applicationVersion: appVersion,
                    ),
                child: const Text('Open-source software licenses'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Credit extends StatelessWidget {
  const _Credit({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
