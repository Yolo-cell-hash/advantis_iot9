import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';

/// Minimal IoT Status Screen - Completely Independent
/// 
/// Shows real-time IoT device status in a clean, minimal interface.
/// Self-initializes Firebase connection and manages its own state.
/// No dependencies on other screens or navigation.
class MinimalIoTStatusScreen extends StatefulWidget {
  /// Callback for Android integration when state changes
  final Function(Map<String, dynamic>)? onStateChanged;
  
  /// Callback for navigation requests (optional)
  final VoidCallback? onNavigationRequested;
  
  const MinimalIoTStatusScreen({
    Key? key,
    this.onStateChanged,
    this.onNavigationRequested,
  }) : super(key: key);

  @override
  State<MinimalIoTStatusScreen> createState() => _MinimalIoTStatusScreenState();
}

class _MinimalIoTStatusScreenState extends State<MinimalIoTStatusScreen> {
  late IoTStateManager _stateManager;
  bool _firebaseInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeModule();
  }
  
  /// Initialize the module independently
  Future<void> _initializeModule() async {
    try {
      // Initialize Firebase service if not already done
      await MinimalFirebaseService.instance.initialize();
      
      // Get state manager instance
      _stateManager = IoTStateManager.instance;
      
      // Start monitoring
      await MinimalFirebaseService.instance.startCoreDataStreams();
      
      // Listen for state changes
      _stateManager.addListener(_onStateChanged);
      
      setState(() {
        _firebaseInitialized = true;
      });
      
      print('MinimalIoTStatusScreen initialized independently');
      
    } catch (e) {
      print('Error initializing MinimalIoTStatusScreen: $e');
    }
  }
  
  void _onStateChanged() {
    if (widget.onStateChanged != null) {
      widget.onStateChanged!(_stateManager.toMap());
    }
  }
  
  @override
  void dispose() {
    _stateManager.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_firebaseInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('IoT Status'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing IoT monitoring...'),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _stateManager,
      child: Scaffold(
        appBar: AppBar(
          title: Text('IoT Device Status'),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
            if (widget.onNavigationRequested != null)
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: widget.onNavigationRequested,
              ),
          ],
        ),
        body: Consumer<IoTStateManager>(
          builder: (context, stateManager, child) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Connection Status
                  _buildConnectionCard(stateManager),
                  SizedBox(height: 16),
                  
                  // Status Cards
                  Expanded(
                    child: ListView(
                      children: [
                        _buildStatusCard(
                          'Fire Detection',
                          stateManager.isFire,
                          Icons.local_fire_department,
                          Colors.red,
                        ),
                        SizedBox(height: 12),
                        _buildStatusCard(
                          'Window Status',
                          stateManager.isWindowOpen,
                          Icons.window,
                          Colors.orange,
                        ),
                        SizedBox(height: 12),
                        _buildStatusCard(
                          'Lights Status',
                          stateManager.lightsStatus,
                          Icons.lightbulb,
                          Colors.yellow,
                        ),
                      ],
                    ),
                  ),
                  
                  // Summary
                  _buildSummaryCard(stateManager),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildConnectionCard(IoTStateManager stateManager) {
    return Card(
      child: ListTile(
        leading: Icon(
          stateManager.firebaseConnected ? Icons.cloud_done : Icons.cloud_off,
          color: stateManager.firebaseConnected ? Colors.green : Colors.red,
        ),
        title: Text('Firebase Connection'),
        subtitle: Text(stateManager.firebaseConnected ? 'Connected' : 'Disconnected'),
        trailing: stateManager.lastUpdated != null
            ? Text(
                'Updated: ${_formatTime(stateManager.lastUpdated!)}',
                style: TextStyle(fontSize: 12),
              )
            : null,
      ),
    );
  }
  
  Widget _buildStatusCard(String title, bool? status, IconData icon, Color color) {
    Color cardColor = status == true ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1);
    Color iconColor = status == true ? color : Colors.grey;
    String statusText = status == null ? 'Unknown' : (status ? 'Active' : 'Inactive');
    
    return Card(
      color: cardColor,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(statusText),
        trailing: status == true 
          ? Icon(Icons.warning, color: color)
          : Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
  
  Widget _buildSummaryCard(IoTStateManager stateManager) {
    return Card(
      color: stateManager.hasCriticalAlert 
        ? Colors.red.withOpacity(0.2)
        : stateManager.hasWarningAlert
          ? Colors.orange.withOpacity(0.2)
          : Colors.green.withOpacity(0.2),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              stateManager.hasCriticalAlert 
                ? Icons.error
                : stateManager.hasWarningAlert
                  ? Icons.warning
                  : Icons.check_circle,
              color: stateManager.hasCriticalAlert 
                ? Colors.red
                : stateManager.hasWarningAlert
                  ? Colors.orange
                  : Colors.green,
              size: 32,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(stateManager.statusSummary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  Future<void> _refreshData() async {
    try {
      // Stop and restart streams for fresh data
      MinimalFirebaseService.instance.stopCoreDataStreams();
      await MinimalFirebaseService.instance.startCoreDataStreams();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data refreshed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error refreshing data: $e')),
      );
    }
  }
}