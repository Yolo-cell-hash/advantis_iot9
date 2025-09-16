# Android Integration Guide

This guide shows how to integrate the Advantis IoT Flutter module into an existing Android application.

## Prerequisites

1. An existing Android project with Flutter module support
2. Firebase configuration for your Android app
3. Proper permissions in your Android manifest

## Setup Steps

### 1. Add Flutter Module to Android Project

In your `settings.gradle` file:
```gradle
include ':app'
setBinding(new Binding([gradle: this]))
evaluate(new File(
  settingsDir.parentFile,
  'advantis_iot9/.android/include_flutter.groovy'
))
```

In your app's `build.gradle`:
```gradle
dependencies {
    implementation project(':flutter')
    // other dependencies
}
```

### 2. Initialize the Module

In your Android Activity or Application class:

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
        
        // Cache the engine for reuse
        FlutterEngineCache.getInstance().put("advantis_iot_engine", flutterEngine)
        
        setContentView(R.layout.activity_main)
    }
}
```

### 3. Launch Individual Screens

#### Method 1: Direct Screen Launch
```kotlin
fun openIoTHomeScreen() {
    startActivity(
        FlutterActivity
            .withCachedEngine("advantis_iot_engine")
            .build(this)
    )
}
```

#### Method 2: Using Method Channels for Specific Screens
```kotlin
import io.flutter.plugin.common.MethodChannel

class IoTModuleManager(private val flutterEngine: FlutterEngine) {
    private val methodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "advantis_iot/navigation"
    )
    
    fun openHomeScreen() {
        methodChannel.invokeMethod("openHomeScreen", null)
    }
    
    fun openSettingsScreen() {
        methodChannel.invokeMethod("openSettingsScreen", null)
    }
    
    fun getCurrentState(): Map<String, Any>? {
        return methodChannel.invokeMethod("getCurrentState", null)
    }
}
```

### 4. Handle State Communication

#### Get Real-time IoT Data
```kotlin
fun setupStateListener() {
    methodChannel.setMethodCallHandler { call, result ->
        when (call.method) {
            "onStateChanged" -> {
                val stateData = call.arguments as? Map<String, Any>
                handleIoTStateUpdate(stateData)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
}

private fun handleIoTStateUpdate(stateData: Map<String, Any>?) {
    stateData?.let { data ->
        val windowOpen = data["isWindowOpen"]
        val fireStatus = data["isFire"]
        val lightsStatus = data["lightsStatus"]
        
        // Update your Android UI based on IoT data
        updateUIWithIoTData(windowOpen, fireStatus, lightsStatus)
    }
}
```

### 5. Required Permissions

Add these permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### 6. Firebase Configuration

Ensure your Android app has the `google-services.json` file in the `app/` directory and the Firebase plugin is configured:

```gradle
// In project-level build.gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}

// In app-level build.gradle
apply plugin: 'com.google.gms.google-services'
```

## Usage Examples

### Basic Integration

```kotlin
class IoTManager(private val context: Context) {
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var iotModule: IoTModuleManager
    
    fun initialize() {
        flutterEngine = FlutterEngine(context)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        iotModule = IoTModuleManager(flutterEngine)
    }
    
    fun showIoTDashboard() {
        val intent = FlutterActivity
            .withCachedEngine("advantis_iot_engine")
            .build(context)
        context.startActivity(intent)
    }
    
    fun getLatestIoTData(): Map<String, Any>? {
        return iotModule.getCurrentState()
    }
}
```

### Advanced State Management

```kotlin
class IoTDataRepository {
    private val iotManager = IoTModuleManager(flutterEngine)
    private val _iotData = MutableLiveData<IoTState>()
    val iotData: LiveData<IoTState> = _iotData
    
    fun startMonitoring() {
        // Start Firebase streams in Flutter module
        iotManager.startFirebaseStreams()
        
        // Set up listener for state changes
        setupStateListener()
    }
    
    private fun setupStateListener() {
        // Listen for state changes from Flutter module
        iotManager.setStateChangeListener { stateData ->
            val iotState = IoTState(
                windowOpen = stateData["isWindowOpen"] as? Boolean,
                fireDetected = stateData["isFire"] as? Boolean,
                lightsOn = stateData["lightsStatus"] as? Boolean,
                lastUpdated = Date()
            )
            _iotData.postValue(iotState)
        }
    }
}
```

## Method Channel Implementation

Add this to your Flutter module's main.dart for Android communication:

```dart
import 'package:flutter/services.dart';

class AndroidIntegration {
  static const MethodChannel _channel = MethodChannel('advantis_iot/navigation');
  
  static void setupMethodChannels() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'openHomeScreen':
        // Navigate to home screen
        return true;
      case 'openSettingsScreen':
        // Navigate to settings screen
        return true;
      case 'getCurrentState':
        return AdvantisIoTModule.getCurrentState();
      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          details: 'Method ${call.method} not implemented',
        );
    }
  }
  
  static void sendStateUpdate(Map<String, dynamic> state) {
    _channel.invokeMethod('onStateChanged', state);
  }
}
```

## Best Practices

1. **Cache Flutter Engines**: Reuse Flutter engines to avoid initialization overhead
2. **Handle Lifecycle**: Properly manage Flutter engine lifecycle in your activities
3. **State Synchronization**: Use method channels for bidirectional communication
4. **Error Handling**: Implement proper error handling for Firebase and network issues
5. **Performance**: Monitor memory usage when using multiple Flutter instances

## Troubleshooting

### Common Issues

1. **Firebase not initialized**: Ensure Firebase is properly configured in both Android and Flutter
2. **State not updating**: Check that Firebase streams are active and network connectivity exists
3. **Memory leaks**: Properly dispose of Flutter engines and listeners when not needed
4. **Screen navigation**: Use cached engines for better performance when switching between screens

### Debug Commands

```bash
# Check Flutter module integration
flutter doctor

# Verify Firebase configuration
flutter packages get
```

For more detailed examples, see the `example/` directory in this module.