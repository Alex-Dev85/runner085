// Basic smoke test for Runner085.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test: empty MaterialApp builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('Runner085')),
      ),
    );

    expect(find.text('Runner085'), findsOneWidget);
  });
}
