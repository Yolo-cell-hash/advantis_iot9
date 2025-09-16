import 'package:flutter/material.dart';
import 'package:advantis_iot/advantis_iot.dart';

/// Example app demonstrating how to use the Advantis IoT module
/// in your Flutter application with enhanced Android integration.
void main() async {
  // Initialize the IoT module first
  await AdvantisIoTModule.initialize();
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advantis IoT Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  late AppState _sharedState;
  
  @override
  void initState() {
    super.initState();
    _sharedState = AdvantisIoTModule.sharedState;
    _sharedState.addListener(_onStateChanged);
  }
  
  @override
  void dispose() {
    _sharedState.removeListener(_onStateChanged);
    super.dispose();
  }
  
  void _onStateChanged() {
    if (mounted) {
      setState(() {}); // Trigger UI update when state changes
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advantis IoT Module Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Advantis IoT Module Integration Examples',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              
              // Firebase connection status
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _sharedState.firebaseConnected 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                  border: Border.all(
                    color: _sharedState.firebaseConnected 
                      ? Colors.green 
                      : Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      _sharedState.firebaseConnected 
                        ? '🔗 Firebase Connected'
                        : '⏳ Firebase Disconnected',
                      style: TextStyle(
                        color: _sharedState.firebaseConnected 
                          ? Colors.green 
                          : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_sharedState.lastUpdated != null)
                      Text(
                        'Last Update: ${_sharedState.lastUpdated}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
              // Real-time data display
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Real-time IoT Data',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text('Updates: ${_sharedState.update ?? 'No data'}'),
                      Text('Window Open: ${_sharedState.isWindowOpen ?? 'Unknown'}'),
                      Text('Fire Status: ${_sharedState.isFire ?? 'Unknown'}'),
                      Text('Lights: ${_sharedState.lightsStatus ?? 'Unknown'}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Option 1: Use complete module app
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdvantisIoTModule.createApp(),
                    ),
                  );
                },
                child: Text('Launch Complete IoT App'),
              ),
              SizedBox(height: 16),
              
              // Option 2: Use individual screens with automatic Firebase connection
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdvantisIoTModule.homeScreen(),
                    ),
                  );
                },
                child: Text('Open IoT Home Screen (Auto-Connect)'),
              ),
              SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdvantisIoTModule.settingsScreen(),
                    ),
                  );
                },
                child: Text('Open Settings Screen'),
              ),
              SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdvantisIoTModule.landingScreen(),
                    ),
                  );
                },
                child: Text('Open Landing Screen'),
              ),
              SizedBox(height: 16),
              
              // Manual Firebase control
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await AdvantisIoTModule.startFirebaseStreams(context);
                      },
                      child: Text('Start Firebase'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        AdvantisIoTModule.stopFirebaseStreams();
                      },
                      child: Text('Stop Firebase'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              
              // External access demo
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'External Access (Android Integration)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          final stateMap = AdvantisIoTModule.getCurrentState();
                          print('Current State: $stateMap');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('State logged to console')),
                          );
                        },
                        child: Text('Get Current State'),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Example of updating state from external source
                          AdvantisIoTModule.updateState({
                            'phoneNumber': '+1234567890',
                            'firebaseConnected': true,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('State updated externally')),
                          );
                        },
                        child: Text('Update State Externally'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              Text(
                'Module Status:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AdvantisIoTModule.isInitialized 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color: AdvantisIoTModule.isInitialized 
                      ? Colors.green 
                      : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AdvantisIoTModule.isInitialized 
                    ? '✓ Module Initialized Successfully'
                    : '✗ Module Not Initialized',
                  style: TextStyle(
                    color: AdvantisIoTModule.isInitialized 
                      ? Colors.green 
                      : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}