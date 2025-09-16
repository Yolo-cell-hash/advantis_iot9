# Advantis IoT Flutter Module - Simplified Integration

A lightweight Flutter module designed for seamless integration into existing Android applications, providing essential IoT device monitoring with real-time Firebase synchronization.

## Features

- **Real-time device monitoring** - Monitor IoT devices with live updates
- **Firebase integration** - Real-time data synchronization and push notifications  
- **User authentication** - Secure onboarding and user management
- **Device settings** - Configure and manage IoT device settings
- **Multi-platform support** - Works on iOS and Android
- **Android Integration** - Easy integration into existing Android apps
- **Dynamic state management** - Shared state across multiple screen instances
- **Method channel communication** - Native Android-Flutter communication

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  advantis_iot:
    path: ../path/to/advantis_iot  # or use git/pub.dev
```

## Quick Start

### Flutter App Integration

```dart
import 'package:advantis_iot/advantis_iot.dart';

void main() async {
  // Initialize the module (with optional Android integration)
  await AdvantisIoTModule.initialize(enableAndroidIntegration: true);
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

### Android App Integration

For integrating into existing Android applications, see the [Android Integration Guide](ANDROID_INTEGRATION.md).

```kotlin
// Android Activity
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Launch IoT screens
        startActivity(
            FlutterActivity
                .withCachedEngine("advantis_iot_engine")
                .build(this)
        )
    }
}
```

### Individual Screen Usage

```dart
import 'package:advantis_iot/advantis_iot.dart';

// Method 1: With automatic Firebase connection
Widget homeScreen = AdvantisIoTModule.homeScreen(); // Auto-connects to Firebase

// Method 2: Manual Firebase control
Widget homeScreen = AdvantisIoTModule.homeScreen(autoConnect: false);
await AdvantisIoTModule.startFirebaseStreams(context);

// Method 3: Traditional provider wrapping (legacy)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdvantisIoTModule.withProvider(
      AdvantisIoTModule.homeScreen(),
    ),
  ),
);
```

### Dynamic State Access

```dart
// Access shared state from anywhere
AppState sharedState = AdvantisIoTModule.sharedState;

// Get current state as Map (for external apps)
Map<String, dynamic> currentState = AdvantisIoTModule.getCurrentState();

// Update state from external source
AdvantisIoTModule.updateState({
  'phoneNumber': '+1234567890',
  'firebaseConnected': true,
});

// Listen to state changes
sharedState.addListener(() {
  print('State updated: ${sharedState.toMap()}');
});
```

### Firebase Integration

```dart
// Manual Firebase control
await AdvantisIoTModule.startFirebaseStreams(context);
AdvantisIoTModule.stopFirebaseStreams();

// Direct Firebase operations
await AdvantisIoTModule.writeFirebaseData('devices/device1', {'status': 'on'});
dynamic data = await AdvantisIoTModule.readFirebaseData('devices/device1');
```

### Available Screens

- **SplashScreen** - App initialization screen
- **HomeScreen** - Main IoT device control interface  
- **LandingScreen** - Landing page with navigation
- **OnboardingScreen** - User onboarding flow
- **SettingsScreen** - Device and app settings

All screens support:
- Automatic Firebase connection (configurable)
- Shared state management
- Real-time data updates
- Android method channel integration

### Available Widgets

- **BrandLogoName** - Company branding component
- **RoomInfoCard** - Device/room status display
- **ConfigTiles** - Configuration option tiles
- **IpPortTextfield** - Network configuration input
- **MenuWidget** - Navigation menu
- **BlePromptStack** - Bluetooth setup prompts

### State Management

The module uses a hybrid approach with Provider and singleton patterns for comprehensive state management:

```dart
import 'package:provider/provider.dart';
import 'package:advantis_iot/advantis_iot.dart';

// Method 1: Provider access (within widgets)
Consumer<AppState>(
  builder: (context, appState, child) {
    return Text('Device Status: ${appState.update}');
  },
)

// Method 2: Direct singleton access (external apps)
AppState state = AdvantisIoTModule.sharedState;
state.addListener(() {
  print('State changed: ${state.toMap()}');
});

// Method 3: Map-based access (Android integration)
Map<String, dynamic> stateData = AdvantisIoTModule.getCurrentState();
```

## Architecture

### Enhanced Module Structure

```
lib/
├── advantis_iot.dart              # Main module export
├── src/
│   ├── advantis_iot_module.dart   # Enhanced core module class
│   ├── services/                  # Core services (NEW)
│   │   ├── services.dart          # Service exports
│   │   ├── firebase_service.dart  # Centralized Firebase management
│   │   └── android_integration_service.dart # Android method channels
│   ├── screens/                   # UI screens
│   │   ├── screens.dart           # Screen exports
│   │   ├── home_screen.dart       # Simplified with service integration
│   │   ├── landing_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── settings_screen.dart
│   │   └── splash_screen.dart
│   ├── widgets/                   # Reusable components
│   │   ├── widgets.dart           # Widget exports
│   │   └── ...
│   ├── utils/                     # Utilities
│   │   ├── utils.dart             # Utility exports
│   │   ├── app_state.dart         # Enhanced with singleton pattern
│   │   └── web_api_brain.dart     # API integration
│   └── providers/                 # State providers
│       └── providers.dart         # Provider exports
├── ANDROID_INTEGRATION.md         # Android integration guide
└── example/                       # Enhanced example with real-time demo
```

### Key Architectural Improvements

1. **Centralized Firebase Service**: Single point for all Firebase operations
2. **Singleton State Management**: Shared state accessible across app boundaries  
3. **Android Integration Layer**: Method channels for native communication
4. **Automatic Connection Management**: Smart Firebase connection handling
5. **External State Access**: Map-based state for Android integration

## Dependencies

The module requires these dependencies:

- Flutter SDK
- Firebase Core & Database
- Provider (state management)
- HTTP (API communication)
- Lottie (animations)
- And other UI/utility packages (see pubspec.yaml)

## Configuration

### Firebase Setup

1. Add your Firebase configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

2. Configure Firebase in your main app before calling `AdvantisIoTModule.initialize()`

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
