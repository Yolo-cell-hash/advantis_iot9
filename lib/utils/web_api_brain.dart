import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:advantis_iot/utils/app_state.dart';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/material.dart';
import 'package:advantis_iot/screens/landing_screen.dart';


class WebApi {

  static const String apiKey = 'e8q0y264i3nxjw2pn9p2pxtbo0ub4n3b';
  static const String baseUrl =
      'https://hmut-api-gdb2c.binary-labs.in';
  dynamic response = '';
  dynamic tokens;

  Future<void> requestOTP(BuildContext context) async {
    String phoneNumber = Provider.of<AppState>(context,listen: false).phoneNumber;
    // Note: It's good practice for async methods that don't return a specific value
    // to have a Future<void> return type.

    // Removed the unnecessary extra curly braces
    Provider.of<AppState>(context, listen: false).spinner = true;
    Map<String, String> requestBody = {
      'countryCode': '+91', // Dummy country code
      'phoneNumber': phoneNumber,
    };

    String jsonBody = jsonEncode(requestBody);

    print('Clicked');
    try {
      response = await http.post(
        Uri.parse('$baseUrl/integrators/v1/auth/request-otp'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
        },
        body: jsonBody,
      );
      print('Response status: ${response.statusCode}');

      if(response.statusCode==200){
        Provider.of<AppState>(context, listen: false).otpSent = true;
      }

      print('Response body: ${response.body}');
    } catch (e) {
      print('Error making POST request: $e');
      // Handle error appropriately, e.g., show a message to the user
    } finally {
      // Ensure spinner is always turned off, even if an error occurs
      Provider.of<AppState>(context, listen: false).spinner = false;
    }
    // It's generally better to handle the response body where you need it,
    // rather than just printing it here.
    // print(response.body);
  }

  Future<void> verifyOTP(BuildContext context,dynamic otp) async {
    String phoneNumber = Provider.of<AppState>(context,listen: false).phoneNumber;
    Provider.of<AppState>(context, listen: false).spinner = true;
    Map<String, dynamic> requestBody = {
      'countryCode': '+91', // Dummy country code
      'phoneNumber': phoneNumber, // Dummy phone number
      'otp': otp,
    };

    String jsonBody = jsonEncode(requestBody);

    try {
      response = await http.post(
        // Changed from http.get to http.post
        Uri.parse(
          '$baseUrl/integrators/v1/auth/verify-otp',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
        },
        body: jsonBody, // Add the encoded body here
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(
          response.body,
        );
        String? extractedAccessToken =
        responseData['accessToken'];
        print(
          'Acess Token is ------------------- $extractedAccessToken --------------------------',
        );
        Provider.of<AppState>(context, listen: false).accessToken = extractedAccessToken!;
        Provider.of<AppState>(context, listen: false).spinner = false;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LandingScreen(),
          ),
        );

      }else{
        Provider.of<AppState>(context, listen: false).spinner = false;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text:"Invalid OTP",
          confirmBtnColor: Colors.red,
        );
      }
    } catch (e) {
      print('Error making POST request: $e');
      Provider.of<AppState>(context, listen: false).spinner = false;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text:e.toString(),
      );
    }
  }

  Future<void> getLockList(BuildContext context) async{
    {
      Provider.of<AppState>(context, listen: false).spinner = true;
      String accessToken = Provider.of<AppState>(context,listen: false).accessToken;


      try {
        response = await http.get(
          Uri.parse('$baseUrl/integrators/v1/lock/list'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          List<dynamic> responseData = jsonDecode(
            response.body,
          );
          Map<String, dynamic> lockId = responseData[0];
          String? _lockId = lockId['lockId'];
          print(
            'Lock ID is ------------------- $_lockId --------------------------',
          );

          Provider.of<AppState>(context, listen: false).lockID = _lockId!;
        }

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        Provider.of<AppState>(context, listen: false).spinner = false;

      } catch (e) {
        print('Error making GET request: $e');
        Provider.of<AppState>(context, listen: false).spinner = false;

      }
    }
  }

}