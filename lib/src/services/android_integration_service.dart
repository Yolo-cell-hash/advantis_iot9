import 'package:flutter/services.dart';
import '../core/iot_state_manager.dart';

/// Android integration service for IoT module
/// 
/// Provides method channel communication between the Flutter module
/// and the Android app for state updates and alerts.
class AndroidIntegrationService {
  static const MethodChannel _channel = MethodChannel('advantis_iot/communication');
  static bool _androidIntegration = false;
  
  /// Check if Android integration is enabled
  static bool get isAndroidIntegration => _androidIntegration;
  
  /// Initialize Android integration
  static void initialize() {
    _androidIntegration = true;
    _channel.setMethodCallHandler(_handleMethodCall);
    print('Android integration service initialized');
  }
  
  /// Handle method calls from Android
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    print('Received method call from Android: ${call.method}');
    
    switch (call.method) {
      case 'getIoTState':
        // Return current IoT state
        return _getCurrentIoTState();
      case 'ping':
        return 'pong';
      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          details: 'Method ${call.method} not implemented',
        );
    }
  }
  
  /// Send IoT state update to Android
  static Future<void> sendStateUpdate(Map<String, dynamic> state) async {
    if (!_androidIntegration) return;
    
    try {
      await _channel.invokeMethod('onIoTStateChanged', state);
      print('State update sent to Android: $state');
    } catch (e) {
      print('Error sending state update to Android: $e');
    }
  }
  
  /// Send alert to Android
  static Future<void> sendAlert(String type, String title, String message) async {
    if (!_androidIntegration) return;
    
    try {
      final alertData = {
        'type': type,
        'title': title,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _channel.invokeMethod('onIoTAlert', alertData);
      print('Alert sent to Android: $alertData');
    } catch (e) {
      print('Error sending alert to Android: $e');
    }
  }
  
  /// Get current IoT state for Android requests
  static Map<String, dynamic> _getCurrentIoTState() {
    try {
      return IoTStateManager.instance.toMap();
    } catch (e) {
      print('Error getting IoT state: $e');
      return {
        'isFire': null,
        'isWindowOpen': null,
        'lightsStatus': null,
        'firebaseConnected': false,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Dispose Android integration
  static void dispose() {
    _androidIntegration = false;
    print('Android integration service disposed');
  }
}