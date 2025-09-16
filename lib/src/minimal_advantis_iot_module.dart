import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/core.dart';
import 'minimal_screens/minimal_screens.dart';
import 'services/android_integration_service.dart';

/// Minimal Advantis IoT Module
/// 
/// Provides essential IoT monitoring functionality with Firebase integration.
/// Designed for seamless integration into existing Android applications.
/// 
/// Core features:
/// - Fire detection monitoring
/// - Window status monitoring  
/// - Lights status monitoring
/// - Real-time Firebase synchronization
/// - Android method channel communication
/// - Independent screen components
class MinimalAdvantisIoTModule {
  static bool _initialized = false;
  static IoTStateManager? _stateManager;
  static List<VoidCallback> _stateListeners = [];

  /// Initialize the minimal IoT module
  /// 
  /// Must be called before using any module functionality.
  /// Initializes Firebase and core services for IoT monitoring.
  static Future<void> initialize({
    bool enableAndroidIntegration = false,
  }) async {
    if (_initialized) return;
    
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      // Initialize Firebase service
      await MinimalFirebaseService.instance.initialize();
      
      // Initialize shared state manager
      _stateManager = IoTStateManager.instance;
      
      // Initialize Android integration if requested
      if (enableAndroidIntegration) {
        AndroidIntegrationService.initialize();
      }
      
      _initialized = true;
      print('Minimal Advantis IoT module initialized successfully');
      
    } catch (e) {
      print('Error initializing Minimal Advantis IoT module: $e');
      throw e;
    }
  }

  /// Start Firebase data streams for IoT monitoring
  /// 
  /// Begins real-time monitoring of fire, window, and lights status.
  static Future<void> startMonitoring() async {
    _ensureInitialized();
    await MinimalFirebaseService.instance.startCoreDataStreams();
  }

  /// Stop Firebase data streams
  /// 
  /// Stops real-time monitoring to save resources.
  static void stopMonitoring() {
    if (_initialized) {
      MinimalFirebaseService.instance.stopCoreDataStreams();
    }
  }

  /// Get current IoT state as Map for external access
  /// 
  /// Returns current fire, window, and lights status for Android integration.
  static Map<String, dynamic> getCurrentState() {
    _ensureInitialized();
    return _stateManager!.toMap();
  }

  /// Add state change listener
  /// 
  /// Callback will be called whenever IoT state changes.
  static void addStateListener(VoidCallback listener) {
    _ensureInitialized();
    _stateListeners.add(listener);
    _stateManager!.addListener(listener);
  }

  /// Remove state change listener
  static void removeStateListener(VoidCallback listener) {
    if (_initialized && _stateManager != null) {
      _stateListeners.remove(listener);
      _stateManager!.removeListener(listener);
    }
  }

  /// Control a device (lights or window)
  /// 
  /// Sends control command to Firebase for device state change.
  static Future<void> controlDevice(String deviceType, bool state) async {
    _ensureInitialized();
    await MinimalFirebaseService.instance.controlDevice(deviceType, state);
  }

  // === SCREEN CREATION METHODS ===

  /// Create minimal IoT status screen
  /// 
  /// Returns independent screen for viewing real-time IoT status.
  static Widget createStatusScreen({
    Function(Map<String, dynamic>)? onStateChanged,
    VoidCallback? onNavigationRequested,
  }) {
    return MinimalIoTStatusScreen(
      onStateChanged: onStateChanged,
      onNavigationRequested: onNavigationRequested,
    );
  }

  /// Create minimal IoT control screen
  /// 
  /// Returns independent screen for controlling IoT devices.
  static Widget createControlScreen({
    Function(String action, bool value)? onControlAction,
    VoidCallback? onNavigationRequested,
  }) {
    return MinimalIoTControlScreen(
      onControlAction: onControlAction,
      onNavigationRequested: onNavigationRequested,
    );
  }

  /// Create minimal IoT dashboard widget
  /// 
  /// Returns compact widget that can be embedded anywhere.
  static Widget createDashboard({
    VoidCallback? onTap,
    Function(Map<String, dynamic>)? onStateChanged,
    bool compact = false,
    double? height,
  }) {
    return MinimalIoTDashboard(
      onTap: onTap,
      onStateChanged: onStateChanged,
      compact: compact,
      height: height,
    );
  }

  /// Create any screen with provider wrapper
  /// 
  /// Wraps a widget with the IoT state provider for proper functionality.
  static Widget withProvider(Widget child) {
    _ensureInitialized();
    return ChangeNotifierProvider.value(
      value: _stateManager!,
      child: child,
    );
  }

  // === CONVENIENCE METHODS FOR ANDROID INTEGRATION ===

  /// Quick method to get specific device status
  static bool? getFireStatus() {
    if (!_initialized) return null;
    return _stateManager!.isFire;
  }

  /// Quick method to get window status
  static bool? getWindowStatus() {
    if (!_initialized) return null;
    return _stateManager!.isWindowOpen;
  }

  /// Quick method to get lights status
  static bool? getLightsStatus() {
    if (!_initialized) return null;
    return _stateManager!.lightsStatus;
  }

  /// Quick method to check Firebase connection status
  static bool isFirebaseConnected() {
    if (!_initialized) return false;
    return _stateManager!.firebaseConnected;
  }

  /// Quick method to control lights
  static Future<void> controlLights(bool turnOn) async {
    await controlDevice('lights', turnOn);
  }

  /// Quick method to control window
  static Future<void> controlWindow(bool open) async {
    await controlDevice('windowOpen', open);
  }

  /// Get status summary string
  static String getStatusSummary() {
    if (!_initialized) return 'Not initialized';
    return _stateManager!.statusSummary;
  }

  /// Check if there are any active alerts
  static bool hasActiveAlerts() {
    if (!_initialized) return false;
    return _stateManager!.hasCriticalAlert || _stateManager!.hasWarningAlert;
  }

  /// Check if module is initialized
  static bool get isInitialized => _initialized;

  /// Dispose the module and cleanup resources
  static void dispose() {
    if (_initialized) {
      MinimalFirebaseService.instance.dispose();
      AndroidIntegrationService.dispose();
      
      // Clear listeners
      for (var listener in _stateListeners) {
        _stateManager?.removeListener(listener);
      }
      _stateListeners.clear();
      
      _initialized = false;
      _stateManager = null;
      
      print('Minimal Advantis IoT module disposed');
    }
  }

  /// Internal method to ensure module is initialized
  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('Minimal Advantis IoT module must be initialized before use. Call MinimalAdvantisIoTModule.initialize() first.');
    }
  }
}