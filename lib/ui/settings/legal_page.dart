import 'package:flutter/material.dart';

import '../../core/theme.dart';

class LegalPage extends StatelessWidget {
  const LegalPage.privacy({super.key})
    : title = 'Privacy policy',
      sections = _privacy;

  const LegalPage.terms({super.key})
    : title = 'Terms of use',
      sections = _terms;

  final String title;
  final List<(String, String)> sections;

  static const _privacy = [
    (
      'Your data stays on your phone',
      'Pandai stores your account, points, badges and herbarium only on this '
          'device. There is no Pandai server, and we do not sell or share any '
          'data.',
    ),
    (
      'Photos',
      'Photos you take are identified by an AI model that runs on your phone. '
          'Photos are never uploaded. Photos you save are kept in the app\'s '
          'own storage until you remove them.',
    ),
    (
      'Internet use',
      'When you are online and scan a plant that is not in the Pandai guide, '
          'the app asks Wikipedia for a short summary using only the plant\'s '
          'scientific name.',
    ),
    (
      'Passwords',
      'Passwords are stored as a salted hash, never as plain text.',
    ),
    (
      'Deleting your data',
      'Use Settings > Reset progress to delete your progress and photos. '
          'Uninstalling the app deletes everything.',
    ),
    (
      'For parents and teachers',
      'Pandai is made for elementary school students. It has no ads, no '
          'in-app purchases and no chat with strangers.',
    ),
  ];

  static const _terms = [
    (
      'Explore safely',
      'Always explore outside with an adult or in a safe place like your '
          'school or garden. Watch out for traffic, water and insects.',
    ),
    (
      'Never eat wild plants',
      'Pandai can be wrong. Never eat, taste or touch a plant just because '
          'the app named it. Some plants are poisonous or sting.',
    ),
    (
      'Respect nature',
      'Take photos, not plants. Do not pick flowers or break branches, '
          'especially in parks and protected areas.',
    ),
    (
      'Fair play',
      'Points and badges are for fun and learning. Please be kind to your '
          'classmates on the ranking.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
        children: [
          for (final (heading, body) in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(heading, style: theme.textTheme.titleMedium),
                  const SizedBox(height: Gap.xs),
                  Text(body, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
