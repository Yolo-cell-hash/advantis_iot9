import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';

/// Minimal IoT Dashboard Widget - Completely Independent
/// 
/// Compact status widget that can be embedded in any screen.
/// Self-initializes Firebase connection and manages its own state.
/// Perfect for embedding in existing Android app layouts.
class MinimalIoTDashboard extends StatefulWidget {
  /// Callback when dashboard is tapped (for navigation)
  final VoidCallback? onTap;
  
  /// Callback for Android integration when state changes
  final Function(Map<String, dynamic>)? onStateChanged;
  
  /// Whether to show detailed status or compact view
  final bool compact;
  
  /// Custom height for the dashboard (optional)
  final double? height;
  
  const MinimalIoTDashboard({
    Key? key,
    this.onTap,
    this.onStateChanged,
    this.compact = false,
    this.height,
  }) : super(key: key);

  @override
  State<MinimalIoTDashboard> createState() => _MinimalIoTDashboardState();
}

class _MinimalIoTDashboardState extends State<MinimalIoTDashboard> {
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
      
      print('MinimalIoTDashboard initialized independently');
      
    } catch (e) {
      print('Error initializing MinimalIoTDashboard: $e');
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
      return _buildLoadingWidget();
    }

    return ChangeNotifierProvider.value(
      value: _stateManager,
      child: Consumer<IoTStateManager>(
        builder: (context, stateManager, child) {
          return GestureDetector(
            onTap: widget.onTap,
            child: Container(
              height: widget.height,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(widget.compact ? 12.0 : 16.0),
                  child: widget.compact 
                    ? _buildCompactView(stateManager)
                    : _buildDetailedView(stateManager),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildLoadingWidget() {
    return Container(
      height: widget.height ?? (widget.compact ? 80 : 120),
      child: Card(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Initializing IoT...', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompactView(IoTStateManager stateManager) {
    return Row(
      children: [
        // Connection indicator
        Icon(
          stateManager.firebaseConnected ? Icons.cloud_done : Icons.cloud_off,
          color: stateManager.firebaseConnected ? Colors.green : Colors.red,
          size: 20,
        ),
        SizedBox(width: 12),
        
        // Status summary
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'IoT Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                stateManager.statusSummary,
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(stateManager),
                ),
              ),
            ],
          ),
        ),
        
        // Status indicators
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusDot(stateManager.isFire, Colors.red),
            SizedBox(width: 6),
            _buildStatusDot(stateManager.isWindowOpen, Colors.orange),
            SizedBox(width: 6),
            _buildStatusDot(stateManager.lightsStatus, Colors.yellow),
          ],
        ),
        
        // Tap hint
        if (widget.onTap != null) ...[
          SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ],
    );
  }
  
  Widget _buildDetailedView(IoTStateManager stateManager) {
    return Column(
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.dashboard,
              color: Colors.blue,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IoT Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    stateManager.firebaseConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      fontSize: 12,
                      color: stateManager.firebaseConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onTap != null)
              Icon(Icons.open_in_new, color: Colors.grey, size: 18),
          ],
        ),
        
        SizedBox(height: 12),
        
        // Status indicators
        Row(
          children: [
            Expanded(
              child: _buildStatusIndicator(
                'Fire',
                stateManager.isFire,
                Icons.local_fire_department,
                Colors.red,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatusIndicator(
                'Window',
                stateManager.isWindowOpen,
                Icons.window,
                Colors.orange,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildStatusIndicator(
                'Lights',
                stateManager.lightsStatus,
                Icons.lightbulb,
                Colors.yellow,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8),
        
        // Overall status
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: _getStatusColor(stateManager).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            stateManager.statusSummary,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getStatusColor(stateManager),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusDot(bool? status, Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status == true ? color : Colors.grey.withOpacity(0.3),
      ),
    );
  }
  
  Widget _buildStatusIndicator(String label, bool? status, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: status == true ? color : Colors.grey,
          size: 20,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10),
        ),
        Text(
          status == null ? '?' : (status ? 'ON' : 'OFF'),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: status == true ? color : Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Color _getStatusColor(IoTStateManager stateManager) {
    if (stateManager.hasCriticalAlert) return Colors.red;
    if (stateManager.hasWarningAlert) return Colors.orange;
    return Colors.green;
  }
}

/// Standalone function to create dashboard widget for external use
Widget createMinimalIoTDashboard({
  VoidCallback? onTap,
  Function(Map<String, dynamic>)? onStateChanged,
  bool compact = false,
  double? height,
}) {
  return MinimalIoTDashboard(
    onTap: onTap,
    onStateChanged: onStateChanged,
    compact: compact,
    height: height,
  );
}