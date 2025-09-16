import 'package:flutter/material.dart';
import 'package:advantis_iot/advantis_iot.dart';

/// Comprehensive example showing different ways to integrate the Advantis IoT module
/// 
/// This example demonstrates:
/// 1. CoreIoTModule usage (recommended for new integrations)
/// 2. AdvantisIoTModule usage (for full-featured applications)
/// 3. Individual screen usage
/// 4. Real-time state monitoring
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Example 1: Initialize core IoT module (lightweight)
  await CoreIoTModule.initialize(enableAndroidIntegration: true);
  
  // Example 2: Initialize full module (backward compatibility)
  // await AdvantisIoTModule.initialize(enableAndroidIntegration: true);
  
  runApp(const IoTIntegrationExample());
}

class IoTIntegrationExample extends StatelessWidget {
  const IoTIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advantis IoT Integration Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const IntegrationDemoScreen(),
    );
  }
}

class IntegrationDemoScreen extends StatefulWidget {
  const IntegrationDemoScreen({super.key});

  @override
  State<IntegrationDemoScreen> createState() => _IntegrationDemoScreenState();
}

class _IntegrationDemoScreenState extends State<IntegrationDemoScreen> {
  Map<String, dynamic>? currentIoTState;

  @override
  void initState() {
    super.initState();
    _setupStateListener();
  }

  void _setupStateListener() {
    // Listen to real-time IoT state changes
    CoreIoTModule.sharedState.addListener(() {
      setState(() {
        currentIoTState = CoreIoTModule.getCurrentIoTState();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Module Integration Examples'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current State Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current IoT State',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentIoTState?.toString() ?? 'Not available',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Integration Examples
            const Text(
              'Integration Examples',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Example 1: Standalone IoT Screen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StandaloneIoTScreen(
                      title: 'Standalone IoT Monitoring',
                    ),
                  ),
                );
              },
              child: const Text('🚀 Launch Standalone IoT Screen'),
            ),
            const SizedBox(height: 8),
            
            // Example 2: Custom Dashboard with IoT Data
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoreIoTModule.wrapWithProvider(
                      const CustomDashboardExample(),
                    ),
                  ),
                );
              },
              child: const Text('📊 Custom Dashboard with IoT Data'),
            ),
            const SizedBox(height: 8),
            
            // Example 3: Legacy Home Screen (backward compatibility)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdvantisIoTModule.homeScreen(),
                  ),
                );
              },
              child: const Text('🏠 Legacy Home Screen'),
            ),
            const SizedBox(height: 8),
            
            // Example 4: Get Current State
            ElevatedButton(
              onPressed: () {
                final state = CoreIoTModule.getCurrentIoTState();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Current State: $state'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('📋 Get Current IoT State'),
            ),
            const SizedBox(height: 8),
            
            // Example 5: Start/Stop Firebase Monitoring
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await CoreIoTModule.startFirebaseMonitoring(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Firebase monitoring started')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('▶️ Start Monitoring'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      CoreIoTModule.stopFirebaseMonitoring();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Firebase monitoring stopped')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('⏹️ Stop Monitoring'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of a custom dashboard that uses IoT data
class CustomDashboardExample extends StatelessWidget {
  const CustomDashboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom IoT Dashboard'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Custom header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: const Text(
              'This is a custom dashboard that integrates IoT data from the module',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Embedded IoT monitoring dashboard
          const Expanded(
            child: IoTMonitoringDashboard(
              showHeader: false,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}