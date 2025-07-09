import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_database/firebase_database.dart';

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
  static const String baseUrl =
      'https://hmut-api-gdb2c.binary-labs.in';

  dynamic phoneNumber;
  String tokenType = "Bearer";
  dynamic otp;
  dynamic lockID;
  bool spinner = false;
  dynamic tokens;
  dynamic dbResponse ;
  late DatabaseReference _dbRef; // To store your database reference
  StreamSubscription<DatabaseEvent>? _dbSubscription;

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
    controller = AnimationController(
      vsync: this,
      // duration: Duration(seconds: 3),
    );
    super.initState();
    _initialization = Firebase.initializeApp();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: _initialization,
        builder: (context,snapshot){
          if(snapshot.hasError){
            return Scaffold(body: Center(child: Text('Something Went Wrong!'),),);
          }

          if(snapshot.connectionState==ConnectionState.done){
            FirebaseApp firebaseApp = Firebase.app(); // Or snapshot.data as FirebaseApp
            FirebaseDatabase database = FirebaseDatabase.instanceFor(
                app: firebaseApp,
                databaseURL: 'https://iot9systemintegration-default-rtdb.asia-southeast1.firebasedatabase.app/');
            DatabaseReference ref = FirebaseDatabase.instance.ref();

            return Scaffold(
              body: ModalProgressHUD(
                inAsyncCall: spinner,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextField(
                          keyboardType: TextInputType.number,

                          decoration: InputDecoration(
                            label: Text('Enter Phone Number'),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value){
                            setState(() {
                              phoneNumber = value;
                            });
                          },
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                spinner=true;
                              });
                              Map<String, String> requestBody = {
                                'countryCode': '+91', // Dummy country code
                                'phoneNumber': phoneNumber
                              };

                              String jsonBody = jsonEncode(requestBody);

                              print('Clicked');
                              try {
                                response = await http.post( // Changed from http.get to http.post
                                  Uri.parse('${baseUrl}/integrators/v1/auth/request-otp'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'x-api-key': apiKey,
                                  },
                                  body: jsonBody, // Add the encoded body here
                                );
                                setState(() {
                                  showResponse = true;
                                });
                                print('Response status: ${response.statusCode}');
                                print('Response body: ${response.body}');

                                setState(() {
                                  spinner=false;
                                });
                              } catch (e) {
                                print('Error making POST request: $e');
                                // Handle error appropriately, e.g., show a message to the user
                                setState(() {
                                  spinner=false;
                                  showResponse = false; // Or handle error display
                                });
                              }

                              setState(() {
                                showResponse = true;
                              });
                              print(response.body);
                            },
                            child: Text('Get OTP'),
                          ),
                        ),
                        SizedBox(height: 20.0,),
                        Divider(height: 5.0,),
                        if (showResponse) SelectableText(response.body),
                        Divider(height: 5.0,),
                        SizedBox(height: 20.0,),

                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(

                            label: Text('Enter OTP'),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value){
                            setState(() {
                              otp = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              spinner=true;
                            });
                            Map<String, dynamic> requestBody = {
                              'countryCode': '+91', // Dummy country code
                              'phoneNumber': phoneNumber, // Dummy phone number
                              'otp' : otp,
                            };

                            String jsonBody = jsonEncode(requestBody);


                            try {

                              response = await http.post( // Changed from http.get to http.post
                                Uri.parse('$baseUrl/integrators/v1/auth/verify-otp'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'x-api-key': apiKey,
                                },
                                body: jsonBody, // Add the encoded body here
                              );
                              setState(() {
                                showResponse = true;
                              });
                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');

                              if(response.statusCode == 200){
                                Map<String, dynamic> responseData = jsonDecode(response.body);
                                String? extractedAccessToken = responseData['accessToken'];
                                print('Acess Token is ------------------- $extractedAccessToken --------------------------');

                                setState(() {
                                  tokens = extractedAccessToken;
                                });
                              }

                              setState(() {
                                spinner=false;
                              });

                            } catch (e) {
                              print('Error making POST request: $e');
                              // Handle error appropriately, e.g., show a message to the user
                              setState(() {
                                showResponse = false; // Or handle error display
                              });
                              setState(() {
                                spinner=false;
                              });
                            }

                          },
                          child: Text('Verify OTP'),
                        ),
                        if (showWeather) Text(weather),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              spinner=true;
                            });

                            try {
                              response = await http.get( // Changed from http.get to http.post
                                Uri.parse('$baseUrl/integrators/v1/lock/list'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': '$tokenType $tokens',
                                },

                              );
                              setState(() {
                                showResponse = true;
                              });

                              if(response.statusCode == 200){
                                List<dynamic> responseData = jsonDecode(response.body);
                                Map<String,dynamic> lockId = responseData[0];
                                String? _lockId = lockId['lockId'];
                                print('Lock ID is ------------------- $_lockId --------------------------');

                                setState(() {
                                  lockID = _lockId;
                                });
                              }

                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');

                              setState(() {
                                spinner=false;
                              });
                            } catch (e) {
                              print('Error making GET request: $e');
                              // Handle error appropriately, e.g., show a message to the user
                              setState(() {
                                showResponse = false; // Or handle error display
                              });
                              setState(() {
                                spinner=false;
                              });
                            }

                          },
                          child: Text('Get Lock List'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              spinner=true;
                            });
                            print(lockID);
                            Map<String, dynamic> requestBody = {
                              'LOCK_ID' : lockID.toString(),
                            };

                            String jsonBody = jsonEncode(requestBody);


                            try {
                              response = await http.post( // Changed from http.get to http.post
                                Uri.parse('$baseUrl/integrators/v1/lock/${lockID}/unlock-request'),
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

                              if(response.statusCode == 200){
                                print('Lock Unlocked Successfully !!!');
                              }

                              setState(() {
                                spinner=false;
                              });

                            } catch (e) {
                              print('Error making POST request: $e');
                              // Handle error appropriately, e.g., show a message to the user
                              setState(() {
                                showResponse = false; // Or handle error display
                              });
                              setState(() {
                                spinner=false;
                              });
                            }
                          },
                          child: Text('Unlock Door'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              spinner=true;
                            });
                            try {
                              response = await http.get( // Changed from http.get to http.post
                                Uri.parse('$baseUrl/integrators/v1/lock/${lockID}/status'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': '$tokenType $tokens',
                                },

                              );
                              setState(() {
                                showResponse = true;
                              });

                              if(response.statusCode == 200){
                                print(response.body);
                              }

                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');

                              setState(() {
                                spinner=false;
                              });
                            } catch (e) {
                              print('Error making GET request: $e');
                              // Handle error appropriately, e.g., show a message to the user
                              setState(() {
                                showResponse = false; // Or handle error display
                              });
                              setState(() {
                                spinner=false;
                              });
                            }

                          },
                          child: Text('Get Lock Status'),
                        ),

                        ElevatedButton(onPressed: ()async{
                          setState(() {
                            spinner=true;
                          });
                          print('Reading');

                          final dataSnapshot = await ref.child("test").get();
                          if (dataSnapshot.exists) {
                            setState(() {
                              spinner=false;
                              dbResponse = dataSnapshot.value;
                            });
                            print("Data: ${dataSnapshot.value}");
                          } else {
                            setState(() {
                              spinner=false;
                            });
                            print("The value from db is -  $dbResponse");
                            print("No data at path");
                          }

                        }, child: Text('Read From Database'),),
                        Divider(height: 10.0,),
                        if (dbResponse != null) SelectableText(dbResponse.toString()),
                        Divider(height: 10.0,),

                        // ElevatedButton(onPressed: showDoneDialog, child: Text('Unlock Door')),
                        // Center(child: Lottie.asset('animations/lock.json'),)
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return Scaffold(body: Center(child: CircularProgressIndicator(),),);
        }
      ),
    );
  }
}
