# Minimal Advantis IoT Module Integration Guide

This guide shows how to integrate the **minimal** Advantis IoT Flutter module into an existing Android application. The minimal module focuses only on essential IoT monitoring functionality.

## Key Features of Minimal Module

✅ **Essential IoT Monitoring Only**
- Fire detection alerts
- Window status monitoring
- Lights status tracking
- Real-time Firebase synchronization

✅ **Completely Independent Screens**
- No navigation dependencies between screens
- Each screen can be used standalone
- Self-contained Firebase initialization

✅ **Android Integration Ready**
- Method channel communication
- State callbacks for Android app
- Easy integration APIs

✅ **Minimal Dependencies**
- Reduced app size
- Faster initialization
- Essential functionality only

## Quick Start

### 1. Initialize the Module

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
```

### 2. Use Independent Screens

```dart
// Each screen works independently
Widget statusScreen = MinimalAdvantisIoTModule.createStatusScreen();
Widget controlScreen = MinimalAdvantisIoTModule.createControlScreen();
Widget dashboard = MinimalAdvantisIoTModule.createDashboard(compact: true);
```

## Android Integration

### Method Channel Setup

Add this to your Flutter module's main.dart:

```dart
import 'package:flutter/services.dart';

// The minimal module automatically handles Android integration
// when initialized with enableAndroidIntegration: true
```

### Handle State Updates in Android

```kotlin
class MainActivity : FlutterActivity() {
    private val CHANNEL = "advantis_iot/communication"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "onIoTStateChanged" -> {
                    val stateData = call.arguments as? Map<String, Any>
                    handleIoTStateUpdate(stateData)
                    result.success(true)
                }
                "onIoTAlert" -> {
                    val alertData = call.arguments as? Map<String, Any>
                    handleIoTAlert(alertData)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun handleIoTStateUpdate(stateData: Map<String, Any>?) {
        stateData?.let { data ->
            val windowOpen = data["isWindowOpen"] as? Boolean
            val fireStatus = data["isFire"] as? Boolean
            val lightsStatus = data["lightsStatus"] as? Boolean
            
            // Update your Android UI
            updateUIWithIoTData(windowOpen, fireStatus, lightsStatus)
        }
    }
    
    private fun handleIoTAlert(alertData: Map<String, Any>?) {
        alertData?.let { data ->
            val type = data["type"] as? String
            val title = data["title"] as? String
            val message = data["message"] as? String
            
            // Show notification in your Android app
            if (type == "critical") {
                showCriticalAlert(title, message)
            } else {
                showWarningAlert(title, message)
            }
        }
    }
}
```

## Screen Independence

Each screen in the minimal module is completely independent:

### ✅ MinimalIoTStatusScreen
- Shows real-time IoT device status
- Self-initializes Firebase connection
- No dependencies on other screens
- Provides callbacks for Android integration

### ✅ MinimalIoTControlScreen  
- Provides device control interface
- Independent Firebase initialization
- Direct device control capabilities
- Control action callbacks

### ✅ MinimalIoTDashboard
- Compact status widget
- Can be embedded in any screen
- Tap callback for navigation
- Self-contained state management

## API Reference

### MinimalAdvantisIoTModule

#### Initialization
```dart
// Initialize module
await MinimalAdvantisIoTModule.initialize({
  bool enableAndroidIntegration = false,
});

// Start/stop monitoring
await MinimalAdvantisIoTModule.startMonitoring();
MinimalAdvantisIoTModule.stopMonitoring();
```

#### Screen Creation
```dart
// Status screen
Widget statusScreen = MinimalAdvantisIoTModule.createStatusScreen(
  onStateChanged: (Map<String, dynamic> state) {
    // Handle state changes
  },
);

// Control screen
Widget controlScreen = MinimalAdvantisIoTModule.createControlScreen(
  onControlAction: (String action, bool value) {
    // Handle control actions
  },
);

// Dashboard widget
Widget dashboard = MinimalAdvantisIoTModule.createDashboard(
  compact: true,
  height: 120,
  onTap: () {
    // Handle tap
  },
);
```

#### State Access
```dart
// Get current state
Map<String, dynamic> state = MinimalAdvantisIoTModule.getCurrentState();

// Get specific statuses
bool? fireStatus = MinimalAdvantisIoTModule.getFireStatus();
bool? windowStatus = MinimalAdvantisIoTModule.getWindowStatus();
bool? lightsStatus = MinimalAdvantisIoTModule.getLightsStatus();

// Check connection
bool connected = MinimalAdvantisIoTModule.isFirebaseConnected();
```

#### Device Control
```dart
// Control devices
await MinimalAdvantisIoTModule.controlLights(true);
await MinimalAdvantisIoTModule.controlWindow(false);

// Generic control
await MinimalAdvantisIoTModule.controlDevice('lights', true);
```

#### State Monitoring
```dart
// Add listener
MinimalAdvantisIoTModule.addStateListener(() {
  print('State changed: ${MinimalAdvantisIoTModule.getCurrentState()}');
});

// Remove listener
MinimalAdvantisIoTModule.removeStateListener(listener);
```

## Comparison: Original vs Minimal Module

| Feature | Original Module | Minimal Module |
|---------|----------------|----------------|
| **Size** | Full app with all screens | Essential screens only |
| **Dependencies** | Full authentication flow | Firebase + core only |
| **Screens** | 6+ screens with navigation | 3 independent screens |
| **Independence** | Screen dependencies exist | Fully independent screens |
| **Android Integration** | Complex setup | Simple method calls |
| **Use Case** | Complete IoT app | IoT monitoring widget |

## Example Usage Patterns

### Pattern 1: Embedded Dashboard
```dart
// In existing Android app layout
Column(
  children: [
    YourExistingWidget(),
    MinimalAdvantisIoTModule.createDashboard(), // 🎯 Embedded
    AnotherExistingWidget(),
  ],
)
```

### Pattern 2: Standalone Screens
```dart
// Navigate to independent screens
Navigator.push(context, MaterialPageRoute(
  builder: (context) => MinimalAdvantisIoTModule.createStatusScreen(),
));
```

### Pattern 3: Background Monitoring
```dart
// Monitor in background, show alerts in your app
void startBackgroundMonitoring() {
  MinimalAdvantisIoTModule.addStateListener(() {
    if (MinimalAdvantisIoTModule.getFireStatus() == true) {
      showFireAlert();
    }
    if (MinimalAdvantisIoTModule.getWindowStatus() == true) {
      showWindowAlert();
    }
  });
}
```

This minimal module provides exactly what you need for IoT monitoring without the complexity of a full application.