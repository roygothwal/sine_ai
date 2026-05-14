import 'package:flutter_test/flutter_test.dart';
import 'package:sine_ai/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('SINE AI app launches', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SineAIApp(),
      ),
    );

    expect(find.byType(SineAIApp), findsOneWidget);
  });
}
