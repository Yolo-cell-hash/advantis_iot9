import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:advantis_iot/minimal_advantis_iot.dart';

void main() {
  group('Minimal IoT Screens Independence Test', () {
    testWidgets('Status screen can be created independently', (WidgetTester tester) async {
      // Test that status screen can be created without module initialization
      // In real usage, Firebase would be mocked, but here we test widget creation
      
      final statusScreen = MinimalIoTStatusScreen(
        autoConnectFirebase: false, // Disable Firebase for testing
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: statusScreen,
        ),
      );
      
      // Verify screen elements are present
      expect(find.text('IoT Status'), findsOneWidget);
      expect(find.text('Initializing...'), findsOneWidget);
    });

    testWidgets('Control screen can be created independently', (WidgetTester tester) async {
      final controlScreen = MinimalIoTControlScreen(
        autoConnectFirebase: false, // Disable Firebase for testing
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: controlScreen,
        ),
      );
      
      // Verify screen elements are present
      expect(find.text('IoT Control'), findsOneWidget);
      expect(find.text('Initializing...'), findsOneWidget);
    });

    testWidgets('Dashboard widget can be created independently', (WidgetTester tester) async {
      final dashboard = MinimalIoTDashboard(
        showTitle: true,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: dashboard,
          ),
        ),
      );
      
      // Verify dashboard elements are present
      expect(find.text('IoT Status'), findsOneWidget);
      expect(find.text('Fire'), findsOneWidget);
      expect(find.text('Window'), findsOneWidget);
      expect(find.text('Lights'), findsOneWidget);
    });

    testWidgets('Multiple screens can exist simultaneously', (WidgetTester tester) async {
      // Test that multiple screens can be created and work independently
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(text: 'Status'),
                    Tab(text: 'Control'),
                    Tab(text: 'Dashboard'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  MinimalIoTStatusScreen(autoConnectFirebase: false),
                  MinimalIoTControlScreen(autoConnectFirebase: false),
                  MinimalIoTDashboard(),
                ],
              ),
            ),
          ),
        ),
      );
      
      // Verify all tabs are present
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Control'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      
      // Tap on control tab
      await tester.tap(find.text('Control'));
      await tester.pumpAndSettle();
      
      // Should see control screen
      expect(find.text('IoT Control'), findsOneWidget);
      
      // Tap on dashboard tab
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      
      // Should see dashboard
      expect(find.text('MONITORING...'), findsOneWidget);
    });
  });
}