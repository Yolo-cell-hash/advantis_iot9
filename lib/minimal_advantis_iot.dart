/// Minimal Advantis IoT Flutter Module
/// 
/// A streamlined Flutter module for essential IoT device monitoring
/// with real-time Firebase integration, designed for seamless integration
/// into existing Android applications.
/// 
/// ## Core Features
/// - Real-time fire detection monitoring
/// - Window status monitoring  
/// - Lights status monitoring
/// - Firebase real-time database integration
/// - Android method channel communication
/// - Independent screen components
/// 
/// ## Quick Start
/// ```dart
/// import 'package:advantis_iot/minimal_advantis_iot.dart';
/// 
/// // Initialize the module
/// await MinimalAdvantisIoTModule.initialize(enableAndroidIntegration: true);
/// 
/// // Start monitoring IoT devices
/// await MinimalAdvantisIoTModule.startMonitoring();
/// 
/// // Create status screen
/// Widget statusScreen = MinimalAdvantisIoTModule.createStatusScreen();
/// 
/// // Create control screen  
/// Widget controlScreen = MinimalAdvantisIoTModule.createControlScreen();
/// 
/// // Create dashboard widget
/// Widget dashboard = MinimalAdvantisIoTModule.createDashboard();
/// 
/// // Get current state
/// Map<String, dynamic> state = MinimalAdvantisIoTModule.getCurrentState();
/// 
/// // Control devices
/// await MinimalAdvantisIoTModule.controlLights(true);
/// await MinimalAdvantisIoTModule.controlWindow(false);
/// ```
/// 
/// ## Android Integration
/// This module is designed for easy integration into existing Android apps.
/// Each screen component is completely independent and can be used without
/// dependencies on other screens.
library minimal_advantis_iot;

// Core module exports
export 'src/minimal_advantis_iot_module.dart';

// Core functionality exports
export 'src/core/core.dart';

// Screen exports
export 'src/minimal_screens/minimal_screens.dart';

// Service exports (for advanced usage)
export 'src/services/android_integration_service.dart';