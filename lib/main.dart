import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:advantis_iot/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:advantis_iot/screens/splash_screen.dart';
import 'package:advantis_iot/utils/app_state.dart';
import 'package:advantis_iot/screens/settings_screen.dart';
import 'package:advantis_iot/screens/landing_screen.dart';
import 'package:advantis_iot/screens/onboarding_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  );
  runApp(ChangeNotifierProvider( create: (context) => AppState(),child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/':(context) => SplashScreen(),
        '/home':(context) => HomeScreen(),
        '/settings':(context) => SettingsScreen(),
        '/landing':(context) => LandingScreen(),
        '/onboarding':(context) => OnboardingScreen(),
      },
      initialRoute: '/',
    );
  }
}
