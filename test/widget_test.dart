import 'package:flutter_test/flutter_test.dart';
import 'package:simple_news_api/main.dart';

void main() {
  testWidgets('Pulse News app loads properly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title appears
    expect(find.text('PULSE'), findsOneWidget);
  });
}
