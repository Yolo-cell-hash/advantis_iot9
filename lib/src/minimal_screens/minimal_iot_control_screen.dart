import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/iot_state_manager.dart';
import '../core/minimal_firebase_service.dart';

/// Minimal IoT Control Screen - Completely independent
/// 
/// Provides basic controls for IoT devices without dependencies.
/// Can be used standalone in Android apps.
class MinimalIoTControlScreen extends StatefulWidget {
  final bool autoConnectFirebase;
  final Function(String, dynamic)? onControlAction;
  
  const MinimalIoTControlScreen({
    super.key,
    this.autoConnectFirebase = true,
    this.onControlAction,
  });

  @override
  State<MinimalIoTControlScreen> createState() => _MinimalIoTControlScreenState();
}

class _MinimalIoTControlScreenState extends State<MinimalIoTControlScreen> {
  bool _isInitialized = false;
  String _connectionStatus = 'Initializing...';
  bool _isControlling = false;

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

  Future<void> _controlDevice(String device, dynamic value) async {
    if (!_isInitialized) return;
    
    setState(() {
      _isControlling = true;
    });

    try {
      await MinimalFirebaseService.instance.writeData(device, value);
      
      // Notify callback if provided
      if (widget.onControlAction != null) {
        widget.onControlAction!(device, value);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$device set to $value'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to control $device: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isControlling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: IoTStateManager.instance,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IoT Control'),
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        body: _isInitialized ? _buildControlContent() : _buildLoadingContent(),
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

  Widget _buildControlContent() {
    return Consumer<IoTStateManager>(
      builder: (context, stateManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectionStatusCard(stateManager),
              const SizedBox(height: 24),
              const Text(
                'Device Controls',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLightsControl(stateManager),
              const SizedBox(height: 16),
              _buildWindowControl(stateManager),
              const SizedBox(height: 16),
              _buildFireSystemControl(stateManager),
              const SizedBox(height: 24),
              _buildQuickActions(),
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

  Widget _buildLightsControl(IoTStateManager stateManager) {
    final lightsOn = stateManager.lightsStatus == true;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: lightsOn ? Colors.yellow[700] : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Lights Control',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Current Status: ${lightsOn ? 'On' : 'Off'}',
              style: TextStyle(
                color: lightsOn ? Colors.yellow[700] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isControlling ? null : () => _controlDevice('lights', true),
                    icon: const Icon(Icons.lightbulb),
                    label: const Text('Turn On'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[600],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isControlling ? null : () => _controlDevice('lights', false),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Turn Off'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWindowControl(IoTStateManager stateManager) {
    final windowOpen = stateManager.isWindowOpen == true;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.window,
                  color: windowOpen ? Colors.orange[700] : Colors.green[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Window Control',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Current Status: ${windowOpen ? 'Open' : 'Closed'}',
              style: TextStyle(
                color: windowOpen ? Colors.orange[700] : Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isControlling ? null : () => _controlDevice('windowOpen', true),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isControlling ? null : () => _controlDevice('windowOpen', false),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFireSystemControl(IoTStateManager stateManager) {
    final fireDetected = stateManager.isFire == true;
    
    return Card(
      color: fireDetected ? Colors.red[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: fireDetected ? Colors.red[700] : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Fire System',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Current Status: ${fireDetected ? 'Fire Detected!' : 'Normal'}',
              style: TextStyle(
                color: fireDetected ? Colors.red[700] : Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (fireDetected)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isControlling ? null : () => _controlDevice('fire', false),
                  icon: const Icon(Icons.clear),
                  label: const Text('Reset Fire Alert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else
              Text(
                'Fire system monitoring automatically. No manual controls needed.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _isControlling ? null : () => _controlDevice('lights', false),
                  icon: const Icon(Icons.bedtime),
                  label: const Text('Night Mode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isControlling ? null : () async {
                    await _controlDevice('lights', true);
                    await Future.delayed(const Duration(milliseconds: 500));
                    await _controlDevice('windowOpen', false);
                  },
                  icon: const Icon(Icons.wb_sunny),
                  label: const Text('Day Mode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isControlling ? null : () async {
                    await _controlDevice('lights', false);
                    await Future.delayed(const Duration(milliseconds: 500));
                    await _controlDevice('windowOpen', false);
                  },
                  icon: const Icon(Icons.security),
                  label: const Text('Secure Mode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}