import 'package:flutter/material.dart';
import 'package:advantis_iot/advantis_iot.dart';

/// Example of using the Minimal Advantis IoT Module
/// 
/// This demonstrates how to integrate the minimal IoT module
/// into an existing Android app with completely independent screens.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the minimal IoT module
  await MinimalAdvantisIoTModule.initialize(
    enableAndroidIntegration: true,
  );
  
  // Start monitoring IoT devices
  await MinimalAdvantisIoTModule.startMonitoring();
  
  runApp(MinimalIoTExampleApp());
}

class MinimalIoTExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal IoT Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ExampleHomeScreen(),
    );
  }
}

class ExampleHomeScreen extends StatefulWidget {
  @override
  State<ExampleHomeScreen> createState() => _ExampleHomeScreenState();
}

class _ExampleHomeScreenState extends State<ExampleHomeScreen> {
  int _selectedIndex = 0;
  
  // This is how you would use the minimal module in your existing Android app
  late final List<Widget> _screens = [
    // Your existing app content with embedded dashboard
    _buildMainAppContent(),
    
    // Independent IoT status screen
    MinimalAdvantisIoTModule.createStatusScreen(
      onStateChanged: (state) {
        print('IoT state changed: $state');
        // Handle state changes in your Android app
      },
    ),
    
    // Independent IoT control screen
    MinimalAdvantisIoTModule.createControlScreen(
      onControlAction: (action, value) {
        print('Control action: $action = $value');
        // Handle control actions in your Android app
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor),
            label: 'IoT Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'IoT Control',
          ),
        ],
      ),
    );
  }
  
  /// Example of your existing app content with embedded IoT dashboard
  Widget _buildMainAppContent() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Existing App'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your App Content',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            // Your existing widgets
            Card(
              child: ListTile(
                title: Text('Your Feature 1'),
                subtitle: Text('Some app functionality'),
                leading: Icon(Icons.star),
              ),
            ),
            SizedBox(height: 16),
            
            // Embedded IoT Dashboard - completely independent
            Text(
              'IoT System Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            // Compact dashboard embedded in your app
            MinimalAdvantisIoTModule.createDashboard(
              compact: true,
              height: 80,
              onTap: () {
                // Navigate to full IoT status screen
                setState(() => _selectedIndex = 1);
              },
              onStateChanged: (state) {
                // Handle IoT state changes in your app
                if (state['isFire'] == true) {
                  _showFireAlert();
                }
              },
            ),
            
            SizedBox(height: 16),
            
            // Detailed dashboard
            MinimalAdvantisIoTModule.createDashboard(
              compact: false,
              height: 150,
              onTap: () {
                // Navigate to control screen
                setState(() => _selectedIndex = 2);
              },
            ),
            
            SizedBox(height: 16),
            
            // More of your app content
            Expanded(
              child: Card(
                child: Center(
                  child: Text('Rest of your app content'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFireAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔥 FIRE ALERT'),
        content: Text('Fire detected in IoT system!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Example showing how to use individual components
class StandaloneExamples {
  
  /// Example: Embed just the dashboard in your existing screen
  static Widget embeddedDashboardExample() {
    return Column(
      children: [
        Text('Your existing content'),
        // Embedded compact dashboard
        MinimalAdvantisIoTModule.createDashboard(
          compact: true,
          onStateChanged: (state) {
            // React to IoT state changes
            print('IoT state: $state');
          },
        ),
        Text('More of your content'),
      ],
    );
  }
  
  /// Example: Use status screen independently
  static Widget statusScreenExample() {
    return MinimalAdvantisIoTModule.createStatusScreen(
      onStateChanged: (state) {
        // Send to your Android app via method channel
        print('Send to Android: $state');
      },
    );
  }
  
  /// Example: Use control screen independently  
  static Widget controlScreenExample() {
    return MinimalAdvantisIoTModule.createControlScreen(
      onControlAction: (action, value) {
        // Handle control actions in your Android app
        print('Control: $action = $value');
      },
    );
  }
  
  /// Example: Get current state for Android integration
  static void androidIntegrationExample() {
    // Get current state
    Map<String, dynamic> state = MinimalAdvantisIoTModule.getCurrentState();
    
    // Check specific statuses
    bool? fireStatus = MinimalAdvantisIoTModule.getFireStatus();
    bool? windowStatus = MinimalAdvantisIoTModule.getWindowStatus();
    bool? lightsStatus = MinimalAdvantisIoTModule.getLightsStatus();
    
    // Control devices
    MinimalAdvantisIoTModule.controlLights(true);
    MinimalAdvantisIoTModule.controlWindow(false);
    
    // Listen to state changes
    MinimalAdvantisIoTModule.addStateListener(() {
      print('State changed: ${MinimalAdvantisIoTModule.getCurrentState()}');
    });
  }
}