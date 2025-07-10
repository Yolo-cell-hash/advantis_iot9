import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String _phoneNumber = '';
  String _accessToekn = '';
  String _lockID = '';
  bool _spinner = false;
  bool _otpSent = false;
  dynamic _otp ;

  dynamic get otp => _otp;

  String get phoneNumber => _phoneNumber;
  String get accessToken => _accessToekn;
  String get lockID => _lockID;

  bool get spinner => _spinner;
  bool get otpSent => _otpSent;


  set phoneNumber(String newValue) {
    _phoneNumber = newValue;
    notifyListeners(); // Notify listeners about the change
  }

  set otp(dynamic newValue) {
    _otp = newValue;
    notifyListeners(); // Notify listeners about the change
  }

  set accessToken(String newValue) {
    _accessToekn = newValue;
    notifyListeners(); // Notify listeners about the change
  }

  set spinner(bool newValue) {
    _spinner = newValue;
    notifyListeners(); // Notify listeners about the change
  }

  set otpSent(bool newValue) {
    _otpSent = newValue;
    notifyListeners(); // Notify listeners about the change
  }

  set lockID(String newValue) {
    _lockID = newValue;
    notifyListeners(); // Notify listeners about the change
  }

}
