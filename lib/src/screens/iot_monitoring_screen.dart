import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../core_iot_module.dart';

/// Lightweight IoT monitoring dashboard
/// 
/// Shows essential IoT device states without any navigation dependencies.
/// Can be embedded in any Android app as a standalone widget.
class IoTMonitoringDashboard extends StatelessWidget {
  final bool showHeader;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const IoTMonitoringDashboard({
    super.key,
    this.showHeader = true,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.grey[50],
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            const Text(
              'IoT Device Monitoring',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, child) {
                return Column(
                  children: [
                    // Firebase Connection Status
                    _buildConnectionStatus(appState.firebaseConnected),
                    const SizedBox(height: 16),
                    
                    // IoT Device States
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: [
                          _buildDeviceCard(
                            'Fire Detection',
                            appState.isFire,
                            Icons.local_fire_department,
                            _getFireColor(appState.isFire),
                          ),
                          _buildDeviceCard(
                            'Window Status',
                            appState.isWindowOpen,
                            Icons.sensor_window,
                            _getWindowColor(appState.isWindowOpen),
                          ),
                          _buildDeviceCard(
                            'Lights',
                            appState.lightsStatus,
                            Icons.lightbulb,
                            _getLightsColor(appState.lightsStatus),
                          ),
                          _buildLastUpdatedCard(appState.lastUpdated),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(bool connected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: connected ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: connected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connected ? Icons.cloud_done : Icons.cloud_off,
            color: connected ? Colors.green[700] : Colors.red[700],
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            connected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: connected ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(String title, dynamic value, IconData icon, Color color) {
    final displayValue = _formatDeviceValue(value);
    final statusText = _getStatusText(title, value);
    
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            if (displayValue != statusText) ...[
              const SizedBox(height: 2),
              Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedCard(DateTime? lastUpdated) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_time,
              size: 32,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _formatLastUpdated(lastUpdated),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getFireColor(dynamic fireStatus) {
    if (fireStatus == true) return Colors.red[700]!;
    if (fireStatus == false) return Colors.green[600]!;
    return Colors.grey[400]!;
  }

  Color _getWindowColor(dynamic windowStatus) {
    if (windowStatus == true) return Colors.orange[600]!;
    if (windowStatus == false) return Colors.green[600]!;
    return Colors.grey[400]!;
  }

  Color _getLightsColor(dynamic lightsStatus) {
    if (lightsStatus == true) return Colors.amber[600]!;
    if (lightsStatus == false) return Colors.grey[600]!;
    return Colors.grey[400]!;
  }

  String _getStatusText(String deviceType, dynamic value) {
    if (value == null) return 'Unknown';
    
    switch (deviceType) {
      case 'Fire Detection':
        return value == true ? 'ALERT' : 'Normal';
      case 'Window Status':
        return value == true ? 'Open' : 'Closed';
      case 'Lights':
        return value == true ? 'On' : 'Off';
      default:
        return value.toString();
    }
  }

  String _formatDeviceValue(dynamic value) {
    if (value == null) return 'No data';
    if (value is bool) return value ? 'True' : 'False';
    return value.toString();
  }

  String _formatLastUpdated(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Standalone IoT monitoring screen that can be used independently
/// 
/// This screen has no navigation dependencies and can be used directly
/// in Android apps or as part of a larger Flutter application.
class StandaloneIoTScreen extends StatelessWidget {
  final String? title;
  final bool showAppBar;
  final List<Widget>? appBarActions;

  const StandaloneIoTScreen({
    super.key,
    this.title,
    this.showAppBar = true,
    this.appBarActions,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure the widget is wrapped with the provider
    return CoreIoTModule.wrapWithProvider(
      Scaffold(
        appBar: showAppBar ? AppBar(
          title: Text(title ?? 'IoT Monitoring'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          actions: appBarActions,
          automaticallyImplyLeading: false, // Remove back button for independence
        ) : null,
        body: const IoTMonitoringDashboard(),
      ),
    );
  }
}