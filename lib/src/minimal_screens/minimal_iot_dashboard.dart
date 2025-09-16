import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/iot_state_manager.dart';

/// Minimal IoT Dashboard Widget - Completely independent
/// 
/// A compact widget showing IoT status for embedding
/// in other screens. Can be used standalone.
class MinimalIoTDashboard extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showTitle;
  final EdgeInsets padding;
  
  const MinimalIoTDashboard({
    super.key,
    this.onTap,
    this.showTitle = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: IoTStateManager.instance,
      child: Consumer<IoTStateManager>(
        builder: (context, stateManager, child) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showTitle) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.home_outlined,
                              color: Colors.blue[700],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'IoT Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              stateManager.firebaseConnected 
                                  ? Icons.cloud_done 
                                  : Icons.cloud_off,
                              color: stateManager.firebaseConnected 
                                  ? Colors.green 
                                  : Colors.red,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusIndicator(
                            'Fire',
                            stateManager.isFire,
                            Icons.local_fire_department,
                            Colors.red,
                          ),
                          _buildStatusIndicator(
                            'Window',
                            stateManager.isWindowOpen,
                            Icons.window,
                            Colors.orange,
                          ),
                          _buildStatusIndicator(
                            'Lights',
                            stateManager.lightsStatus,
                            Icons.lightbulb,
                            Colors.yellow,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildOverallStatus(stateManager),
                      if (stateManager.lastUpdated != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Updated: ${_formatLastUpdated(stateManager.lastUpdated!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(
    String label,
    bool? status,
    IconData icon,
    Color alertColor,
  ) {
    Color indicatorColor;
    
    if (status == null) {
      indicatorColor = Colors.grey;
    } else if (status) {
      indicatorColor = alertColor;
    } else {
      indicatorColor = Colors.green;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: indicatorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: indicatorColor,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: indicatorColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: indicatorColor,
          ),
        ),
        Text(
          status == null ? '?' : (status ? '!' : '✓'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: indicatorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallStatus(IoTStateManager stateManager) {
    String statusText;
    Color statusColor;

    if (stateManager.hasCriticalAlert) {
      statusText = 'CRITICAL ALERT';
      statusColor = Colors.red;
    } else if (stateManager.hasWarningAlert) {
      statusText = 'WARNING';
      statusColor = Colors.orange;
    } else if (stateManager.allSystemsNormal) {
      statusText = 'ALL SYSTEMS NORMAL';
      statusColor = Colors.green;
    } else {
      statusText = 'MONITORING...';
      statusColor = Colors.grey;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        statusText,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: statusColor[700],
          fontSize: 14,
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}