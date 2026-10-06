import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/services/classifier/classifier_math.dart';
import 'package:pandai/ui/collection/herbarium_page.dart';
import 'package:pandai/ui/scanner/scan_result_page.dart';

import '../support/test_app.dart';

void main() {
  testWidgets('a confident scan can be saved for points', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.pumpPage(
      tester,
      const ScanResultPage(imagePath: '/tmp/x.jpg'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sunflower'), findsOneWidget);
    expect(find.text('Helianthus annuus'), findsOneWidget);
    expect(find.text('91%'), findsOneWidget);
    expect(harness.state.data.totalScans, 1);

    await tester.tap(find.text('Add to herbarium  +30'));
    await tester.pumpAndSettle();
    expect(find.text('New plant discovered!'), findsOneWidget);
    await tester.tap(find.text('Great!'));
    await tester.pumpAndSettle();

    expect(find.text('Saved in your herbarium'), findsOneWidget);
    expect(harness.state.data.points, 30);
    expect(harness.state.hasSpecies('Helianthus annuus'), isTrue);
  });

  testWidgets('a blurry photo asks the player to try again', (tester) async {
    final harness = TestHarness(
      predictions: const [
        Prediction('background', 0.7),
        Prediction('Carica papaya', 0.12),
      ],
    );
    await harness.signIn();
    await harness.pumpPage(
      tester,
      const ScanResultPage(imagePath: '/tmp/x.jpg'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hmm, I am not sure'), findsOneWidget);
    expect(
      find.text('I could not find a plant in this photo.'),
      findsOneWidget,
    );
    expect(find.text('Papaya'), findsOneWidget);
    expect(harness.state.data.totalScans, 0);
  });

  testWidgets('plants outside the guide still show and can be saved', (
    tester,
  ) async {
    final harness = TestHarness(
      predictions: const [Prediction('Betula lenta', 0.8)],
    );
    await harness.signIn();
    await harness.pumpPage(
      tester,
      const ScanResultPage(imagePath: '/tmp/x.jpg'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Betula lenta'), findsOneWidget);
    expect(find.textContaining('not in the Pandai guide'), findsOneWidget);
    expect(
      find.text('Connect to the internet to read more about this plant.'),
      findsOneWidget,
    );
  });

  testWidgets('choosing an alternative changes the saved plant', (
    tester,
  ) async {
    final harness = TestHarness(
      predictions: const [
        Prediction('Hibiscus syriacus', 0.5),
        Prediction('Hibiscus rosa-sinensis', 0.4),
      ],
    );
    await harness.signIn();
    await harness.pumpPage(
      tester,
      const ScanResultPage(imagePath: '/tmp/x.jpg'),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Chinese hibiscus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chinese hibiscus'));
    await tester.pumpAndSettle();
    expect(find.text('Chinese hibiscus'), findsOneWidget);
    await tester.tap(find.text('Add to herbarium  +30'));
    await tester.pumpAndSettle();
    expect(harness.state.hasSpecies('Hibiscus rosa-sinensis'), isTrue);
  });

  testWidgets('herbarium entries can be opened and removed', (tester) async {
    final harness = TestHarness();
    await harness.signIn();
    await harness.state.addToCollection(
      scientificName: 'Cocos nucifera',
      sourceImagePath: '/tmp/coconut.jpg',
      confidence: 0.77,
    );
    await harness.pumpPage(tester, const HerbariumPage());
    await tester.pumpAndSettle();

    expect(find.text('1 plant collected'), findsOneWidget);
    await tester.tap(find.text('Coconut palm'));
    await tester.pumpAndSettle();
    expect(find.textContaining('77% sure'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from herbarium'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(harness.state.data.collection, isEmpty);
    expect(find.text('Your collection is empty'), findsOneWidget);
    expect(harness.state.data.points, 30, reason: 'points are kept');
  });
}
