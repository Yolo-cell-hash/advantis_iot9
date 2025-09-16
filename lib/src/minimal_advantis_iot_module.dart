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

  /// Update IoT state from external data
  /// 
  /// Allows Android app to update state directly.
  static void updateState(Map<String, dynamic> data) {
    _ensureInitialized();
    _stateManager!.updateFromMap(data);
  }

  /// Write data to Firebase (device control)
  /// 
  /// Controls IoT devices by writing to Firebase.
  static Future<void> controlDevice(String devicePath, dynamic value) async {
    _ensureInitialized();
    await MinimalFirebaseService.instance.writeData(devicePath, value);
  }

  /// Read data from Firebase
  /// 
  /// Reads current device state from Firebase.
  static Future<dynamic> readDeviceData(String devicePath) async {
    _ensureInitialized();
    return await MinimalFirebaseService.instance.readData(devicePath);
  }

  /// Get the IoT state manager instance
  /// 
  /// Provides access to the state manager for listening to changes.
  static IoTStateManager get stateManager {
    _ensureInitialized();
    return _stateManager!;
  }

  /// Check if module is initialized
  static bool get isInitialized => _initialized;

  /// Check if Firebase streams are active
  static bool get isMonitoring => 
      _initialized && MinimalFirebaseService.instance.streamsActive;

  // === SCREEN FACTORY METHODS ===
  // These methods create independent screens that can be used standalone

  /// Create IoT Status Screen - Independent screen for viewing device status
  /// 
  /// [autoConnectFirebase] - Whether to automatically start Firebase monitoring
  /// [onFireAlert] - Callback when fire is detected
  /// [onWindowAlert] - Callback when window is opened
  /// [onLightsChanged] - Callback when lights status changes
  static Widget createStatusScreen({
    bool autoConnectFirebase = true,
    VoidCallback? onFireAlert,
    VoidCallback? onWindowAlert,
    VoidCallback? onLightsChanged,
  }) {
    _ensureInitialized();
    return ChangeNotifierProvider.value(
      value: _stateManager!,
      child: MinimalIoTStatusScreen(
        autoConnectFirebase: autoConnectFirebase,
        onFireAlert: onFireAlert,
        onWindowAlert: onWindowAlert,
        onLightsChanged: onLightsChanged,
      ),
    );
  }

  /// Create IoT Control Screen - Independent screen for controlling devices
  /// 
  /// [autoConnectFirebase] - Whether to automatically start Firebase monitoring
  /// [onControlAction] - Callback when a control action is performed
  static Widget createControlScreen({
    bool autoConnectFirebase = true,
    Function(String, dynamic)? onControlAction,
  }) {
    _ensureInitialized();
    return ChangeNotifierProvider.value(
      value: _stateManager!,
      child: MinimalIoTControlScreen(
        autoConnectFirebase: autoConnectFirebase,
        onControlAction: onControlAction,
      ),
    );
  }

  /// Create IoT Dashboard Widget - Compact widget for embedding
  /// 
  /// [onTap] - Callback when dashboard is tapped
  /// [showTitle] - Whether to show the title
  /// [padding] - Padding around the dashboard
  static Widget createDashboard({
    VoidCallback? onTap,
    bool showTitle = true,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    _ensureInitialized();
    return ChangeNotifierProvider.value(
      value: _stateManager!,
      child: MinimalIoTDashboard(
        onTap: onTap,
        showTitle: showTitle,
        padding: padding,
      ),
    );
  }

  /// Create a Material App with IoT Status Screen as home
  /// 
  /// Useful for testing or standalone Flutter apps.
  static Widget createApp({
    String title = 'Minimal IoT Monitor',
    ThemeData? theme,
  }) {
    _ensureInitialized();
    
    return ChangeNotifierProvider.value(
      value: _stateManager!,
      child: MaterialApp(
        title: title,
        theme: theme ?? ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: MinimalIoTStatusScreen(),
        routes: {
          '/status': (context) => MinimalIoTStatusScreen(),
          '/control': (context) => MinimalIoTControlScreen(),
        },
      ),
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

  /// Register listener for state changes (for Android callbacks)
  static void addStateListener(VoidCallback listener) {
    _ensureInitialized();
    _stateManager!.addListener(listener);
  }

  /// Remove listener for state changes
  static void removeStateListener(VoidCallback listener) {
    if (_initialized) {
      _stateManager!.removeListener(listener);
    }
  }

  /// Reset all IoT states
  static void resetState() {
    if (_initialized) {
      _stateManager!.reset();
    }
  }

  /// Dispose of all resources
  static void dispose() {
    if (_initialized) {
      MinimalFirebaseService.instance.dispose();
      _stateManager = null;
      _initialized = false;
    }
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'MinimalAdvantisIoTModule must be initialized before use. '
        'Call MinimalAdvantisIoTModule.initialize() first.'
      );
    }
  }
}