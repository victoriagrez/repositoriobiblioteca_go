import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biblioteca_go/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verifica que la app inicie correctamente
    await tester.pumpWidget(const MyApp());
    
    // Verifica que existe un MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}