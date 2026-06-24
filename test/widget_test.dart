import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_cube/main.dart';

void main() {
  testWidgets('Magic Square app launch smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Initially, it shows a loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the asynchronous initialization finish by pumping frames.
    // We avoid pumpAndSettle because the active game timer runs indefinitely.
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify that we are on the Level Select Screen
    expect(find.text('MAGIC SQUARE'), findsOneWidget);
    expect(find.text('Select a Matrix to Align'), findsOneWidget);
  });
}
