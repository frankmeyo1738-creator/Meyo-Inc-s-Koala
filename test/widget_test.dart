import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:koala/main.dart';

void main() {
  testWidgets('Koala app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KoalaApp());

    // Verify that the app launches with home screen
    expect(find.text('Koala'), findsOneWidget);
  });
}
