import 'package:flutter_test/flutter_test.dart';

import 'package:pandai/main.dart';

void main() {
  testWidgets('app starts on the login page', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('SELAMAT DATANG KEMBALI!'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
