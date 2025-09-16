import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/services.dart';
import 'utils/app_state.dart';

/// Lightweight Core IoT Module for essential monitoring functionality
/// 
/// This module provides only the core features needed for IoT monitoring:
/// - Real-time Firebase monitoring of isFire, isWindowOpen, lightsStatus
/// - State management and Android integration
/// - Independent screen components
/// - Minimal dependencies and lightweight integration
class CoreIoTModule {
  static bool _initialized = false;
  static AppState? _sharedAppState;

  /// Initialize the Core IoT module with minimal setup
  /// 
  /// Only initializes essential services for IoT monitoring.
  /// Set [enableAndroidIntegration] to true for native Android integration.
  static Future<void> initialize({bool enableAndroidIntegration = false}) async {
    if (_initialized) return;
    
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase service
    await FirebaseService.instance.initialize();
    
    // Initialize shared app state
    _sharedAppState = AppState.instance;
    
    // Initialize Android integration if requested
    if (enableAndroidIntegration) {
      AndroidIntegrationService.initialize();
    }
    
    _initialized = true;
  }

  /// Check if module is initialized
  static bool get isInitialized => _initialized;

  /// Get shared app state instance for external access
  static AppState get sharedState {
    assert(_initialized, 'Core IoT Module must be initialized before accessing shared state');
    return _sharedAppState!;
  }

  /// Create a provider-wrapped widget for any Flutter widget
  /// 
  /// Use this to wrap your own custom screens or widgets with IoT state management
  static Widget wrapWithProvider(Widget child, {bool autoStartFirebase = true}) {
    assert(_initialized, 'Core IoT Module must be initialized before wrapping widgets');
    
    return ChangeNotifierProvider.value(
      value: _sharedAppState!,
      child: autoStartFirebase 
        ? _FirebaseAutoConnectWrapper(child: child)
        : child,
    );
  }

  /// Start Firebase monitoring manually
  /// 
  /// Begins real-time monitoring of:
  /// - isFire: Fire detection status
  /// - isWindowOpen: Window breach status  
  /// - lightsStatus: Light control status
  static Future<void> startFirebaseMonitoring(BuildContext context) async {
    assert(_initialized, 'Core IoT Module must be initialized before starting Firebase monitoring');
    await FirebaseService.instance.startDataStreams(context);
    _sharedAppState!.firebaseConnected = true;
  }

  /// Stop Firebase monitoring
  static void stopFirebaseMonitoring() {
    FirebaseService.instance.stopDataStreams();
    if (_sharedAppState != null) {
      _sharedAppState!.firebaseConnected = false;
    }
  }

  /// Get current IoT state as Map for external access (Android integration)
  static Map<String, dynamic> getCurrentIoTState() {
    assert(_initialized, 'Core IoT Module must be initialized before accessing state');
    return {
      'isFire': _sharedAppState!.isFire,
      'isWindowOpen': _sharedAppState!.isWindowOpen,
      'lightsStatus': _sharedAppState!.lightsStatus,
      'firebaseConnected': _sharedAppState!.firebaseConnected,
      'lastUpdated': _sharedAppState!.lastUpdated?.toIso8601String(),
    };
  }

  /// Update IoT state from external data (Android integration)
  static void updateIoTState({
    dynamic isFire,
    dynamic isWindowOpen,
    dynamic lightsStatus,
    bool? firebaseConnected,
  }) {
    assert(_initialized, 'Core IoT Module must be initialized before updating state');
    
    if (isFire != null) _sharedAppState!.isFire = isFire;
    if (isWindowOpen != null) _sharedAppState!.isWindowOpen = isWindowOpen;
    if (lightsStatus != null) _sharedAppState!.lightsStatus = lightsStatus;
    if (firebaseConnected != null) _sharedAppState!.firebaseConnected = firebaseConnected;
  }

  /// Write data to Firebase
  static Future<void> writeToFirebase(String path, dynamic value) async {
    assert(_initialized, 'Core IoT Module must be initialized before writing to Firebase');
    await FirebaseService.instance.writeData(path, value);
  }

  /// Read data from Firebase
  static Future<dynamic> readFromFirebase(String path) async {
    assert(_initialized, 'Core IoT Module must be initialized before reading from Firebase');
    return await FirebaseService.instance.readData(path);
  }

  /// Check if Android integration is enabled
  static bool get isAndroidIntegrationEnabled => AndroidIntegrationService.isAndroidIntegration;

  /// Dispose module resources
  static void dispose() {
    FirebaseService.instance.dispose();
    _sharedAppState = null;
    _initialized = false;
  }
}

/// Internal wrapper that automatically starts Firebase connection
class _FirebaseAutoConnectWrapper extends StatefulWidget {
  final Widget child;

  const _FirebaseAutoConnectWrapper({required this.child});

  @override
  State<_FirebaseAutoConnectWrapper> createState() => __FirebaseAutoConnectWrapperState();
}

class __FirebaseAutoConnectWrapperState extends State<_FirebaseAutoConnectWrapper> {
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseConnection();
  }

  Future<void> _initializeFirebaseConnection() async {
    if (!_connected && FirebaseService.instance.isInitialized) {
      try {
        await FirebaseService.instance.startDataStreams(context);
        if (mounted) {
          final appState = Provider.of<AppState>(context, listen: false);
          appState.firebaseConnected = true;
          setState(() {
            _connected = true;
          });
        }
      } catch (e) {
        print('Error starting Firebase streams: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}