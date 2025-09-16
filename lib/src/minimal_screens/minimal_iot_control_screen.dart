import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';

/// Minimal IoT Control Screen - Completely Independent
/// 
/// Provides device control interface for lights and window.
/// Self-initializes Firebase connection and manages its own state.
/// No dependencies on other screens or navigation.
class MinimalIoTControlScreen extends StatefulWidget {
  /// Callback for Android integration when control action is performed
  final Function(String action, bool value)? onControlAction;
  
  /// Callback for navigation requests (optional)
  final VoidCallback? onNavigationRequested;
  
  const MinimalIoTControlScreen({
    Key? key,
    this.onControlAction,
    this.onNavigationRequested,
  }) : super(key: key);

  @override
  State<MinimalIoTControlScreen> createState() => _MinimalIoTControlScreenState();
}

class _MinimalIoTControlScreenState extends State<MinimalIoTControlScreen> {
  late IoTStateManager _stateManager;
  bool _firebaseInitialized = false;
  bool _controlsEnabled = true;
  
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
      
      setState(() {
        _firebaseInitialized = true;
      });
      
      print('MinimalIoTControlScreen initialized independently');
      
    } catch (e) {
      print('Error initializing MinimalIoTControlScreen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_firebaseInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('IoT Control'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing IoT controls...'),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _stateManager,
      child: Scaffold(
        appBar: AppBar(
          title: Text('IoT Device Control'),
          backgroundColor: Colors.green,
          actions: [
            if (widget.onNavigationRequested != null)
              IconButton(
                icon: Icon(Icons.home),
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
                  
                  // Fire Alert (Read-only)
                  _buildFireAlert(stateManager),
                  SizedBox(height: 16),
                  
                  // Control Cards
                  Expanded(
                    child: ListView(
                      children: [
                        _buildControlCard(
                          'Lights Control',
                          'Control the lights in your IoT system',
                          Icons.lightbulb,
                          Colors.yellow,
                          stateManager.lightsStatus,
                          (value) => _controlLights(value),
                        ),
                        SizedBox(height: 16),
                        _buildControlCard(
                          'Window Control',
                          'Control the window opening/closing',
                          Icons.window,
                          Colors.blue,
                          stateManager.isWindowOpen,
                          (value) => _controlWindow(value),
                        ),
                      ],
                    ),
                  ),
                  
                  // Emergency Controls
                  _buildEmergencyControls(),
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
        title: Text('Control System'),
        subtitle: Text(stateManager.firebaseConnected ? 'Online - Ready for Control' : 'Offline - Controls Disabled'),
        trailing: Switch(
          value: _controlsEnabled && stateManager.firebaseConnected,
          onChanged: stateManager.firebaseConnected ? (value) {
            setState(() {
              _controlsEnabled = value;
            });
          } : null,
        ),
      ),
    );
  }
  
  Widget _buildFireAlert(IoTStateManager stateManager) {
    if (stateManager.isFire != true) return SizedBox.shrink();
    
    return Card(
      color: Colors.red.withOpacity(0.2),
      child: ListTile(
        leading: Icon(Icons.local_fire_department, color: Colors.red, size: 32),
        title: Text('FIRE DETECTED', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        subtitle: Text('Controls may be disabled for safety'),
        trailing: Icon(Icons.warning, color: Colors.red),
      ),
    );
  }
  
  Widget _buildControlCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool? currentState,
    Function(bool) onChanged,
  ) {
    bool isEnabled = _controlsEnabled && _stateManager.firebaseConnected && _stateManager.isFire != true;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(description, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Current Status: '),
                Text(
                  currentState == null ? 'Unknown' : (currentState ? 'ON' : 'OFF'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: currentState == true ? Colors.green : Colors.grey,
                  ),
                ),
                Spacer(),
                Switch(
                  value: currentState == true,
                  onChanged: isEnabled ? onChanged : null,
                ),
              ],
            ),
            if (!isEnabled)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Controls disabled: ${!_stateManager.firebaseConnected ? "No connection" : _stateManager.isFire == true ? "Fire detected" : "Controls disabled"}',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmergencyControls() {
    return Card(
      color: Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Controls',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controlsEnabled && _stateManager.firebaseConnected
                      ? () => _emergencyAction('turn_off_all')
                      : null,
                    icon: Icon(Icons.power_off),
                    label: Text('Turn Off All'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controlsEnabled && _stateManager.firebaseConnected
                      ? () => _emergencyAction('close_window')
                      : null,
                    icon: Icon(Icons.lock),
                    label: Text('Close Window'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _controlLights(bool turnOn) async {
    try {
      await MinimalFirebaseService.instance.controlDevice('lights', turnOn);
      
      if (widget.onControlAction != null) {
        widget.onControlAction!('lights', turnOn);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lights ${turnOn ? 'turned on' : 'turned off'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error controlling lights: $e')),
      );
    }
  }
  
  Future<void> _controlWindow(bool open) async {
    try {
      await MinimalFirebaseService.instance.controlDevice('windowOpen', open);
      
      if (widget.onControlAction != null) {
        widget.onControlAction!('window', open);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Window ${open ? 'opened' : 'closed'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error controlling window: $e')),
      );
    }
  }
  
  Future<void> _emergencyAction(String action) async {
    try {
      switch (action) {
        case 'turn_off_all':
          await MinimalFirebaseService.instance.controlDevice('lights', false);
          if (widget.onControlAction != null) {
            widget.onControlAction!('emergency_all_off', false);
          }
          break;
        case 'close_window':
          await MinimalFirebaseService.instance.controlDevice('windowOpen', false);
          if (widget.onControlAction != null) {
            widget.onControlAction!('emergency_close_window', false);
          }
          break;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Emergency action completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error performing emergency action: $e')),
      );
    }
  }
}