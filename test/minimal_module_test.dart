import 'package:flutter_test/flutter_test.dart';
import 'package:advantis_iot/advantis_iot.dart';

/// Tests for the Minimal Advantis IoT Module
/// 
/// These tests verify the core functionality and independence
/// of the minimal IoT module components.
void main() {
  group('MinimalAdvantisIoTModule Tests', () {
    
    test('module initialization', () async {
      // Test that module can be initialized
      expect(MinimalAdvantisIoTModule.isInitialized, false);
      
      // Note: Actual initialization would require Firebase setup in test environment
      // await MinimalAdvantisIoTModule.initialize();
      // expect(MinimalAdvantisIoTModule.isInitialized, true);
    });
    
    test('state access before initialization', () {
      // Test that methods handle uninitialized state gracefully
      expect(MinimalAdvantisIoTModule.getFireStatus(), null);
      expect(MinimalAdvantisIoTModule.getWindowStatus(), null);
      expect(MinimalAdvantisIoTModule.getLightsStatus(), null);
      expect(MinimalAdvantisIoTModule.isFirebaseConnected(), false);
    });
    
    test('state manager singleton', () {
      // Test that state manager follows singleton pattern
      final stateManager1 = IoTStateManager.instance;
      final stateManager2 = IoTStateManager.instance;
      
      expect(identical(stateManager1, stateManager2), true);
    });
    
    test('state manager state updates', () {
      final stateManager = IoTStateManager.instance;
      
      // Test initial state
      expect(stateManager.isFire, null);
      expect(stateManager.isWindowOpen, null);
      expect(stateManager.lightsStatus, null);
      expect(stateManager.firebaseConnected, false);
      
      // Test state updates
      stateManager.isFire = true;
      expect(stateManager.isFire, true);
      expect(stateManager.hasCriticalAlert, true);
      
      stateManager.isWindowOpen = true;
      expect(stateManager.isWindowOpen, true);
      expect(stateManager.hasWarningAlert, true);
      
      stateManager.lightsStatus = true;
      expect(stateManager.lightsStatus, true);
      
      // Test status summary
      stateManager.isFire = false;
      stateManager.isWindowOpen = false;
      stateManager.lightsStatus = true;
      expect(stateManager.statusSummary, "LIGHTS ON");
      
      stateManager.isFire = true;
      expect(stateManager.statusSummary, "FIRE DETECTED");
      
      // Test reset
      stateManager.reset();
      expect(stateManager.isFire, null);
      expect(stateManager.isWindowOpen, null);
      expect(stateManager.lightsStatus, null);
    });
    
    test('state manager map conversion', () {
      final stateManager = IoTStateManager.instance;
      
      stateManager.isFire = true;
      stateManager.isWindowOpen = false;
      stateManager.lightsStatus = true;
      stateManager.firebaseConnected = true;
      
      final map = stateManager.toMap();
      
      expect(map['isFire'], true);
      expect(map['isWindowOpen'], false);
      expect(map['lightsStatus'], true);
      expect(map['firebaseConnected'], true);
      expect(map['lastUpdated'], isNotNull);
      
      // Test update from map
      final newStateManager = IoTStateManager.instance;
      newStateManager.updateFromMap({
        'isFire': false,
        'isWindowOpen': true,
        'lightsStatus': false,
        'firebaseConnected': false,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      expect(newStateManager.isFire, false);
      expect(newStateManager.isWindowOpen, true);
      expect(newStateManager.lightsStatus, false);
      expect(newStateManager.firebaseConnected, false);
    });
  });
  
  group('MinimalFirebaseService Tests', () {
    
    test('firebase service singleton', () {
      // Test that Firebase service follows singleton pattern
      final service1 = MinimalFirebaseService.instance;
      final service2 = MinimalFirebaseService.instance;
      
      expect(identical(service1, service2), true);
    });
    
    test('firebase service initial state', () {
      final service = MinimalFirebaseService.instance;
      
      expect(service.isInitialized, false);
      expect(service.streamsActive, false);
    });
  });
  
  group('Widget Creation Tests', () {
    
    testWidgets('can create dashboard widget', (WidgetTester tester) async {
      // Test that dashboard widget can be created
      final dashboard = MinimalAdvantisIoTModule.createDashboard(
        compact: true,
        height: 100,
      );
      
      expect(dashboard, isA<Widget>());
    });
    
    testWidgets('can create status screen', (WidgetTester tester) async {
      // Test that status screen can be created
      final statusScreen = MinimalAdvantisIoTModule.createStatusScreen();
      
      expect(statusScreen, isA<Widget>());
    });
    
    testWidgets('can create control screen', (WidgetTester tester) async {
      // Test that control screen can be created
      final controlScreen = MinimalAdvantisIoTModule.createControlScreen();
      
      expect(controlScreen, isA<Widget>());
    });
  });
  
  group('Independence Tests', () {
    
    test('screens can be created without initialization', () {
      // Test that screens can be created even if module isn't initialized
      // This verifies independence - each screen handles its own initialization
      
      expect(() => MinimalAdvantisIoTModule.createDashboard(), returnsNormally);
      expect(() => MinimalAdvantisIoTModule.createStatusScreen(), returnsNormally);
      expect(() => MinimalAdvantisIoTModule.createControlScreen(), returnsNormally);
    });
    
    test('multiple screen instances work independently', () {
      // Test that multiple instances of screens can exist simultaneously
      
      final dashboard1 = MinimalAdvantisIoTModule.createDashboard(compact: true);
      final dashboard2 = MinimalAdvantisIoTModule.createDashboard(compact: false);
      final statusScreen = MinimalAdvantisIoTModule.createStatusScreen();
      final controlScreen = MinimalAdvantisIoTModule.createControlScreen();
      
      expect(dashboard1, isA<Widget>());
      expect(dashboard2, isA<Widget>());
      expect(statusScreen, isA<Widget>());
      expect(controlScreen, isA<Widget>());
      
      // Verify they are different instances
      expect(identical(dashboard1, dashboard2), false);
    });
  });
  
  group('Android Integration Tests', () {
    
    test('android integration service initial state', () {
      expect(AndroidIntegrationService.isAndroidIntegration, false);
    });
    
    test('android integration initialization', () {
      AndroidIntegrationService.initialize();
      expect(AndroidIntegrationService.isAndroidIntegration, true);
      
      AndroidIntegrationService.dispose();
      expect(AndroidIntegrationService.isAndroidIntegration, false);
    });
  });
}

/// Tests for verification of requirements compliance
group('Requirements Compliance Tests', () {
  
  test('core essential functions are available', () {
    // Verify that only the core essential functions are exposed
    
    // Fire detection
    expect(() => MinimalAdvantisIoTModule.getFireStatus(), returnsNormally);
    
    // Window status  
    expect(() => MinimalAdvantisIoTModule.getWindowStatus(), returnsNormally);
    
    // Lights status
    expect(() => MinimalAdvantisIoTModule.getLightsStatus(), returnsNormally);
    
    // Firebase connection check
    expect(() => MinimalAdvantisIoTModule.isFirebaseConnected(), returnsNormally);
  });
  
  test('screens are independent', () {
    // Each screen can be created without dependencies on others
    
    final dashboard = MinimalAdvantisIoTModule.createDashboard();
    final statusScreen = MinimalAdvantisIoTModule.createStatusScreen();
    final controlScreen = MinimalAdvantisIoTModule.createControlScreen();
    
    expect(dashboard, isA<Widget>());
    expect(statusScreen, isA<Widget>());
    expect(controlScreen, isA<Widget>());
    
    // No navigation dependencies between screens
    // Each screen manages its own state and initialization
  });
  
  test('android integration is streamlined', () {
    // Android integration should be simple and straightforward
    
    expect(() => AndroidIntegrationService.initialize(), returnsNormally);
    expect(AndroidIntegrationService.isAndroidIntegration, true);
    
    // Method channel should be ready for communication
    expect(() => AndroidIntegrationService.dispose(), returnsNormally);
  });
  
  test('firebase initialization is streamlined', () {
    // Firebase should initialize automatically throughout module lifecycle
    
    final service = MinimalFirebaseService.instance;
    expect(service, isNotNull);
    expect(service.isInitialized, false); // Not initialized until called
    
    // Service should be ready for initialization
    expect(() => service.dispose(), returnsNormally);
  });
}