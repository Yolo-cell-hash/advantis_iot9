import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/screens.dart';
import 'providers/providers.dart';

/// Main module class for Advantis IoT
/// 
/// Provides centralized access to all module functionality including
/// screens, widgets, and utilities for IoT device management.
class AdvantisIoTModule {
  static bool _initialized = false;

  /// Initialize the Advantis IoT module
  /// 
  /// Must be called before using any module functionality.
  /// Initializes Firebase and other required services.
  static Future<void> initialize() async {
    if (_initialized) return;
    
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    _initialized = true;
  }

  /// Check if module is initialized
  static bool get isInitialized => _initialized;

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

    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Advantis IoT',
        routes: routes,
        initialRoute: initialRoute ?? '/',
      ),
    );
  }

  /// Get splash screen widget
  static Widget splashScreen() => SplashScreen();

  /// Get home screen widget
  static Widget homeScreen() => HomeScreen();

  /// Get settings screen widget
  static Widget settingsScreen() => SettingsScreen();

  /// Get landing screen widget
  static Widget landingScreen() => LandingScreen();

  /// Get onboarding screen widget
  static Widget onboardingScreen() => OnboardingScreen();

  /// Create a provider-wrapped widget
  /// 
  /// Wraps any widget with the required AppState provider
  static Widget withProvider(Widget child) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: child,
    );
  }
}