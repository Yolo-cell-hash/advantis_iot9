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
/// ## Usage
/// ```dart
/// import 'package:advantis_iot/advantis_iot.dart';
/// 
/// // Initialize the module
/// await AdvantisIoTModule.initialize();
/// 
/// // Use complete app
/// Widget app = AdvantisIoTModule.createApp();
/// 
/// // Use individual screens with automatic Firebase connection
/// Widget homeScreen = AdvantisIoTModule.homeScreen();
/// 
/// // Access shared state
/// AppState state = AdvantisIoTModule.sharedState;
/// 
/// // Manual Firebase control
/// await AdvantisIoTModule.startFirebaseStreams(context);
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