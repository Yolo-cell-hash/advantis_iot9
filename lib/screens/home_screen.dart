import 'dart:async';
import 'dart:convert';
import 'package:advantis_iot/widgets/brand_logo_name.dart';
import 'package:advantis_iot/widgets/ip_port_textfield.dart';
import 'package:advantis_iot/widgets/privacy_conditions_hyper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:advantis_iot/utils/app_state.dart';
import 'package:advantis_iot/utils/web_api_brain.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  dynamic dbResponse1;
  late DatabaseReference _dbRef,_dbRef1;
  StreamSubscription<DatabaseEvent>? _dbSubscription,_dbSubscription1;

  final buttonStyleEnabled = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    minimumSize: const Size(double.infinity, 50),
  );

  WebApi webApi = WebApi();

  late Future<FirebaseApp> _initialization;
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
    controller = AnimationController(vsync: this);
    super.initState();
    _initialization = Firebase.initializeApp();

    _initialization.then((firebaseApp) {
      // Ensure Firebase is initialized
      FirebaseDatabase database = FirebaseDatabase.instanceFor(
        app: firebaseApp,
        databaseURL:
            'https://iot9systemintegration-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _dbRef1 = database.ref("updates");

      _dbSubscription = _dbRef1.onValue.listen(
        (DatabaseEvent event) {
          if (mounted) {
            setState(() {
              if (event.snapshot.exists) {
                dbResponse1 = event.snapshot.value;

                print('DATABASE SNAPSHOT IS $dbResponse1');
                Provider.of<AppState>(context, listen: false).setUpdates(dbResponse1);

                print("VALUE STORED IN PROVIDER IS -------------- ${Provider
                    .of<AppState>(context, listen: false)
                    .update}");


                if (dbResponse1.toString() == "true") {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    title: 'Alert',
                    text: 'Window Breach Alert',
                    confirmBtnColor: Colors.green,
                  );
                }
                print("Data updated: ${event.snapshot.value}");
              } else {
                dbResponse1 = null; // Or handle as "No data"
                print("No data at path");
                Provider.of<AppState>(context, listen: false).setUpdates(null);
              }
            });
          }
        },
        onError: (error) {
          // Handle potential errors, e.g., permission denied
          print("Error listening to database: $error");
          if (mounted) {
            setState(() {
              spinner = false;
            });
          }
        },
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        controller.reset();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _dbSubscription?.cancel(); // Cancel the database listener
    _dbSubscription1?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = Provider.of<AppState>(context).spinner;
    return SafeArea(
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          String phoneNumber = Provider.of<AppState>(context).phoneNumber;
          bool wasOtpSent = Provider.of<AppState>(context).otpSent;
          dynamic typedOTP = Provider.of<AppState>(context).otp;
          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('Something Went Wrong!')));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            FirebaseApp firebaseApp =
                Firebase.app(); // Or snapshot.data as FirebaseApp
            FirebaseDatabase database = FirebaseDatabase.instanceFor(
              app: firebaseApp,
              databaseURL:
                  'https://iot9systemintegration-default-rtdb.asia-southeast1.firebasedatabase.app/',
            );
            DatabaseReference ref = FirebaseDatabase.instance.ref();

            return Scaffold(
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
            );
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
