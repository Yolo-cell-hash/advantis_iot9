import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/screens.dart';
import 'providers/providers.dart';
import 'services/services.dart';

/// Main module class for Advantis IoT
/// 
/// Provides centralized access to all module functionality including
/// screens, widgets, and utilities for IoT device management.
/// Enhanced for Android integration with dynamic state management.
class AdvantisIoTModule {
  static bool _initialized = false;
  static AppState? _sharedAppState;

  /// Initialize the Advantis IoT module
  /// 
  /// Must be called before using any module functionality.
  /// Initializes Firebase and other required services.
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
    assert(_initialized, 'Module must be initialized before accessing shared state');
    return _sharedAppState!;
  }

  /// Create the main app widget with provider setup
  /// 
  /// Returns a MaterialApp configured for the IoT module
  /// with all necessary providers and routing.
  static Widget createApp({
    String? initialRoute,
    Map<String, WidgetBuilder>? additionalRoutes,
  }) {
    assert(_initialized, 'Module must be initialized before creating app');
    
    final routes = <String, WidgetBuilder>{
      '/': (context) => SplashScreen(),
      '/home': (context) => HomeScreen(),
      '/settings': (context) => SettingsScreen(),
      '/landing': (context) => LandingScreen(),
      '/onboarding': (context) => OnboardingScreen(),
      ...?additionalRoutes,
    };

    return ChangeNotifierProvider.value(
      value: _sharedAppState!,
      child: MaterialApp(
        title: 'Advantis IoT',
        routes: routes,
        initialRoute: initialRoute ?? '/',
      ),
    );
  }

  /// Create individual screen widgets with automatic Firebase connection
  /// These methods ensure Firebase streams are started when screens are created
  
  /// Get splash screen widget
  static Widget splashScreen({bool autoConnect = true}) {
    return _wrapWithFirebaseConnection(SplashScreen(), autoConnect);
  }

  /// Get home screen widget with automatic Firebase connection
  static Widget homeScreen({bool autoConnect = true}) {
    return _wrapWithFirebaseConnection(HomeScreen(), autoConnect);
  }

  /// Get settings screen widget
  static Widget settingsScreen({bool autoConnect = true}) {
    return _wrapWithFirebaseConnection(SettingsScreen(), autoConnect);
  }

  /// Get landing screen widget with automatic Firebase connection
  static Widget landingScreen({bool autoConnect = true}) {
    return _wrapWithFirebaseConnection(LandingScreen(), autoConnect);
  }

  /// Get onboarding screen widget
  static Widget onboardingScreen({bool autoConnect = true}) {
    return _wrapWithFirebaseConnection(OnboardingScreen(), autoConnect);
  }

  /// Create a provider-wrapped widget with Firebase connection
  /// 
  /// Wraps any widget with the required AppState provider and
  /// optionally starts Firebase data streams
  static Widget withProvider(Widget child, {bool autoConnect = true}) {
    assert(_initialized, 'Module must be initialized before using withProvider');
    return _wrapWithFirebaseConnection(child, autoConnect);
  }

  /// Internal helper to wrap widgets with provider and Firebase connection
  static Widget _wrapWithFirebaseConnection(Widget child, bool autoConnect) {
    return ChangeNotifierProvider.value(
      value: _sharedAppState!,
      child: autoConnect 
        ? FirebaseConnectionWrapper(child: child)
        : child,
    );
  }

  /// Start Firebase data streams manually
  static Future<void> startFirebaseStreams(BuildContext context) async {
    assert(_initialized, 'Module must be initialized before starting Firebase streams');
    await FirebaseService.instance.startDataStreams(context);
    _sharedAppState!.firebaseConnected = true;
  }

  /// Stop Firebase data streams manually
  static void stopFirebaseStreams() {
    FirebaseService.instance.stopDataStreams();
    if (_sharedAppState != null) {
      _sharedAppState!.firebaseConnected = false;
    }
  }

  /// Get current state as Map for external access (Android integration)
  static Map<String, dynamic> getCurrentState() {
    assert(_initialized, 'Module must be initialized before accessing state');
    return _sharedAppState!.toMap();
  }

  /// Update state from external data (Android integration)
  static void updateState(Map<String, dynamic> data) {
    assert(_initialized, 'Module must be initialized before updating state');
    _sharedAppState!.updateFromMap(data);
  }

  /// Write data to Firebase
  static Future<void> writeFirebaseData(String path, dynamic value) async {
    assert(_initialized, 'Module must be initialized before writing Firebase data');
    await FirebaseService.instance.writeData(path, value);
  }

  /// Read data from Firebase
  static Future<dynamic> readFirebaseData(String path) async {
    assert(_initialized, 'Module must be initialized before reading Firebase data');
    return await FirebaseService.instance.readData(path);
  }

  /// Dispose module resources
  static void dispose() {
    FirebaseService.instance.dispose();
    _sharedAppState = null;
    _initialized = false;
  }
}

/// Wrapper widget that automatically starts Firebase connection
class FirebaseConnectionWrapper extends StatefulWidget {
  final Widget child;

  const FirebaseConnectionWrapper({super.key, required this.child});

  @override
  State<FirebaseConnectionWrapper> createState() => _FirebaseConnectionWrapperState();
}

class _FirebaseConnectionWrapperState extends State<FirebaseConnectionWrapper> {
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
  void dispose() {
    // Note: We don't stop streams here as they should persist
    // across individual screen lifecycles
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}