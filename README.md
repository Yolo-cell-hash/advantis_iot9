# Advantis IoT Flutter Module

A comprehensive Flutter module for IoT device control and monitoring with real-time Firebase integration.

## Features

- **Real-time device monitoring** - Monitor IoT devices with live updates
- **Firebase integration** - Real-time data synchronization and push notifications  
- **User authentication** - Secure onboarding and user management
- **Device settings** - Configure and manage IoT device settings
- **Multi-platform support** - Works on iOS and Android

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  advantis_iot:
    path: ../path/to/advantis_iot  # or use git/pub.dev
```

## Usage

### Basic Setup

```dart
import 'package:advantis_iot/advantis_iot.dart';

void main() async {
  // Initialize the module before use
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
import 'package:advantis_iot/advantis_iot.dart';

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

### Available Screens

- **SplashScreen** - App initialization screen
- **HomeScreen** - Main IoT device control interface
- **LandingScreen** - Landing page with navigation
- **OnboardingScreen** - User onboarding flow
- **SettingsScreen** - Device and app settings

### Available Widgets

- **BrandLogoName** - Company branding component
- **RoomInfoCard** - Device/room status display
- **ConfigTiles** - Configuration option tiles
- **IpPortTextfield** - Network configuration input
- **MenuWidget** - Navigation menu
- **BlePromptStack** - Bluetooth setup prompts

### State Management

The module uses Provider for state management. Access app state:

```dart
import 'package:provider/provider.dart';
import 'package:advantis_iot/advantis_iot.dart';

// Access state in widgets
Consumer<AppState>(
  builder: (context, appState, child) {
    return Text('Device Status: ${appState.update}');
  },
)
```

## Module Structure

```
lib/
├── advantis_iot.dart              # Main module export
├── src/
│   ├── advantis_iot_module.dart   # Core module class
│   ├── screens/                   # UI screens
│   │   ├── screens.dart           # Screen exports
│   │   ├── home_screen.dart
│   │   ├── landing_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── settings_screen.dart
│   │   └── splash_screen.dart
│   ├── widgets/                   # Reusable components
│   │   ├── widgets.dart           # Widget exports
│   │   └── ...
│   ├── utils/                     # Utilities
│   │   ├── utils.dart             # Utility exports
│   │   ├── app_state.dart         # State management
│   │   └── web_api_brain.dart     # API integration
│   └── providers/                 # State providers
│       └── providers.dart         # Provider exports
```

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
