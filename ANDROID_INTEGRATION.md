# Android Integration Guide - Simplified

This guide shows how to integrate the streamlined Advantis IoT Flutter module into an existing Android application with minimal setup.

## Overview

The Advantis IoT module has been optimized for easy integration, focusing on essential IoT monitoring features:
- 🔥 Fire detection monitoring
- 🪟 Window status tracking  
- 💡 Lights control monitoring
- 🔗 Real-time Firebase synchronization
- 📱 Android method channel communication

## Quick Setup

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

### 2. Minimal Android Integration

```kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MainActivity : AppCompatActivity() {
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var iotDataChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        initializeIoTModule()
    }
    
    private fun initializeIoTModule() {
        // Initialize Flutter engine
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        // Cache for reuse
        FlutterEngineCache.getInstance().put("advantis_iot_engine", flutterEngine)
        
        // Setup data communication
        setupIoTDataChannel()
    }
    
    private fun setupIoTDataChannel() {
        iotDataChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "advantis_iot/data"
        )
        
        // Listen for real-time IoT updates
        iotDataChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "onStateChanged" -> {
                    val stateData = call.arguments as? Map<String, Any>
                    handleIoTUpdate(stateData)
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
}
```

### 3. Launch IoT Monitoring

#### Option A: Full Screen IoT Dashboard
```kotlin
fun launchIoTMonitoring() {
    startActivity(
        FlutterActivity
            .withCachedEngine("advantis_iot_engine")
            .build(this)
    )
}
```

#### Option B: Get Real-time Data
```kotlin
fun getCurrentIoTState() {
    iotDataChannel.invokeMethod("getCurrentState", null) { result ->
        if (result is Map<*, *>) {
            val fireStatus = result["isFire"]
            val windowStatus = result["isWindowOpen"] 
            val lightsStatus = result["lightsStatus"]
            
            // Update your Android UI
            updateUIWithIoTData(fireStatus, windowStatus, lightsStatus)
        }
    }
}
```

#### Option C: Control Monitoring
```kotlin
// Start Firebase monitoring
fun startIoTMonitoring() {
    iotDataChannel.invokeMethod("startFirebaseStreams", null)
}

// Stop monitoring to save resources
fun stopIoTMonitoring() {
    iotDataChannel.invokeMethod("stopFirebaseStreams", null)
}
```

## Real-time Data Handling

### Handle IoT State Updates
```kotlin
private fun handleIoTUpdate(stateData: Map<String, Any>?) {
    stateData?.let { data ->
        // Fire detection
        data["isFire"]?.let { isFire ->
            if (isFire == true) {
                showFireAlert()
            }
        }
        
        // Window status
        data["isWindowOpen"]?.let { isOpen ->
            updateWindowStatus(isOpen as Boolean)
        }
        
        // Lights status
        data["lightsStatus"]?.let { lightsOn ->
            updateLightsStatus(lightsOn as Boolean)
        }
        
        // Update UI with latest data
        updateDashboard(data)
    }
}

private fun handleIoTAlert(alertData: Map<String, Any>?) {
    alertData?.let { data ->
        val type = data["type"] as? String
        val message = data["message"] as? String
        
        when (type) {
            "critical" -> showCriticalAlert(message ?: "Critical IoT Alert")
            "warning" -> showWarningAlert(message ?: "IoT Warning")
            else -> showInfoAlert(message ?: "IoT Notification")
        }
    }
}
```

## Required Permissions

Add these permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## Firebase Configuration

1. Add your `google-services.json` file to the `app/` directory
2. Configure Firebase in your project-level `build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

3. Apply the plugin in your app-level `build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

## Usage Examples

### Basic Integration Example
```kotlin
class IoTManager(private val context: Context) {
    fun initialize(): Boolean {
        return try {
            initializeIoTModule()
            true
        } catch (e: Exception) {
            Log.e("IoTManager", "Failed to initialize IoT module: $e")
            false
        }
    }
    
    fun showIoTDashboard() {
        launchIoTMonitoring()
    }
    
    fun getLatestIoTData(): Map<String, Any>? {
        return getCurrentIoTState()
    }
    
    fun startMonitoring() {
        startIoTMonitoring()
    }
    
    fun stopMonitoring() {
        stopIoTMonitoring()
    }
}
```

### Repository Pattern Example
```kotlin
class IoTRepository {
    private val _iotState = MutableLiveData<IoTState>()
    val iotState: LiveData<IoTState> = _iotState
    
    fun startMonitoring() {
        setupStateListener()
        startIoTMonitoring()
    }
    
    private fun setupStateListener() {
        // Real-time updates from Flutter module
        handleIoTUpdate { stateData ->
            val state = IoTState(
                fireDetected = stateData["isFire"] as? Boolean,
                windowOpen = stateData["isWindowOpen"] as? Boolean,
                lightsOn = stateData["lightsStatus"] as? Boolean,
                lastUpdated = Date()
            )
            _iotState.postValue(state)
        }
    }
}

data class IoTState(
    val fireDetected: Boolean?,
    val windowOpen: Boolean?,
    val lightsOn: Boolean?,
    val lastUpdated: Date
)
```

## Key Benefits

✅ **Minimal Setup**: Only 3 method channel calls needed  
✅ **Real-time Data**: Automatic Firebase synchronization  
✅ **Lightweight**: Essential IoT features only  
✅ **Independent**: No navigation dependencies  
✅ **Flexible**: Use full screen or data-only integration  
✅ **Android Native**: Seamless method channel communication  

## Troubleshooting

### Common Issues

1. **"Module not initialized"**: Call `CoreIoTModule.initialize()` first
2. **No Firebase data**: Check internet connection and Firebase config
3. **Method channel errors**: Ensure Flutter engine is properly initialized
4. **State not updating**: Verify `startFirebaseStreams` was called

### Debug Commands

```bash
# Verify Flutter module
flutter doctor

# Check dependencies
flutter pub get

# Test Firebase connection
flutter run --debug
```

For complete examples, see the `android_example/` directory.