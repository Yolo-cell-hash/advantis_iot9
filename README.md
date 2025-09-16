# Advantis IoT Flutter Module

A comprehensive Flutter module for IoT device control and monitoring with real-time Firebase integration. Now featuring a **minimal module** perfect for Android app integration.

## Features

### Full Module
- **Real-time device monitoring** - Monitor IoT devices with live updates
- **Firebase integration** - Real-time data synchronization and push notifications  
- **User authentication** - Secure onboarding and user management
- **Device settings** - Configure and manage IoT device settings
- **Multi-platform support** - Works on iOS and Android

### 🎯 Minimal Module (NEW)
- **Essential IoT monitoring only** - Fire detection, window status, lights control
- **Completely independent screens** - No navigation dependencies
- **Android integration ready** - Method channels and state callbacks
- **Streamlined Firebase** - Automatic initialization and management
- **Minimal footprint** - Reduced dependencies and app size

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  advantis_iot:
    path: ../path/to/advantis_iot  # or use git/pub.dev
```

## Usage

### 🚀 Quick Start with Minimal Module

Perfect for integrating into existing Android apps:

```dart
import 'package:advantis_iot/advantis_iot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize minimal IoT module
  await MinimalAdvantisIoTModule.initialize(
    enableAndroidIntegration: true,
  );
  
  // Start monitoring
  await MinimalAdvantisIoTModule.startMonitoring();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YourExistingAppContent(),
    );
  }
}

class YourExistingAppContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your existing app content
          YourWidget(),
          
          // Embedded IoT dashboard - completely independent
          MinimalAdvantisIoTModule.createDashboard(
            compact: true,
            height: 80,
            onTap: () {
              // Navigate to full IoT screen
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MinimalAdvantisIoTModule.createStatusScreen(),
              ));
            },
          ),
          
          // More of your content
        ],
      ),
    );
  }
}
```

### 📱 Independent Screens

Each screen works completely independently:

```dart
// IoT Status Screen - completely standalone
Widget statusScreen = MinimalAdvantisIoTModule.createStatusScreen(
  onStateChanged: (state) {
    // Handle state changes in your Android app
    print('IoT state: $state');
  },
);

// IoT Control Screen - independent device control
Widget controlScreen = MinimalAdvantisIoTModule.createControlScreen(
  onControlAction: (action, value) {
    // Handle control actions
    print('Control: $action = $value');
  },
);

// Compact Dashboard - embeddable anywhere
Widget dashboard = MinimalAdvantisIoTModule.createDashboard(
  compact: true,
  onStateChanged: (state) {
    // React to IoT state changes
    if (state['isFire'] == true) {
      showFireAlert();
    }
  },
);
```

### 🔄 Real-time State Access

```dart
// Get current IoT state
Map<String, dynamic> state = MinimalAdvantisIoTModule.getCurrentState();

// Check specific device statuses
bool? fireDetected = MinimalAdvantisIoTModule.getFireStatus();
bool? windowOpen = MinimalAdvantisIoTModule.getWindowStatus();  
bool? lightsOn = MinimalAdvantisIoTModule.getLightsStatus();

// Control devices
await MinimalAdvantisIoTModule.controlLights(true);
await MinimalAdvantisIoTModule.controlWindow(false);

// Listen for state changes
MinimalAdvantisIoTModule.addStateListener(() {
  print('IoT state changed: ${MinimalAdvantisIoTModule.getCurrentState()}');
});
```

### 🏠 Full Module Usage

```dart
import 'package:advantis_iot/advantis_iot.dart';

void main() async {
  // Initialize the full module
  await AdvantisIoTModule.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use the complete module app
    return AdvantisIoTModule.createApp();
  }
}
```

### Individual Screen Usage

```dart
// Use individual screens in your navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdvantisIoTModule.withProvider(
      AdvantisIoTModule.homeScreen(),
    ),
  ),
);
```

## Module Comparison

| Feature | Full Module | Minimal Module |
|---------|-------------|----------------|
| **Use Case** | Complete IoT app | IoT monitoring widget |
| **Screens** | 6+ screens with navigation | 3 independent screens |
| **Dependencies** | Full authentication flow | Firebase + core only |
| **Size** | Full app | Essential components only |
| **Android Integration** | Complex setup | Simple method calls |
| **Independence** | Screen dependencies exist | Fully independent screens |

## Available Screens

### Full Module
- **SplashScreen** - App initialization screen
- **HomeScreen** - Main IoT device control interface
- **LandingScreen** - Landing page with navigation
- **OnboardingScreen** - User onboarding flow
- **SettingsScreen** - Device and app settings

### Minimal Module
- **MinimalIoTStatusScreen** - Real-time device status display
- **MinimalIoTControlScreen** - Device control interface
- **MinimalIoTDashboard** - Embeddable status widget

## Android Integration

### Method Channel Communication

The minimal module automatically sets up method channels for Android communication:

```kotlin
// In your Android MainActivity
class MainActivity : FlutterActivity() {
    private val CHANNEL = "advantis_iot/communication"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "onIoTStateChanged" -> {
                        val state = call.arguments as Map<String, Any>
                        handleIoTStateUpdate(state)
                        result.success(true)
                    }
                    "onIoTAlert" -> {
                        val alert = call.arguments as Map<String, Any>
                        showIoTAlert(alert)
                        result.success(true)
                    }
                }
            }
    }
}
```

## Module Structure

```
lib/
├── advantis_iot.dart              # Main module export
├── src/
│   ├── advantis_iot_module.dart   # Full module class
│   ├── minimal_advantis_iot_module.dart # Minimal module class
│   ├── core/                      # Core IoT functionality
│   │   ├── iot_state_manager.dart
│   │   ├── minimal_firebase_service.dart
│   │   └── core.dart
│   ├── minimal_screens/           # Independent minimal screens
│   │   ├── minimal_iot_status_screen.dart
│   │   ├── minimal_iot_control_screen.dart
│   │   ├── minimal_iot_dashboard.dart
│   │   └── minimal_screens.dart
│   ├── screens/                   # Full module screens
│   ├── widgets/                   # Reusable components
│   ├── services/                  # Integration services
│   │   └── android_integration_service.dart
│   ├── utils/                     # Utilities
│   └── providers/                 # State providers
```

## Quick Links

- 📖 [Minimal Integration Guide](MINIMAL_INTEGRATION.md)
- 🏗️ [Minimization Summary](MINIMIZATION_SUMMARY.md) 
- 📱 [Android Integration Guide](ANDROID_INTEGRATION.md)
- 💻 [Example Usage](example/minimal_example.dart)

## Dependencies

The module requires these dependencies:

- Flutter SDK
- Firebase Core & Database
- Provider (state management)
- HTTP (API communication)
- And other UI/utility packages (see pubspec.yaml)

## Configuration

### Firebase Setup

1. Add your Firebase configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

2. Configure Firebase in your main app before calling module initialize

### Permissions

Add required permissions for IoT functionality:

Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.BLUETOOTH" />
```

iOS (`ios/Runner/Info.plist`):
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to IoT devices</string>
```

## Contributing

1. Follow Flutter coding standards
2. Add tests for new functionality
3. Update documentation for API changes
4. Ensure backwards compatibility

## License

[Add your license information here]
