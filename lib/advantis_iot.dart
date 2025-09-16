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
/// 
/// ## Usage
/// ```dart
/// import 'package:advantis_iot/advantis_iot.dart';
/// 
/// // Initialize the module
/// AdvantisIoTModule.initialize();
/// 
/// // Use screens in your app
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => AdvantisIoTModule.homeScreen(),
/// ));
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