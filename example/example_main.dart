import 'package:flutter/material.dart';
import 'package:advantis_iot/advantis_iot.dart';

/// Example app demonstrating how to use the Advantis IoT module
/// in your Flutter application.
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

class ExampleHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advantis IoT Module Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Advantis IoT Module Integration Examples',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
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
            
            // Option 2: Use individual screens
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdvantisIoTModule.withProvider(
                      AdvantisIoTModule.homeScreen(),
                    ),
                  ),
                );
              },
              child: Text('Open IoT Home Screen'),
            ),
            SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdvantisIoTModule.withProvider(
                      AdvantisIoTModule.settingsScreen(),
                    ),
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
                    builder: (context) => AdvantisIoTModule.withProvider(
                      AdvantisIoTModule.onboardingScreen(),
                    ),
                  ),
                );
              },
              child: Text('Open Onboarding Screen'),
            ),
            SizedBox(height: 32),
            
            Text(
              'Integration Status:',
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
    );
  }
}