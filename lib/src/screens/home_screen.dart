import 'dart:async';
import 'dart:convert';
import '../widgets/brand_logo_name.dart';
import '../widgets/ip_port_textfield.dart';
import '../widgets/privacy_conditions_hyper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../utils/app_state.dart';
import '../utils/web_api_brain.dart';
import '../services/firebase_service.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  dynamic response = '';
  dynamic weather = ' ';
  bool showResponse = false;
  late AnimationController controller;
  bool showWeather = false;
  String tokenType = "Bearer";
  dynamic otp;
  dynamic lockID;
  bool spinner = false;
  dynamic tokens;
  bool _firebaseInitialized = false;

  final buttonStyleEnabled = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    minimumSize: const Size(double.infinity, 50),
  );

  Future<void> handler(RemoteMessage message) async {
    print('Title : ${message.notification!.title}');
    print('Title : ${message.notification!.body}');
  }

  Future<void> fbPushNotification() async {
    final firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(handler);
  }

  Future<void> getNotifPermission()async{
    var status = await Permission.notification.status;
    if (status.isDenied) {
      Permission.notification.request();
    }
    if (await Permission.location.isRestricted) {
      Permission.notification.request();
    }
  }

  Future<void> _getToken(String accessToken) async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      try {
        // _dbRef1 currently points to "updates"
        // We will store the token as a key-value pair under "updates"
        // For example: "updates": { "fcmDeviceToken": "your_actual_fcm_token_here", ...other data... }

        // Use a specific key for the FCM token within the 'updates' path
        // This will overwrite any existing value at 'updates/fcmDeviceToken'
        await _dbRef1.child("fcmDeviceToken").set(token);
        await _dbRef1.child('accessToken').set(accessToken);

        setState(() {
          _token = token;
        });
        print('FCM Token: $token successfully written to database at /updates/fcmDeviceToken');
      } catch (e) {
        print('Error writing FCM token to database: $e');
        // Handle any errors
      }
    } else {
      print('Failed to get FCM token.');
    }
  }

  WebApi webApi = WebApi();

  void showDoneDialog() => showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (context) => Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'animations/lock.json',
                repeat: false,
                controller: controller,
                onLoaded: (composition) {
                  controller.duration = composition.duration;
                  controller.forward();
                },
              ),
              Text('Lock Unlocked'),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
  );

  @override
  void initState() {
    fbPushNotification();
    getNotifPermission();
    controller = AnimationController(vsync: this);
    super.initState();
    
    // Initialize Firebase connection if not already done
    _initializeFirebaseConnection();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        controller.reset();
      }
    });
  }

  Future<void> _initializeFirebaseConnection() async {
    if (FirebaseService.instance.isInitialized && !_firebaseInitialized) {
      try {
        // Start Firebase streams if not already started
        await FirebaseService.instance.startDataStreams(context);
        
        // Store access token
        await FirebaseService.instance.storeAccessToken('abcdef');
        
        setState(() {
          _firebaseInitialized = true;
        });
        
        // Listen for updates to show alerts
        _setupUpdateListener();
        
      } catch (e) {
        print('Error initializing Firebase connection: $e');
      }
    }
  }

  void _setupUpdateListener() {
    // Listen to AppState changes for alerts
    final appState = Provider.of<AppState>(context, listen: false);
    appState.addListener(() {
      if (mounted && appState.update?.toString() == "true") {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Alert',
          text: 'Window Breach Alert',
          confirmBtnColor: Colors.green,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    // Firebase streams are managed by the service, no need to cancel here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = Provider.of<AppState>(context).spinner;
    String phoneNumber = Provider.of<AppState>(context).phoneNumber;
    bool wasOtpSent = Provider.of<AppState>(context).otpSent;
    dynamic typedOTP = Provider.of<AppState>(context).otp;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const BrandLogoName(),
                  const PrivacyConditionsHyper(),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.18,
                left: 0,
                right: 0,
                child: IpPortTextfield(
                  onChanged:
                  !wasOtpSent
                      ? (() async =>
                  await webApi.requestOTP(context))
                      : (() async => await webApi.verifyOTP(
                    context,
                    typedOTP,
                  )),
                  label: !wasOtpSent ? 'Phone Number' : 'OTP',
                  btnLabel:
                  !wasOtpSent ? 'Request OTP' : 'Verify OTP',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
