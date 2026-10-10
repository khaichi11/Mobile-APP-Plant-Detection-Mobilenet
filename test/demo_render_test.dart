// Renders the app as PNG frames for the demo GIF, without an emulator: screens
// are drawn on the laptop with a fake classifier, then placed in a phone frame.
//   DEMO_FRAMES=build/frames flutter test test/demo_render_test.dart
//   python3 tool/render_gif.py build/frames docs/demo.gif
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/app.dart';
import 'package:pandai/ui/scanner/scan_result_page.dart';

import 'demo/demo_recorder.dart';
import 'support/test_app.dart';

void main() {
  final out = Platform.environment['DEMO_FRAMES'];
  testWidgets('demo frames', (tester) async {
    await tester.runAsync(
      () => loadFonts({
        for (final family in ['Poppins', 'Inter'])
          family: [
            for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
              'assets/fonts/$family-$w.ttf',
          ],
      }),
    );
    final harness = TestHarness();
    await harness.signIn();
    if (out != null) Directory(out).createSync(recursive: true);
    final r = DemoRecorder(tester, out)..prepare();
    await tester.pumpWidget(
      r.wrap(PandaiApp(state: harness.state, services: harness.services)),
    );

    // 1. the logo fades in and out into the app
    r.scene = 'opening';
    await r.run(2900);
    await r.settle();

    // 2. home, scrolled slowly
    r.scene = 'home';
    await r.run(1500);
    await r.scroll(-600, steps: 12);
    await r.run(1000);
    await r.scroll(600, steps: 8);

    // 3. a sunflower photo is identified and saved to the herbarium
    r.scene = 'scan';
    final photo = File('assets/images/plants/sunflower.jpg').absolute.path;
    Navigator.of(
      tester.element(find.byType(Scaffold).first),
    ).push(MaterialPageRoute(builder: (_) => ScanResultPage(imagePath: photo)));
    await r.run(300);
    await r.settle(1000);
    await r.run(200);
    await r.settle(1000);
    await r.run(1800);
    await r.tap(find.text('Add to herbarium  +30'), after: 1500);
    await r.tap(find.text('Great!'), after: 1200);
    await r.scroll(-500);
    await r.run(1200);

    // 4. the collection tab
    r.scene = 'collection';
    Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
    await r.run(600);
    await r.tap(find.text('Collection'), after: 2000);
    r.finish();
  }, skip: out == null);
}
