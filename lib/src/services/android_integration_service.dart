import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../advantis_iot_module.dart';

/// Android integration service for method channel communication
/// 
/// Provides bridge between Android native code and Flutter module
/// for seamless integration in existing Android applications.
class AndroidIntegrationService {
  static const MethodChannel _channel = MethodChannel('advantis_iot/navigation');
  static const MethodChannel _dataChannel = MethodChannel('advantis_iot/data');
  
  static bool _initialized = false;
  
  /// Initialize method channel handlers
  static void initialize() {
    if (_initialized) return;
    
    _channel.setMethodCallHandler(_handleNavigationCall);
    _dataChannel.setMethodCallHandler(_handleDataCall);
    
    _initialized = true;
  }
  
  /// Handle navigation method calls from Android
  static Future<dynamic> _handleNavigationCall(MethodCall call) async {
    try {
      switch (call.method) {
        case 'openHomeScreen':
          // Android can trigger navigation to home screen
          return {'success': true, 'screen': 'home'};
          
        case 'openSettingsScreen':
          // Android can trigger navigation to settings screen
          return {'success': true, 'screen': 'settings'};
          
        case 'openLandingScreen':
          // Android can trigger navigation to landing screen
          return {'success': true, 'screen': 'landing'};
          
        case 'getCurrentRoute':
          // Return current route information
          return {'route': 'current_route'};
          
        default:
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            details: 'Navigation method ${call.method} not implemented',
          );
      }
    } catch (e) {
      throw PlatformException(
        code: 'ERROR',
        message: 'Error handling navigation call: $e',
      );
    }
  }
  
  /// Handle data method calls from Android
  static Future<dynamic> _handleDataCall(MethodCall call) async {
    try {
      if (!AdvantisIoTModule.isInitialized) {
        throw PlatformException(
          code: 'NOT_INITIALIZED',
          message: 'AdvantisIoT module not initialized',
        );
      }
      
      switch (call.method) {
        case 'getCurrentState':
          // Return current app state
          return AdvantisIoTModule.getCurrentState();
          
        case 'updateState':
          // Update state from Android
          final data = call.arguments as Map<String, dynamic>?;
          if (data != null) {
            AdvantisIoTModule.updateState(data);
            return {'success': true};
          }
          throw PlatformException(
            code: 'INVALID_ARGUMENTS',
            message: 'State data is required',
          );
          
        case 'startFirebaseStreams':
          // Start Firebase streams (requires context)
          return {'success': true, 'message': 'Firebase streams started'};
          
        case 'stopFirebaseStreams':
          // Stop Firebase streams
          AdvantisIoTModule.stopFirebaseStreams();
          return {'success': true, 'message': 'Firebase streams stopped'};
          
        case 'writeFirebaseData':
          // Write data to Firebase
          final path = call.arguments['path'] as String?;
          final value = call.arguments['value'];
          
          if (path != null) {
            await AdvantisIoTModule.writeFirebaseData(path, value);
            return {'success': true, 'path': path};
          }
          throw PlatformException(
            code: 'INVALID_ARGUMENTS',
            message: 'Path is required for Firebase write',
          );
          
        case 'readFirebaseData':
          // Read data from Firebase
          final path = call.arguments['path'] as String?;
          
          if (path != null) {
            final data = await AdvantisIoTModule.readFirebaseData(path);
            return {'success': true, 'data': data, 'path': path};
          }
          throw PlatformException(
            code: 'INVALID_ARGUMENTS',
            message: 'Path is required for Firebase read',
          );
          
        default:
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            details: 'Data method ${call.method} not implemented',
          );
      }
    } catch (e) {
      throw PlatformException(
        code: 'ERROR',
        message: 'Error handling data call: $e',
      );
    }
  }
  
  /// Send state update to Android
  static void sendStateUpdate(Map<String, dynamic> state) {
    try {
      _dataChannel.invokeMethod('onStateChanged', state);
    } catch (e) {
      print('Error sending state update to Android: $e');
    }
  }
  
  /// Send navigation event to Android
  static void sendNavigationEvent(String event, Map<String, dynamic>? data) {
    try {
      _channel.invokeMethod('onNavigationEvent', {
        'event': event,
        'data': data,
      });
    } catch (e) {
      print('Error sending navigation event to Android: $e');
    }
  }
  
  /// Send alert to Android
  static void sendAlert(String type, String title, String message) {
    try {
      _dataChannel.invokeMethod('onAlert', {
        'type': type,
        'title': title,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending alert to Android: $e');
    }
  }
  
  /// Send Firebase connection status to Android
  static void sendFirebaseStatus(bool connected) {
    try {
      _dataChannel.invokeMethod('onFirebaseStatusChanged', {
        'connected': connected,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending Firebase status to Android: $e');
    }
  }
  
  /// Request permission from Android
  static Future<bool> requestPermission(String permission) async {
    try {
      final result = await _channel.invokeMethod('requestPermission', {
        'permission': permission,
      });
      return result['granted'] == true;
    } catch (e) {
      print('Error requesting permission from Android: $e');
      return false;
    }
  }
  
  /// Check if running in Android integration mode
  static bool get isAndroidIntegration => _initialized;
}