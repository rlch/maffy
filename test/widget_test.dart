import 'package:flutter_test/flutter_test.dart';
import 'package:maffy/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MaffyApp());
    
    // Verify the app title is present
    expect(find.text('Untitled Graph'), findsOneWidget);
  });
}
