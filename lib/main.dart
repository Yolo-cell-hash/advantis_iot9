import 'package:flutter/material.dart';
import 'package:advantis_iot/advantis_iot.dart';

/// Example implementation of the simplified Advantis IoT module
/// 
/// This demonstrates the minimal setup needed to use the IoT monitoring
/// functionality in a Flutter app or Android integration.
void main() async {
  // Initialize the core IoT module with Android integration support
  await CoreIoTModule.initialize(enableAndroidIntegration: true);
  
  runApp(const IoTExampleApp());
}

class IoTExampleApp extends StatelessWidget {
  const IoTExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advantis IoT Module',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Use the standalone IoT monitoring screen directly
      home: const StandaloneIoTScreen(
        title: 'IoT Device Monitoring',
      ),
    );
  }
}
