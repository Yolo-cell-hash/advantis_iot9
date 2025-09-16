# Changelog

All notable changes to the Advantis IoT Flutter module will be documented in this file.

## [1.0.0] - 2024-09-16

### Added
- **Initial module release** - Converted Flutter app to reusable module
- **AdvantisIoTModule** class - Main module interface with initialization and screen access
- **Modular architecture** - Organized code into screens, widgets, utils, and providers
- **Comprehensive documentation** - README with usage examples and API documentation
- **Example integration** - Sample code showing how to use the module
- **Provider-based state management** - Centralized app state using Provider pattern

### Features
- 🏠 **HomeScreen** - Main IoT device control interface with real-time updates
- 🚀 **SplashScreen** - App initialization and branding screen  
- 👋 **OnboardingScreen** - User onboarding flow with BLE setup
- 🏞️ **LandingScreen** - Landing page with navigation options
- ⚙️ **SettingsScreen** - Device and app configuration settings

### Widgets
- **RoomInfoCard** - Device status and control cards
- **BrandLogoName** - Company branding component
- **ConfigTiles** - Configuration option tiles
- **IpPortTextfield** - Network configuration inputs
- **MenuWidget** - Navigation menu component
- **BlePromptStack** - Bluetooth setup prompts

### Utilities
- **AppState** - Centralized state management with Provider
- **WebApiBrain** - API communication and data handling
- Firebase integration for real-time data synchronization
- Push notification support

### Module Structure
```
lib/
├── advantis_iot.dart              # Main module export
├── src/
│   ├── advantis_iot_module.dart   # Core module class
│   ├── screens/                   # UI screens
│   ├── widgets/                   # Reusable components  
│   ├── utils/                     # Utilities and helpers
│   └── providers/                 # State management
```

### Breaking Changes
- Converted from standalone app to Flutter module
- Changed package structure - all imports now use relative paths
- Main app functionality moved to `AdvantisIoTModule` class
- Added initialization requirement via `AdvantisIoTModule.initialize()`

### Dependencies
- Flutter SDK 3.7.2+
- Firebase Core & Database for real-time data
- Provider for state management
- HTTP for API communication
- Various UI packages (Lottie, animations, etc.)

### Usage
```dart
// Initialize the module
await AdvantisIoTModule.initialize();

// Use complete app
AdvantisIoTModule.createApp()

// Use individual screens
AdvantisIoTModule.homeScreen()
```