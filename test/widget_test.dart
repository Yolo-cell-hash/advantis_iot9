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
  group('AdvantisIoTModule Tests', () {
    testWidgets('Module initialization test', (WidgetTester tester) async {
      // Initialize the module
      await AdvantisIoTModule.initialize();
      
      // Verify module is initialized
      expect(AdvantisIoTModule.isInitialized, true);
      
      // Verify shared state is accessible
      expect(AdvantisIoTModule.sharedState, isNotNull);
    });

    testWidgets('Individual screen widgets test', (WidgetTester tester) async {
      // Initialize first
      await AdvantisIoTModule.initialize();
      
      // Test individual screen widgets
      await tester.pumpWidget(MaterialApp(
        home: AdvantisIoTModule.homeScreen(autoConnect: false),
      ));
      
      // Verify home screen loads
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('State management test', (WidgetTester tester) async {
      // Initialize module
      await AdvantisIoTModule.initialize();
      
      // Test state access
      final initialState = AdvantisIoTModule.getCurrentState();
      expect(initialState, isA<Map<String, dynamic>>());
      
      // Test state update
      final testData = {'phoneNumber': '+1234567890', 'otpSent': true};
      AdvantisIoTModule.updateState(testData);
      
      final updatedState = AdvantisIoTModule.getCurrentState();
      expect(updatedState['phoneNumber'], '+1234567890');
      expect(updatedState['otpSent'], true);
    });

    testWidgets('Firebase service integration test', (WidgetTester tester) async {
      // Initialize module
      await AdvantisIoTModule.initialize();
      
      // Verify Firebase service is available
      expect(FirebaseService.instance.isInitialized, true);
      
      // Test state updates
      final appState = AdvantisIoTModule.sharedState;
      expect(appState, isNotNull);
      
      // Test state change notification
      bool notified = false;
      appState.addListener(() {
        notified = true;
      });
      
      appState.phoneNumber = 'test';
      await tester.pump();
      
      expect(notified, true);
    });

    testWidgets('App creation test', (WidgetTester tester) async {
      // Initialize the module
      await AdvantisIoTModule.initialize();
      
      // Build the complete app
      await tester.pumpWidget(AdvantisIoTModule.createApp());

      // Verify that the app loads
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    test('Android integration service test', () {
      // Initialize Android integration
      AndroidIntegrationService.initialize();
      
      // Verify initialization
      expect(AndroidIntegrationService.isAndroidIntegration, true);
    });
  });

  group('AppState Tests', () {
    test('Singleton pattern test', () {
      final state1 = AppState.instance;
      final state2 = AppState.instance;
      
      expect(state1, same(state2));
    });

    test('State serialization test', () {
      final appState = AppState.instance;
      appState.phoneNumber = '+1234567890';
      appState.otpSent = true;
      appState.firebaseConnected = true;
      
      final stateMap = appState.toMap();
      expect(stateMap['phoneNumber'], '+1234567890');
      expect(stateMap['otpSent'], true);
      expect(stateMap['firebaseConnected'], true);
      
      // Test state restoration
      final newState = AppState();
      newState.updateFromMap(stateMap);
      
      expect(newState.phoneNumber, '+1234567890');
      expect(newState.otpSent, true);
      expect(newState.firebaseConnected, true);
    });

    test('State reset test', () {
      final appState = AppState.instance;
      appState.phoneNumber = '+1234567890';
      appState.otpSent = true;
      
      appState.reset();
      
      expect(appState.phoneNumber, '');
      expect(appState.otpSent, false);
    });
  });
}
