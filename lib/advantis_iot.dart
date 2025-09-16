/// Advantis IoT Flutter Module
/// 
/// A comprehensive Flutter module for IoT device control and monitoring
/// with real-time Firebase integration.
/// 
/// ## Features
/// - Real-time device monitoring
/// - Firebase integration for data synchronization
/// - User authentication and onboarding
/// - Device settings management
/// - Notification handling
/// - Dynamic state management for Android integration
/// 
/// ## Usage Options
/// 
/// ### Option 1: Full Module (Original)
/// ```dart
/// import 'package:advantis_iot/advantis_iot.dart';
/// 
/// // Initialize the full module
/// await AdvantisIoTModule.initialize();
/// 
/// // Use complete app
/// Widget app = AdvantisIoTModule.createApp();
/// 
/// // Use individual screens with automatic Firebase connection
/// Widget homeScreen = AdvantisIoTModule.homeScreen();
/// ```
/// 
/// ### Option 2: Minimal Module (For Android Integration)
/// ```dart
/// import 'package:advantis_iot/minimal_advantis_iot.dart';
/// 
/// // Initialize minimal module
/// await MinimalAdvantisIoTModule.initialize(enableAndroidIntegration: true);
/// 
/// // Create independent screens
/// Widget statusScreen = MinimalAdvantisIoTModule.createStatusScreen();
/// Widget controlScreen = MinimalAdvantisIoTModule.createControlScreen();
/// Widget dashboard = MinimalAdvantisIoTModule.createDashboard();
/// 
/// // Direct device control
/// await MinimalAdvantisIoTModule.controlLights(true);
/// ```
library advantis_iot;

// Core module exports
export 'src/advantis_iot_module.dart';

// Screen exports
export 'src/screens/screens.dart';

// Widget exports
export 'src/widgets/widgets.dart';

// Utility exports
export 'src/utils/utils.dart';

// State management exports
export 'src/providers/providers.dart';

// Service exports
export 'src/services/services.dart';

// Minimal module export (for Android integration)
export 'minimal_advantis_iot.dart';