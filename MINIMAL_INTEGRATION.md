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

### 1. Add to your Flutter Module

```dart
import 'package:advantis_iot/minimal_advantis_iot.dart';

// Initialize once in your app
await MinimalAdvantisIoTModule.initialize(enableAndroidIntegration: true);

// Start monitoring IoT devices  
await MinimalAdvantisIoTModule.startMonitoring();
```

### 2. Use Independent Screens

```dart
// Create status screen - completely independent
Widget statusScreen = MinimalAdvantisIoTModule.createStatusScreen(
  onFireAlert: () {
    // Handle fire alert in your app
    print('Fire detected!');
  },
  onWindowAlert: () {
    // Handle window alert
    print('Window opened!');
  },
);

// Create control screen - completely independent  
Widget controlScreen = MinimalAdvantisIoTModule.createControlScreen(
  onControlAction: (device, value) {
    // Handle device control actions
    print('$device set to $value');
  },
);

// Create compact dashboard widget
Widget dashboard = MinimalAdvantisIoTModule.createDashboard(
  onTap: () {
    // Navigate to full status screen
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => statusScreen,
    ));
  },
);
```

### 3. Direct Device Control

```dart
// Control lights
await MinimalAdvantisIoTModule.controlLights(true);  // Turn on
await MinimalAdvantisIoTModule.controlLights(false); // Turn off

// Control window
await MinimalAdvantisIoTModule.controlWindow(false); // Close

// Get current state
Map<String, dynamic> state = MinimalAdvantisIoTModule.getCurrentState();
bool? fireStatus = MinimalAdvantisIoTModule.getFireStatus();
bool? windowStatus = MinimalAdvantisIoTModule.getWindowStatus();
bool? lightsStatus = MinimalAdvantisIoTModule.getLightsStatus();
```

## Android Integration

### 1. Add Flutter Module to Android Project

In your `settings.gradle`:
```gradle
include ':app'
setBinding(new Binding([gradle: this]))
evaluate(new File(
  settingsDir.parentFile,
  'advantis_iot/.android/include_flutter.groovy'
))
```

In your app's `build.gradle`:
```gradle
dependencies {
    implementation project(':flutter')
}
```

### 2. Initialize in Android Activity

```kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class MainActivity : AppCompatActivity() {
    private lateinit var flutterEngine: FlutterEngine

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize Flutter engine
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        FlutterEngineCache.getInstance().put("iot_engine", flutterEngine)
    }
}
```

### 3. Launch IoT Screens from Android

```kotlin
// Launch status screen
fun openIoTStatus() {
    startActivity(
        FlutterActivity
            .withCachedEngine("iot_engine")
            .build(this)
    )
}

// Launch control screen with method channel
private fun openIoTControl() {
    val methodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "advantis_iot/navigation"
    )
    methodChannel.invokeMethod("openControlScreen", null)
}
```

### 4. Listen to IoT State Changes

```kotlin
import io.flutter.plugin.common.MethodChannel

class IoTStateListener(private val flutterEngine: FlutterEngine) {
    private val dataChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "advantis_iot/data"
    )
    
    init {
        dataChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "onStateChanged" -> {
                    val state = call.arguments as? Map<String, Any>
                    handleIoTStateUpdate(state)
                    result.success(true)
                }
                "onAlert" -> {
                    val alertData = call.arguments as? Map<String, Any>
                    handleIoTAlert(alertData)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun handleIoTStateUpdate(state: Map<String, Any>?) {
        state?.let { data ->
            val fireDetected = data["isFire"] as? Boolean
            val windowOpen = data["isWindowOpen"] as? Boolean
            val lightsOn = data["lightsStatus"] as? Boolean
            
            // Update your Android UI
            updateAndroidUI(fireDetected, windowOpen, lightsOn)
        }
    }
    
    private fun handleIoTAlert(alertData: Map<String, Any>?) {
        alertData?.let { data ->
            val type = data["type"] as? String
            val title = data["title"] as? String
            val message = data["message"] as? String
            
            // Show Android notification
            showAndroidNotification(type, title, message)
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

### Core Methods

```dart
// Initialization
MinimalAdvantisIoTModule.initialize({bool enableAndroidIntegration})
MinimalAdvantisIoTModule.startMonitoring()
MinimalAdvantisIoTModule.stopMonitoring()

// Screen Creation
MinimalAdvantisIoTModule.createStatusScreen({callbacks...})
MinimalAdvantisIoTModule.createControlScreen({callbacks...})
MinimalAdvantisIoTModule.createDashboard({options...})

// State Access
MinimalAdvantisIoTModule.getCurrentState()
MinimalAdvantisIoTModule.getFireStatus()
MinimalAdvantisIoTModule.getWindowStatus()
MinimalAdvantisIoTModule.getLightsStatus()

// Device Control
MinimalAdvantisIoTModule.controlLights(bool)
MinimalAdvantisIoTModule.controlWindow(bool)
MinimalAdvantisIoTModule.controlDevice(String, dynamic)

// State Management
MinimalAdvantisIoTModule.addStateListener(VoidCallback)
MinimalAdvantisIoTModule.removeStateListener(VoidCallback)
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
// In your existing Android app screen
Widget buildMainScreen() {
  return Column(
    children: [
      // Your existing content
      YourExistingWidget(),
      
      // Embedded IoT dashboard
      MinimalAdvantisIoTModule.createDashboard(
        onTap: () => navigateToFullIoTScreen(),
      ),
      
      // More of your content
      AnotherWidget(),
    ],
  );
}
```

### Pattern 2: Standalone Screens
```dart
// Navigate to independent IoT screens
void openIoTMonitoring() {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) => MinimalAdvantisIoTModule.createStatusScreen(),
  ));
}

void openIoTControls() {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) => MinimalAdvantisIoTModule.createControlScreen(),
  ));
}
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