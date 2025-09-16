// This is a basic Flutter widget test for Advantis IoT module.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advantis_iot/advantis_iot.dart';

void main() {
  testWidgets('AdvantisIoTModule initialization test', (WidgetTester tester) async {
    // Initialize the module
    await AdvantisIoTModule.initialize();
    
    // Verify module is initialized
    expect(AdvantisIoTModule.isInitialized, true);
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(AdvantisIoTModule.createApp());

    // Verify that splash screen or initial route loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Individual screen widgets test', (WidgetTester tester) async {
    // Test individual screen widgets
    await tester.pumpWidget(MaterialApp(
      home: AdvantisIoTModule.withProvider(AdvantisIoTModule.homeScreen()),
    ));
    
    // Verify home screen loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
