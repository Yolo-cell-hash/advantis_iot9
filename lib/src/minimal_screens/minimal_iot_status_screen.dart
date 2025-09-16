import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/iot_state_manager.dart';
import '../core/minimal_firebase_service.dart';

/// Minimal IoT Status Screen - Completely independent
/// 
/// Displays real-time IoT device status without dependencies
/// on other screens. Can be used standalone in Android apps.
class MinimalIoTStatusScreen extends StatefulWidget {
  final bool autoConnectFirebase;
  final VoidCallback? onFireAlert;
  final VoidCallback? onWindowAlert;
  final VoidCallback? onLightsChanged;
  
  const MinimalIoTStatusScreen({
    super.key,
    this.autoConnectFirebase = true,
    this.onFireAlert,
    this.onWindowAlert,
    this.onLightsChanged,
  });

  @override
  State<MinimalIoTStatusScreen> createState() => _MinimalIoTStatusScreenState();
}

class _MinimalIoTStatusScreenState extends State<MinimalIoTStatusScreen> {
  bool _isInitialized = false;
  String _connectionStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    if (widget.autoConnectFirebase) {
      try {
        await MinimalFirebaseService.instance.initialize();
        await MinimalFirebaseService.instance.startCoreDataStreams();
        
        setState(() {
          _isInitialized = true;
          _connectionStatus = 'Connected';
        });
        
        // Set up listeners for callbacks
        _setupCallbacks();
        
      } catch (e) {
        setState(() {
          _connectionStatus = 'Connection Failed: $e';
        });
      }
    } else {
      setState(() {
        _isInitialized = true;
        _connectionStatus = 'Ready (Firebase disabled)';
      });
    }
  }

  void _setupCallbacks() {
    final stateManager = IoTStateManager.instance;
    stateManager.addListener(() {
      if (mounted) {
        // Fire alert callback
        if (stateManager.isFire == true && widget.onFireAlert != null) {
          widget.onFireAlert!();
        }
        
        // Window alert callback
        if (stateManager.isWindowOpen == true && widget.onWindowAlert != null) {
          widget.onWindowAlert!();
        }
        
        // Lights changed callback
        if (widget.onLightsChanged != null) {
          widget.onLightsChanged!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: IoTStateManager.instance,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IoT Status'),
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
        ),
        body: _isInitialized ? _buildStatusContent() : _buildLoadingContent(),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_connectionStatus),
        ],
      ),
    );
  }

  Widget _buildStatusContent() {
    return Consumer<IoTStateManager>(
      builder: (context, stateManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectionStatusCard(stateManager),
              const SizedBox(height: 16),
              _buildStatusCard(
                'Fire Detection',
                stateManager.isFire,
                Icons.local_fire_department,
                Colors.red,
                'Fire Detected!',
                'No Fire',
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                'Window Status',
                stateManager.isWindowOpen,
                Icons.window,
                Colors.orange,
                'Window Open',
                'Window Closed',
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                'Lights',
                stateManager.lightsStatus,
                Icons.lightbulb,
                Colors.yellow,
                'Lights On',
                'Lights Off',
              ),
              const SizedBox(height: 16),
              _buildSystemOverview(stateManager),
              const SizedBox(height: 16),
              _buildLastUpdated(stateManager),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectionStatusCard(IoTStateManager stateManager) {
    final isConnected = stateManager.firebaseConnected;
    return Card(
      color: isConnected ? Colors.green[50] : Colors.red[50],
      child: ListTile(
        leading: Icon(
          isConnected ? Icons.cloud_done : Icons.cloud_off,
          color: isConnected ? Colors.green : Colors.red,
        ),
        title: Text(
          isConnected ? 'Firebase Connected' : 'Firebase Disconnected',
          style: TextStyle(
            color: isConnected ? Colors.green[700] : Colors.red[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(_connectionStatus),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    bool? status,
    IconData icon,
    Color alertColor,
    String activeMessage,
    String inactiveMessage,
  ) {
    Color cardColor;
    Color textColor;
    String message;
    
    if (status == null) {
      cardColor = Colors.grey[50]!;
      textColor = Colors.grey[700]!;
      message = 'Unknown';
    } else if (status) {
      cardColor = alertColor.withOpacity(0.1);
      textColor = alertColor[700]!;
      message = activeMessage;
    } else {
      cardColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      message = inactiveMessage;
    }

    return Card(
      color: cardColor,
      child: ListTile(
        leading: Icon(icon, color: textColor, size: 32),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: status == null
            ? Icon(Icons.help_outline, color: Colors.grey)
            : Icon(
                status ? Icons.warning : Icons.check_circle,
                color: textColor,
              ),
      ),
    );
  }

  Widget _buildSystemOverview(IoTStateManager stateManager) {
    String overallStatus;
    Color statusColor;
    IconData statusIcon;

    if (stateManager.hasCriticalAlert) {
      overallStatus = 'CRITICAL ALERT';
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else if (stateManager.hasWarningAlert) {
      overallStatus = 'WARNING';
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else if (stateManager.allSystemsNormal) {
      overallStatus = 'ALL SYSTEMS NORMAL';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      overallStatus = 'CHECKING...';
      statusColor = Colors.grey;
      statusIcon = Icons.sync;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                overallStatus,
                style: TextStyle(
                  color: statusColor[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated(IoTStateManager stateManager) {
    final lastUpdated = stateManager.lastUpdated;
    if (lastUpdated == null) return const SizedBox.shrink();

    return Card(
      child: ListTile(
        leading: const Icon(Icons.update),
        title: const Text('Last Updated'),
        subtitle: Text(
          '${lastUpdated.toLocal().toString().split('.')[0]}',
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Optionally stop streams when screen is disposed
    // MinimalFirebaseService.instance.stopCoreDataStreams();
    super.dispose();
  }
}