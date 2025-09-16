import 'package:flutter_test/flutter_test.dart';
import 'package:advantis_iot/advantis_iot.dart';

void main() {
  group('Advantis IoT Core Module Tests', () {
    test('CoreIoTModule initialization should work', () async {
      // Test that the module can be initialized
      expect(CoreIoTModule.isInitialized, false);
      
      // Initialize the module
      await CoreIoTModule.initialize();
      
      // Check if initialized
      expect(CoreIoTModule.isInitialized, true);
      
      // Cleanup
      CoreIoTModule.dispose();
    });

    test('CoreIoTModule state management should work', () async {
      // Initialize module
      await CoreIoTModule.initialize();
      
      // Get initial state
      final initialState = CoreIoTModule.getCurrentIoTState();
      expect(initialState, isA<Map<String, dynamic>>());
      
      // Update state
      CoreIoTModule.updateIoTState(
        isFire: true,
        isWindowOpen: false,
        lightsStatus: true,
      );
      
      // Get updated state
      final updatedState = CoreIoTModule.getCurrentIoTState();
      expect(updatedState['isFire'], true);
      expect(updatedState['isWindowOpen'], false);
      expect(updatedState['lightsStatus'], true);
      
      // Cleanup
      CoreIoTModule.dispose();
    });

    test('AppState singleton should work correctly', () {
      final appState1 = AppState.instance;
      final appState2 = AppState.instance;
      
      // Should be the same instance
      expect(identical(appState1, appState2), true);
      
      // Test state updates
      appState1.isFire = true;
      expect(appState2.isFire, true);
      
      appState1.isWindowOpen = false;
      expect(appState2.isWindowOpen, false);
    });

    test('AppState map conversion should work', () {
      final appState = AppState.instance;
      
      // Set some test data
      appState.isFire = true;
      appState.isWindowOpen = false;
      appState.lightsStatus = true;
      appState.phoneNumber = '+1234567890';
      
      // Convert to map
      final map = appState.toMap();
      expect(map['isFire'], true);
      expect(map['isWindowOpen'], false);
      expect(map['lightsStatus'], true);
      expect(map['phoneNumber'], '+1234567890');
      
      // Test updateFromMap
      appState.updateFromMap({
        'isFire': false,
        'isWindowOpen': true,
        'lightsStatus': false,
        'phoneNumber': '+9876543210',
      });
      
      expect(appState.isFire, false);
      expect(appState.isWindowOpen, true);
      expect(appState.lightsStatus, false);
      expect(appState.phoneNumber, '+9876543210');
    });
  });

  group('Legacy Module Tests', () {
    test('AdvantisIoTModule initialization should work', () async {
      // Test backward compatibility
      expect(AdvantisIoTModule.isInitialized, false);
      
      // Initialize the module
      await AdvantisIoTModule.initialize();
      
      // Check if initialized
      expect(AdvantisIoTModule.isInitialized, true);
      
      // Test state access
      final sharedState = AdvantisIoTModule.sharedState;
      expect(sharedState, isA<AppState>());
      
      // Test state map access
      final currentState = AdvantisIoTModule.getCurrentState();
      expect(currentState, isA<Map<String, dynamic>>());
      
      // Cleanup
      AdvantisIoTModule.dispose();
    });
  });
}