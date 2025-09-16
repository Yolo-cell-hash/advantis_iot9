package com.example.advantis_iot_android

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MainActivity : AppCompatActivity() {
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var iotDataChannel: MethodChannel
    private lateinit var iotNavigationChannel: MethodChannel
    
    private lateinit var statusText: TextView
    private lateinit var dataText: TextView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        initializeFlutterEngine()
        initializeUI()
        setupMethodChannels()
    }
    
    private fun initializeFlutterEngine() {
        // Create and cache Flutter engine for IoT module
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        // Cache the engine for reuse
        FlutterEngineCache.getInstance().put("advantis_iot_engine", flutterEngine)
    }
    
    private fun initializeUI() {
        statusText = findViewById(R.id.status_text)
        dataText = findViewById(R.id.data_text)
        
        // Button to launch complete IoT app
        findViewById<Button>(R.id.btn_launch_app).setOnClickListener {
            launchCompleteIoTApp()
        }
        
        // Button to launch home screen only
        findViewById<Button>(R.id.btn_home_screen).setOnClickListener {
            launchHomeScreen()
        }
        
        // Button to launch settings screen
        findViewById<Button>(R.id.btn_settings_screen).setOnClickListener {
            launchSettingsScreen()
        }
        
        // Button to get current state
        findViewById<Button>(R.id.btn_get_state).setOnClickListener {
            getCurrentIoTState()
        }
        
        // Button to start Firebase monitoring
        findViewById<Button>(R.id.btn_start_firebase).setOnClickListener {
            startFirebaseMonitoring()
        }
    }
    
    private fun setupMethodChannels() {
        // Data communication channel
        iotDataChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "advantis_iot/data"
        )
        
        // Navigation communication channel
        iotNavigationChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "advantis_iot/navigation"
        )
        
        // Listen for state changes from Flutter
        iotDataChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "onStateChanged" -> {
                    val stateData = call.arguments as? Map<String, Any>
                    handleIoTStateUpdate(stateData)
                    result.success(true)
                }
                "onAlert" -> {
                    val alertData = call.arguments as? Map<String, Any>
                    handleIoTAlert(alertData)
                    result.success(true)
                }
                "onFirebaseStatusChanged" -> {
                    val statusData = call.arguments as? Map<String, Any>
                    handleFirebaseStatusUpdate(statusData)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun launchCompleteIoTApp() {
        startActivity(
            FlutterActivity
                .withCachedEngine("advantis_iot_engine")
                .build(this)
        )
    }
    
    private fun launchHomeScreen() {
        iotNavigationChannel.invokeMethod("openHomeScreen", null) { result ->
            if (result is Map<*, *>) {
                updateStatus("Opened home screen: ${result["screen"]}")
            }
        }
        launchCompleteIoTApp()
    }
    
    private fun launchSettingsScreen() {
        iotNavigationChannel.invokeMethod("openSettingsScreen", null) { result ->
            if (result is Map<*, *>) {
                updateStatus("Opened settings screen: ${result["screen"]}")
            }
        }
        launchCompleteIoTApp()
    }
    
    private fun getCurrentIoTState() {
        iotDataChannel.invokeMethod("getCurrentState", null) { result ->
            if (result is Map<*, *>) {
                val stateString = result.entries.joinToString("\n") { "${it.key}: ${it.value}" }
                updateDataDisplay("Current IoT State:\n$stateString")
            }
        }
    }
    
    private fun startFirebaseMonitoring() {
        iotDataChannel.invokeMethod("startFirebaseStreams", null) { result ->
            if (result is Map<*, *>) {
                updateStatus("Firebase monitoring started: ${result["message"]}")
            }
        }
    }
    
    private fun handleIoTStateUpdate(stateData: Map<String, Any>?) {
        stateData?.let { data ->
            runOnUiThread {
                val updateText = buildString {
                    appendLine("Real-time IoT Data:")
                    data["isWindowOpen"]?.let { appendLine("Window Open: $it") }
                    data["isFire"]?.let { appendLine("Fire Status: $it") }
                    data["lightsStatus"]?.let { appendLine("Lights: $it") }
                    data["update"]?.let { appendLine("Updates: $it") }
                    data["firebaseConnected"]?.let { appendLine("Firebase: $it") }
                    data["lastUpdated"]?.let { appendLine("Last Updated: $it") }
                }
                updateDataDisplay(updateText)
            }
        }
    }
    
    private fun handleIoTAlert(alertData: Map<String, Any>?) {
        alertData?.let { data ->
            runOnUiThread {
                val type = data["type"] as? String ?: "info"
                val title = data["title"] as? String ?: "Alert"
                val message = data["message"] as? String ?: "No message"
                
                updateStatus("IoT Alert [$type]: $title - $message")
                
                // Handle critical alerts (you might show a notification or dialog)
                if (type == "critical") {
                    // Show urgent notification for fire alerts, etc.
                }
            }
        }
    }
    
    private fun handleFirebaseStatusUpdate(statusData: Map<String, Any>?) {
        statusData?.let { data ->
            runOnUiThread {
                val connected = data["connected"] as? Boolean ?: false
                val status = if (connected) "Connected" else "Disconnected"
                updateStatus("Firebase Status: $status")
            }
        }
    }
    
    private fun updateStatus(text: String) {
        runOnUiThread {
            statusText.text = text
        }
    }
    
    private fun updateDataDisplay(text: String) {
        runOnUiThread {
            dataText.text = text
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Clean up method channels
        iotDataChannel.setMethodCallHandler(null)
        iotNavigationChannel.setMethodCallHandler(null)
    }
}