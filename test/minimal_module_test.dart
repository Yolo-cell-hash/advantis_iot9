import 'package:flutter_test/flutter_test.dart';
import 'package:advantis_iot/minimal_advantis_iot.dart';

void main() {
  group('MinimalAdvantisIoTModule Tests', () {
    test('module initialization', () async {
      // Test that module can be initialized
      expect(MinimalAdvantisIoTModule.isInitialized, false);
      
      // Note: In real tests, you would mock Firebase
      // For now, just test the API structure
      expect(() => MinimalAdvantisIoTModule.getCurrentState(), throwsStateError);
    });

    test('state manager singleton', () {
      final manager1 = IoTStateManager.instance;
      final manager2 = IoTStateManager.instance;
      
      expect(manager1, same(manager2));
    });

    test('state manager initial values', () {
      final manager = IoTStateManager.instance;
      
      expect(manager.isFire, null);
      expect(manager.isWindowOpen, null);
      expect(manager.lightsStatus, null);
      expect(manager.firebaseConnected, false);
    });

    test('state manager setters', () {
      final manager = IoTStateManager.instance;
      
      manager.isFire = true;
      expect(manager.isFire, true);
      expect(manager.hasCriticalAlert, true);
      
      manager.isWindowOpen = true;
      expect(manager.isWindowOpen, true);
      expect(manager.hasWarningAlert, true);
      
      manager.isFire = false;
      manager.isWindowOpen = false;
      expect(manager.allSystemsNormal, true);
    });

    test('state manager toMap/fromMap', () {
      final manager = IoTStateManager.instance;
      
      manager.isFire = true;
      manager.isWindowOpen = false;
      manager.lightsStatus = true;
      
      final map = manager.toMap();
      expect(map['isFire'], true);
      expect(map['isWindowOpen'], false);
      expect(map['lightsStatus'], true);
      
      // Test updating from map
      manager.updateFromMap({
        'isFire': false,
        'isWindowOpen': true,
        'lightsStatus': false,
      });
      
      expect(manager.isFire, false);
      expect(manager.isWindowOpen, true);
      expect(manager.lightsStatus, false);
    });

    test('state manager reset', () {
      final manager = IoTStateManager.instance;
      
      manager.isFire = true;
      manager.isWindowOpen = true;
      manager.lightsStatus = true;
      
      manager.reset();
      
      expect(manager.isFire, null);
      expect(manager.isWindowOpen, null);
      expect(manager.lightsStatus, null);
      expect(manager.firebaseConnected, false);
    });
  });
}