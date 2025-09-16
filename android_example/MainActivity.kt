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

/**
 * Example Android Activity showing simplified integration with Advantis IoT Flutter module
 * 
 * This demonstrates the minimal code needed to integrate IoT monitoring
 * into an existing Android application.
 */
class MainActivity : AppCompatActivity() {
    private lateinit var flutterEngine: FlutterEngine
    private lateinit var iotDataChannel: MethodChannel
    
    private lateinit var statusText: TextView
    private lateinit var dataText: TextView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        initializeFlutterEngine()
        initializeUI()
        setupIoTDataChannel()
    }
    
    /**
     * Initialize Flutter engine for IoT module
     * This needs to be done once and the engine can be reused
     */
    private fun initializeFlutterEngine() {
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        // Cache the engine for efficient reuse
        FlutterEngineCache.getInstance().put("advantis_iot_engine", flutterEngine)
    }
    
    private fun initializeUI() {
        statusText = findViewById(R.id.status_text)
        dataText = findViewById(R.id.data_text)
        
        // Launch standalone IoT monitoring screen
        findViewById<Button>(R.id.btn_launch_monitoring).setOnClickListener {
            launchIoTMonitoring()
        }
        
        // Get current IoT state
        findViewById<Button>(R.id.btn_get_state).setOnClickListener {
            getCurrentIoTState()
        }
        
        // Start Firebase monitoring
        findViewById<Button>(R.id.btn_start_monitoring).setOnClickListener {
            startIoTMonitoring()
        }
        
        // Stop Firebase monitoring
        findViewById<Button>(R.id.btn_stop_monitoring).setOnClickListener {
            stopIoTMonitoring()
        }
    }
    
    /**
     * Setup data communication channel with Flutter IoT module
     */
    private fun setupIoTDataChannel() {
        iotDataChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "advantis_iot/data"
        )
        
        // Listen for real-time IoT state changes from Flutter
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
    
    /**
     * Launch standalone IoT monitoring screen
     * This opens a dedicated screen showing real-time IoT device states
     */
    private fun launchIoTMonitoring() {
        startActivity(
            FlutterActivity
                .withCachedEngine("advantis_iot_engine")
                .build(this)
        )
        updateStatus("Launched IoT monitoring screen")
    }
    
    /**
     * Get current IoT device states
     * Returns real-time data for fire detection, window status, and lights
     */
    private fun getCurrentIoTState() {
        iotDataChannel.invokeMethod("getCurrentState", null) { result ->
            if (result is Map<*, *>) {
                val stateString = buildString {
                    appendLine("Current IoT State:")
                    result["isFire"]?.let { appendLine("🔥 Fire: $it") }
                    result["isWindowOpen"]?.let { appendLine("🪟 Window: $it") }
                    result["lightsStatus"]?.let { appendLine("💡 Lights: $it") }
                    result["firebaseConnected"]?.let { appendLine("🔗 Connected: $it") }
                    result["lastUpdated"]?.let { appendLine("⏰ Updated: $it") }
                }
                updateDataDisplay(stateString)
            }
        }
    }
    
    /**
     * Start IoT monitoring services
     * Begins real-time Firebase monitoring of device states
     */
    private fun startIoTMonitoring() {
        iotDataChannel.invokeMethod("startFirebaseStreams", null) { result ->
            if (result is Map<*, *>) {
                updateStatus("IoT monitoring started: ${result["message"]}")
            }
        }
    }
    
    /**
     * Stop IoT monitoring services
     * Stops Firebase monitoring to save resources
     */
    private fun stopIoTMonitoring() {
        iotDataChannel.invokeMethod("stopFirebaseStreams", null) { result ->
            if (result is Map<*, *>) {
                updateStatus("IoT monitoring stopped: ${result["message"]}")
            }
        }
    }
    
    /**
     * Handle real-time IoT state updates from Flutter module
     * This is called automatically when device states change
     */
    private fun handleIoTStateUpdate(stateData: Map<String, Any>?) {
        stateData?.let { data ->
            runOnUiThread {
                val updateText = buildString {
                    appendLine("📊 Real-time IoT Data:")
                    
                    // Fire detection status
                    data["isFire"]?.let { 
                        val status = if (it == true) "🚨 FIRE DETECTED!" else "✅ Normal"
                        appendLine("Fire: $status")
                    }
                    
                    // Window status  
                    data["isWindowOpen"]?.let {
                        val status = if (it == true) "⚠️ Window Open" else "✅ Window Closed"
                        appendLine("Window: $status")
                    }
                    
                    // Lights status
                    data["lightsStatus"]?.let {
                        val status = if (it == true) "💡 Lights On" else "🌙 Lights Off"
                        appendLine("Lights: $status")
                    }
                    
                    // Connection status
                    data["firebaseConnected"]?.let {
                        val status = if (it == true) "🔗 Connected" else "❌ Disconnected"
                        appendLine("Connection: $status")
                    }
                    
                    // Last update time
                    data["lastUpdated"]?.let { appendLine("Updated: $it") }
                }
                updateDataDisplay(updateText)
            }
        }
    }
    
    /**
     * Handle IoT alerts (fire, security breaches, etc.)
     */
    private fun handleIoTAlert(alertData: Map<String, Any>?) {
        alertData?.let { data ->
            runOnUiThread {
                val type = data["type"] as? String ?: "info"
                val title = data["title"] as? String ?: "Alert"
                val message = data["message"] as? String ?: "No message"
                
                val alertIcon = when (type) {
                    "critical" -> "🚨"
                    "warning" -> "⚠️"
                    else -> "ℹ️"
                }
                
                updateStatus("$alertIcon $title: $message")
                
                // Handle critical alerts with notifications
                if (type == "critical") {
                    // You can show Android notifications, play sounds, etc.
                    handleCriticalAlert(title, message)
                }
            }
        }
    }
    
    /**
     * Handle critical IoT alerts (e.g., fire detection)
     */
    private fun handleCriticalAlert(title: String, message: String) {
        // Implement your critical alert handling here:
        // - Show Android notification
        // - Play alert sound
        // - Send push notification
        // - Log to analytics
        println("CRITICAL ALERT: $title - $message")
    }
    
    /**
     * Handle Firebase connection status changes
     */
    private fun handleFirebaseStatusUpdate(statusData: Map<String, Any>?) {
        statusData?.let { data ->
            runOnUiThread {
                val connected = data["connected"] as? Boolean ?: false
                val status = if (connected) "🔗 Connected" else "❌ Disconnected"
                updateStatus("Firebase: $status")
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
        // Clean up method channel
        iotDataChannel.setMethodCallHandler(null)
    }
}