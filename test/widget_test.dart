import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:biblioteca_go/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BibliotecaApp());
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
  });
}