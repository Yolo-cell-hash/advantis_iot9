import 'package:flutter/material.dart';
import 'package:advantis_iot/minimal_advantis_iot.dart';

/// Example implementation of the Minimal Advantis IoT module
/// 
/// This demonstrates how to use the minimal module for Android integration.
/// Shows completely independent screens that can be used standalone.
void main() async {
  await MinimalAdvantisIoTModule.initialize(enableAndroidIntegration: true);
  runApp(const MinimalIoTExampleApp());
}

class MinimalIoTExampleApp extends StatelessWidget {
  const MinimalIoTExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal IoT Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExampleHomeScreen(),
    );
  }
}

/// Example Android app home screen with embedded IoT functionality
class ExampleHomeScreen extends StatefulWidget {
  const ExampleHomeScreen({super.key});

  @override
  State<ExampleHomeScreen> createState() => _ExampleHomeScreenState();
}

class _ExampleHomeScreenState extends State<ExampleHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start monitoring when the app starts
    MinimalAdvantisIoTModule.startMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Android App'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to My App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your existing Android app content goes here...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Embedded IoT Dashboard - completely independent
            const Text(
              'IoT Monitoring',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            MinimalAdvantisIoTModule.createDashboard(
              onTap: () {
                // Navigate to full IoT status screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MinimalAdvantisIoTModule.createStatusScreen(
                      onFireAlert: () {
                        // Handle fire alert in your Android app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🔥 FIRE DETECTED! Check immediately!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      onWindowAlert: () {
                        // Handle window alert in your Android app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚠️ Window is open'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons for different IoT screens
            const Text(
              'IoT Controls',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MinimalAdvantisIoTModule.createStatusScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('View Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MinimalAdvantisIoTModule.createControlScreen(
                            onControlAction: (device, value) {
                              // Handle control actions in your Android app
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$device set to $value'),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_remote),
                    label: const Text('Control'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick actions using the module API
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await MinimalAdvantisIoTModule.controlLights(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lights turned on')),
                    );
                  },
                  icon: const Icon(Icons.lightbulb),
                  label: const Text('Lights On'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await MinimalAdvantisIoTModule.controlLights(false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lights turned off')),
                    );
                  },
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Lights Off'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final state = MinimalAdvantisIoTModule.getCurrentState();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Current IoT State'),
                        content: Text(state.toString()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.info),
                  label: const Text('Get State'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            const Text(
              'This demonstrates how the minimal IoT module can be easily integrated into your existing Android app.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Optionally stop monitoring when leaving the screen
    // MinimalAdvantisIoTModule.stopMonitoring();
    super.dispose();
  }
}