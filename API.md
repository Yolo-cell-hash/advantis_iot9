# API Documentation

## AdvantisIoTModule

The main module class providing access to all IoT functionality.

### Static Methods

#### `Future<void> initialize()`
Initializes the module and required services (Firebase, etc.).
Must be called before using any other module functionality.

```dart
await AdvantisIoTModule.initialize();
```

#### `bool get isInitialized`
Returns whether the module has been initialized.

#### `Widget createApp({String? initialRoute, Map<String, WidgetBuilder>? additionalRoutes})`
Creates a complete MaterialApp with all IoT screens and routing configured.

```dart
return AdvantisIoTModule.createApp(
  initialRoute: '/home',
  additionalRoutes: {
    '/custom': (context) => CustomScreen(),
  },
);
```

#### `Widget withProvider(Widget child)`
Wraps any widget with the required AppState provider.

```dart
AdvantisIoTModule.withProvider(CustomWidget())
```

#### Screen Getters
Individual screen widgets:
- `Widget splashScreen()` - App initialization screen
- `Widget homeScreen()` - Main IoT control interface  
- `Widget landingScreen()` - Navigation landing page
- `Widget onboardingScreen()` - User setup flow
- `Widget settingsScreen()` - Configuration settings

## AppState

Provider-based state management for the IoT module.

### Properties
- `String phoneNumber` - User phone number
- `String accessToken` - Authentication token
- `String lockID` - Device lock identifier
- `bool spinner` - Loading state indicator
- `bool otpSent` - OTP verification state
- `dynamic otp` - OTP value
- `dynamic update` - Device update data
- `dynamic isWindowOpen` - Window sensor state
- `dynamic isFire` - Fire sensor state  
- `dynamic lightsStatus` - Light control state

### Usage
```dart
Consumer<AppState>(
  builder: (context, appState, child) {
    return Text('Device Status: ${appState.update}');
  },
)

// Or using Provider.of
final appState = Provider.of<AppState>(context);
appState.phoneNumber = '+1234567890';
```

## WebApi

Utility class for API communication and Firebase integration.

### Key Methods
- Network API calls for device control
- Firebase real-time database integration
- Device state synchronization
- Push notification handling

## Screen Classes

### HomeScreen
Main IoT device control interface with real-time monitoring.

**Features:**
- Device status cards
- Control buttons for lights, locks, etc.
- Real-time Firebase data updates
- Weather integration
- Navigation menu

### LandingScreen  
Landing page with navigation options and device overview.

### OnboardingScreen
User onboarding flow with Bluetooth setup and device pairing.

### SettingsScreen
Configuration screen for device and app settings.

### SplashScreen
App initialization screen with branding and loading.

## Widget Classes

### RoomInfoCard
Reusable card component for displaying device/room status.

**Props:**
- Device information
- Status indicators  
- Control actions

### BrandLogoName
Company branding component with logo and name.

### ConfigTiles
Configuration option tiles for settings screens.

### IpPortTextfield
Network configuration input fields for IP and port settings.

### MenuWidget
Navigation menu component with options and user actions.

### BlePromptStack
Bluetooth Low Energy setup and pairing prompts.

## Usage Examples

### Basic Integration
```dart
void main() async {
  await AdvantisIoTModule.initialize();
  runApp(AdvantisIoTModule.createApp());
}
```

### Custom Integration
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: AdvantisIoTModule.withProvider(
          AdvantisIoTModule.homeScreen(),
        ),
      ),
    );
  }
}
```

### State Management
```dart
// Access state anywhere in the widget tree
final appState = Provider.of<AppState>(context, listen: false);

// Update device status
appState.setUpdates({'temperature': 22.5, 'lights': 'on'});

// Listen to changes
Consumer<AppState>(
  builder: (context, state, child) {
    return Text('Temperature: ${state.update['temperature']}°C');
  },
)
```