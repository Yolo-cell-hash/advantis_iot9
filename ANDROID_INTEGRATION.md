# Android Integration Guide

This guide shows how to integrate the Advantis IoT Flutter module into an existing Android application.

## Prerequisites

- Android Studio or IntelliJ IDEA
- Flutter SDK installed
- Existing Android Kotlin/Java project
- Firebase project configured

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

In your MainActivity:
```kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "advantis_iot/communication"
    private lateinit var methodChannel: MethodChannel
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        setupMethodChannels()
    }
}
```

### 3. Launch Individual Screens

```kotlin
// Launch IoT Status Screen
fun openIoTStatusScreen() {
    val intent = FlutterActivity
        .withNewEngine()
        .initialRoute("/iot_status")
        .build(this)
    startActivity(intent)
}

// Launch IoT Control Screen
fun openIoTControlScreen() {
    val intent = FlutterActivity
        .withNewEngine()
        .initialRoute("/iot_control")
        .build(this)
    startActivity(intent)
}
```

### 4. Handle State Communication

#### Get Real-time IoT Data
```kotlin
fun setupStateListener() {
    methodChannel.setMethodCallHandler { call, result ->
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
        
        // Update your Android UI based on IoT data
        updateUIWithIoTData(windowOpen, fireStatus, lightsStatus)
        
        // Show notifications if needed
        if (fireStatus == true) {
            showFireNotification()
        }
    }
}

private fun handleIoTAlert(alertData: Map<String, Any>?) {
    alertData?.let { data ->
        val type = data["type"] as? String
        val title = data["title"] as? String
        val message = data["message"] as? String
        
        when (type) {
            "critical" -> showCriticalAlert(title, message)
            "warning" -> showWarningAlert(title, message)
            else -> showInfoAlert(title, message)
        }
    }
}
```

#### Send Commands to Flutter
```kotlin
// Get current IoT state
fun getCurrentIoTState() {
    methodChannel.invokeMethod("getIoTState", null) { result ->
        val state = result as? Map<String, Any>
        // Handle state data
    }
}

// Control devices
fun controlLights(turnOn: Boolean) {
    val args = mapOf("device" to "lights", "state" to turnOn)
    methodChannel.invokeMethod("controlDevice", args)
}
```

### 5. Required Permissions

Add to your `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.VIBRATE" />
```

### 6. Firebase Configuration

Add your `google-services.json` to the `app/` directory and ensure Firebase is configured in your `build.gradle`.

## Usage Examples

### Basic Integration

```kotlin
class IoTIntegrationExample : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Button to open IoT status
        findViewById<Button>(R.id.btn_iot_status).setOnClickListener {
            openIoTStatusScreen()
        }
        
        // Button to open IoT control
        findViewById<Button>(R.id.btn_iot_control).setOnClickListener {
            openIoTControlScreen()
        }
    }
    
    private fun openIoTStatusScreen() {
        val intent = FlutterActivity
            .withNewEngine()
            .initialRoute("/minimal_status")
            .build(this)
        startActivity(intent)
    }
    
    private fun openIoTControlScreen() {
        val intent = FlutterActivity
            .withNewEngine()
            .initialRoute("/minimal_control")
            .build(this)
        startActivity(intent)
    }
}
```

### Advanced State Management

```kotlin
class IoTStateManager {
    private var isFireDetected: Boolean? = null
    private var isWindowOpen: Boolean? = null
    private var lightsStatus: Boolean? = null
    
    fun updateState(state: Map<String, Any>) {
        isFireDetected = state["isFire"] as? Boolean
        isWindowOpen = state["isWindowOpen"] as? Boolean
        lightsStatus = state["lightsStatus"] as? Boolean
        
        // Notify listeners
        notifyStateListeners()
    }
    
    fun getStateForUI(): IoTDisplayState {
        return IoTDisplayState(
            fireStatus = isFireDetected ?: false,
            windowStatus = isWindowOpen ?: false,
            lightsStatus = lightsStatus ?: false
        )
    }
    
    private fun notifyStateListeners() {
        // Update UI components
        updateStatusIndicators()
        
        // Send notifications if needed
        if (isFireDetected == true) {
            sendFireAlert()
        }
    }
}
```

## Method Channel Implementation

Add this to your Flutter module's main.dart for Android communication:

```dart
import 'package:flutter/services.dart';

class AndroidIntegration {
  static const MethodChannel _channel = MethodChannel('advantis_iot/communication');
  
  static void setupMethodChannels() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getIoTState':
        return MinimalAdvantisIoTModule.getCurrentState();
      case 'controlDevice':
        final device = call.arguments['device'] as String;
        final state = call.arguments['state'] as bool;
        await MinimalAdvantisIoTModule.controlDevice(device, state);
        return true;
      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          details: 'Method ${call.method} not implemented',
        );
    }
  }
  
  static void sendStateUpdate(Map<String, dynamic> state) {
    _channel.invokeMethod('onIoTStateChanged', state);
  }
  
  static void sendAlert(String type, String title, String message) {
    _channel.invokeMethod('onIoTAlert', {
      'type': type,
      'title': title,
      'message': message,
    });
  }
}
```

## Best Practices

### 1. Error Handling
```kotlin
methodChannel.invokeMethod("getIoTState", null) { result ->
    when (result) {
        is Map<*, *> -> {
            // Success
            handleStateData(result as Map<String, Any>)
        }
        is FlutterError -> {
            Log.e("IoT", "Flutter error: ${result.message}")
        }
        else -> {
            Log.e("IoT", "Unexpected result type")
        }
    }
}
```

### 2. Lifecycle Management
```kotlin
override fun onDestroy() {
    super.onDestroy()
    // Clean up method channel listeners
    methodChannel.setMethodCallHandler(null)
}
```

### 3. Background Processing
```kotlin
// Handle IoT state updates in background
class IoTBackgroundService : Service() {
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Set up background IoT monitoring
        return START_STICKY
    }
    
    private fun processIoTStateUpdate(state: Map<String, Any>) {
        // Process state changes even when app is backgrounded
        if (state["isFire"] == true) {
            showFireNotification()
        }
    }
}
```

## Troubleshooting

### Common Issues

1. **Method Channel Not Working**
   - Ensure channel name matches exactly
   - Check Flutter engine is properly initialized
   
2. **State Updates Not Received**
   - Verify method call handler is set up before Flutter engine starts
   - Check Firebase permissions and configuration
   
3. **Screen Navigation Issues**
   - Use correct route names
   - Ensure Flutter module is properly built and included

### Debug Tips

```kotlin
// Enable Flutter debugging
FlutterEngine.Builder()
    .build(applicationContext)
    .dartExecutor
    .executeDartEntrypoint(
        DartExecutor.DartEntrypoint.createDefault()
    )
```

For additional support, refer to the Flutter documentation or file an issue in the project repository.