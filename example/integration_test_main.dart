import 'package:flutter/material.dart';
import 'package:advantis_iot/minimal_advantis_iot.dart';

/// Integration Test App - Shows how screens work independently
/// 
/// This demonstrates that each screen can be used without dependencies
/// on other screens, making them perfect for Android integration.
void main() async {
  // Initialize minimal module
  await MinimalAdvantisIoTModule.initialize(enableAndroidIntegration: true);
  runApp(const IndependentScreensTestApp());
}

class IndependentScreensTestApp extends StatelessWidget {
  const IndependentScreensTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Independent Screens Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const IndependentScreensDemo(),
    );
  }
}

class IndependentScreensDemo extends StatelessWidget {
  const IndependentScreensDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Independent IoT Screens Demo'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Screen Independence Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Each screen below works completely independently - no navigation dependencies.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Demo 1: Direct screen creation
            _buildSectionTitle('1. Direct Screen Creation'),
            const Text(
              'Screens can be created directly without any setup:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openScreen(
                      context,
                      'Status Screen',
                      MinimalAdvantisIoTModule.createStatusScreen(),
                    ),
                    child: const Text('Open Status Screen'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openScreen(
                      context,
                      'Control Screen',
                      MinimalAdvantisIoTModule.createControlScreen(),
                    ),
                    child: const Text('Open Control Screen'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Demo 2: Embedded dashboard
            _buildSectionTitle('2. Embedded Dashboard Widget'),
            const Text(
              'Dashboard can be embedded anywhere in your existing app:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Your Existing Android App Content',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Embedded IoT Dashboard
                  MinimalAdvantisIoTModule.createDashboard(
                    onTap: () => _openScreen(
                      context,
                      'Full Status',
                      MinimalAdvantisIoTModule.createStatusScreen(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Demo 3: Multiple instances
            _buildSectionTitle('3. Multiple Independent Instances'),
            const Text(
              'Multiple screens can exist simultaneously without conflicts:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () => _openMultipleScreens(context),
              child: const Text('Open Multiple Screens Demo'),
            ),

            const SizedBox(height: 24),

            // Demo 4: API Usage
            _buildSectionTitle('4. Direct API Usage'),
            const Text(
              'Use the module API directly without any screens:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _testAPI(context, 'Get State'),
                  child: const Text('Get Current State'),
                ),
                ElevatedButton(
                  onPressed: () => _testAPI(context, 'Control Lights'),
                  child: const Text('Control Lights'),
                ),
                ElevatedButton(
                  onPressed: () => _testAPI(context, 'Monitor'),
                  child: const Text('Start Monitoring'),
                ),
              ],
            ),

            const SizedBox(height: 32),
            
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ Key Benefits for Android Integration:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text('• Each screen is completely independent'),
                    Text('• No navigation dependencies between screens'),
                    Text('• Can embed widgets in existing Android layouts'),
                    Text('• Direct API access for custom implementations'),
                    Text('• Minimal Firebase setup required'),
                    Text('• Real-time state synchronization'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  void _openScreen(BuildContext context, String title, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
          ),
          body: screen,
        ),
      ),
    );
  }

  void _openMultipleScreens(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Multiple Screens'),
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.dashboard), text: 'Status'),
                  Tab(icon: Icon(Icons.settings_remote), text: 'Control'),
                  Tab(icon: Icon(Icons.widgets), text: 'Dashboard'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                MinimalAdvantisIoTModule.createStatusScreen(),
                MinimalAdvantisIoTModule.createControlScreen(),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Dashboard Widget Example',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      MinimalAdvantisIoTModule.createDashboard(),
                      const Text(
                        'This shows how the dashboard can be embedded anywhere.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _testAPI(BuildContext context, String action) async {
    String result;
    
    try {
      switch (action) {
        case 'Get State':
          final state = MinimalAdvantisIoTModule.getCurrentState();
          result = 'Current State:\n${state.toString()}';
          break;
        case 'Control Lights':
          await MinimalAdvantisIoTModule.controlLights(true);
          result = 'Lights turned ON via API';
          break;
        case 'Monitor':
          await MinimalAdvantisIoTModule.startMonitoring();
          result = 'Monitoring started via API';
          break;
        default:
          result = 'Unknown action';
      }
    } catch (e) {
      result = 'Error: $e';
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(action),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}