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
  static const String apiKey = 'e8q0y264i3nxjw2pn9p2pxtbo0ub4n3b';
  static const String baseUrl = 'https://hmut-api-gdb2c.binary-labs.in';
  String tokenType = "Bearer";
  dynamic otp;
  dynamic lockID;
  bool spinner = false;
  dynamic tokens;
  dynamic dbResponse1;
  late DatabaseReference _dbRef1;
  StreamSubscription<DatabaseEvent>? _dbSubscription;

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
      _dbRef1 = database.ref("isWindowOpen");

      _dbSubscription = _dbRef1.onValue.listen(
        (DatabaseEvent event) {
          if (mounted) {
            // Check if the widget is still in the tree
            setState(() {
              if (event.snapshot.exists) {
                dbResponse1 = event.snapshot.value;
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
              }
              spinner =
                  false; // Assuming you might still use spinner for initial load elsewhere
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
              body: ModalProgressHUD(
                inAsyncCall: isLoading,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 15.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IpPortTextfield(
                          onChanged:
                              !wasOtpSent ? (() async => await webApi.requestOTP(context)): (() async => await webApi.verifyOTP(context,typedOTP)),
                          label: !wasOtpSent ? 'Phone Number' : 'OTP',
                          btnLabel: !wasOtpSent ? 'Request OTP' : 'Verify OTP',
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed:

                              () async {
                            setState(() {
                              spinner = true;
                            });

                            try {
                              response = await http.get(
                                Uri.parse('$baseUrl/integrators/v1/lock/list'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': '$tokenType $tokens',
                                },
                              );
                              setState(() {
                                showResponse = true;
                              });

                              if (response.statusCode == 200) {
                                List<dynamic> responseData = jsonDecode(
                                  response.body,
                                );
                                Map<String, dynamic> lockId = responseData[0];
                                String? _lockId = lockId['lockId'];
                                print(
                                  'Lock ID is ------------------- $_lockId --------------------------',
                                );

                                setState(() {
                                  lockID = _lockId;
                                });
                              }

                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');

                              setState(() {
                                spinner = false;
                              });
                            } catch (e) {
                              print('Error making GET request: $e');
                              // Handle error appropriately, e.g., show a message to the user
                              setState(() {
                                showResponse = false; // Or handle error display
                              });
                              setState(() {
                                spinner = false;
                              });
                            }
                          },
                          child: Text('Get Lock List'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              spinner = true;
                            });
                            print(lockID);
                            Map<String, dynamic> requestBody = {
                              'LOCK_ID': lockID.toString(),
                            };

                            String jsonBody = jsonEncode(requestBody);

                            try {
                              response = await http.post(
                                // Changed from http.get to http.post
                                Uri.parse(
                                  '$baseUrl/integrators/v1/lock/${lockID}/unlock-request',
                                ),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'x-api-key': apiKey,
                                  'Authorization': '$tokenType $tokens',
                                  'LOCK_ID': lockID,
                                },
                                body: jsonBody, // Add the encoded body here
                              );
                              setState(() {
                                showResponse = true;
                              });
                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');

                              if (response.statusCode == 200) {
                                print('Lock Unlocked Successfully !!!');
                              }

                              setState(() {
                                spinner = false;
                              });
                            } catch (e) {
                              print('Error making POST request: $e');
                              // Handle error appropriately, e.g., show a message to the user
                              setState(() {
                                showResponse = false; // Or handle error display
                              });
                              setState(() {
                                spinner = false;
                              });
                            }
                          },
                          child: Text('Unlock Door'),
                        ),
                        // ElevatedButton(
                        //   onPressed: () async {
                        //     setState(() {
                        //       spinner=true;
                        //     });
                        //     try {
                        //       response = await http.get( // Changed from http.get to http.post
                        //         Uri.parse('$baseUrl/integrators/v1/lock/${lockID}/status'),
                        //         headers: {
                        //           'Content-Type': 'application/json',
                        //           'Authorization': '$tokenType $tokens',
                        //         },
                        //
                        //       );
                        //       setState(() {
                        //         showResponse = true;
                        //       });
                        //
                        //       if(response.statusCode == 200){
                        //         print(response.body);
                        //       }
                        //
                        //       print('Response status: ${response.statusCode}');
                        //       print('Response body: ${response.body}');
                        //
                        //       setState(() {
                        //         spinner=false;
                        //       });
                        //     } catch (e) {
                        //       print('Error making GET request: $e');
                        //       // Handle error appropriately, e.g., show a message to the user
                        //       setState(() {
                        //         showResponse = false; // Or handle error display
                        //       });
                        //       setState(() {
                        //         spinner=false;
                        //       });
                        //     }
                        //
                        //   },
                        //   child: Text('Get Lock Status'),
                        // ),
                        // ElevatedButton(
                        //   onPressed: () async {
                        //     setState(() {
                        //       spinner=true;
                        //     });
                        //
                        //     try {
                        //       response = await http.get(
                        //         Uri.parse('$baseUrl/integrators/v1/lock/$lockID/activity-trail?page=1'),
                        //         headers: {
                        //           'Content-Type': 'application/json',
                        //           'LOCK_ID': lockID.toString(),
                        //           'Authorization': '$tokenType $tokens',
                        //         },
                        //
                        //       );
                        //       setState(() {
                        //         showResponse = true;
                        //       });
                        //
                        //       if(response.statusCode == 200){
                        //         print('Activites fetched');
                        //       }
                        //
                        //       print('Response status: ${response.statusCode}');
                        //       print('Response body: ${response.body}');
                        //
                        //       setState(() {
                        //         spinner=false;
                        //       });
                        //     } catch (e) {
                        //       print('Error making GET request: $e');
                        //       // Handle error appropriately, e.g., show a message to the user
                        //       setState(() {
                        //         showResponse = false; // Or handle error display
                        //       });
                        //       setState(() {
                        //         spinner=false;
                        //       });
                        //     }
                        //
                        //   },
                        //   child: Text('Get Activity Trials'),
                        // ),
                        Divider(height: 10.0),
                        if (dbResponse1 != null)
                          SelectableText(dbResponse1.toString()),
                        Divider(height: 10.0),

                        // ElevatedButton(onPressed: showDoneDialog, child: Text('Unlock Door')),
                        // Center(child: Lottie.asset('animations/lock.json'),)
                      ],
                    ),
                  ),
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
