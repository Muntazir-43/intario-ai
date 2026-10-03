import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('basic test', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Text('Intario AI'),
      ),
    ));

    expect(find.text('Intario AI'), findsOneWidget);
  });
}