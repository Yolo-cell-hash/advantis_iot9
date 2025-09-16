import 'package:flutter/material.dart';
import 'package:advantis_iot/advantis_iot.dart';

/// Example implementation of the Advantis IoT module
/// 
/// This demonstrates how to use the module in a Flutter app.
/// For production use, call AdvantisIoTModule.initialize() in your main app
/// and use individual screens as needed.
void main() async {
  await AdvantisIoTModule.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdvantisIoTModule.createApp();
  }
}
