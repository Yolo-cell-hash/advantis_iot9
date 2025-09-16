/// Advantis IoT Flutter Module
/// 
/// A lightweight Flutter module for IoT device monitoring with real-time Firebase integration.
/// Designed for seamless integration into existing Android applications.
/// 
/// ## Core Features
/// - Real-time monitoring of fire detection, window status, and lights
/// - Firebase integration with automatic state synchronization
/// - Android method channel communication
/// - Independent screen components
/// - Minimal dependencies and lightweight design
/// 
/// ## Quick Start
/// ```dart
/// import 'package:advantis_iot/advantis_iot.dart';
/// 
/// // Initialize the core IoT module
/// await CoreIoTModule.initialize(enableAndroidIntegration: true);
/// 
/// // Use standalone monitoring screen
/// Widget iotScreen = StandaloneIoTScreen();
/// 
/// // Or use the dashboard widget directly
/// Widget dashboard = CoreIoTModule.wrapWithProvider(IoTMonitoringDashboard());
/// 
/// // Access current IoT state
/// Map<String, dynamic> state = CoreIoTModule.getCurrentIoTState();
/// ```
/// 
/// ## Android Integration
/// The module provides seamless Android integration through method channels.
/// See the android_example/ directory for complete integration examples.
library advantis_iot;

// Core module exports
export 'src/core_iot_module.dart';
export 'src/advantis_iot_module.dart'; // For backward compatibility

// Essential screen exports
export 'src/screens/iot_monitoring_screen.dart';
export 'src/screens/screens.dart'; // All screens

// Widget exports
export 'src/widgets/widgets.dart';

// Utility exports
export 'src/utils/utils.dart';

// State management exports
export 'src/providers/providers.dart';

// Service exports
export 'src/services/services.dart';