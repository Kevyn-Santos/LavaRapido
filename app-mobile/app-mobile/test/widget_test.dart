import 'package:flutter_test/flutter_test.dart';

import 'package:flash_splash/app.dart';

void main() {
  testWidgets('o app abre na tela inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const FlashSplashApp());

    expect(find.byType(FlashSplashApp), findsOneWidget);
  });
}
