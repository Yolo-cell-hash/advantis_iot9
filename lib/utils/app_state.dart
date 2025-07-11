import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String _phoneNumber = '';
  String _accessToekn = '';
  String _lockID = '';
  bool _spinner = false;
  bool _otpSent = false;
  dynamic _otp ;
  dynamic _update;
  dynamic _isWindowOpen;
  dynamic _isFire;
  dynamic _lightsStatus;


  dynamic get otp => _otp;
  dynamic get update => _update;
  dynamic get isWindowOpen => _isWindowOpen;
  dynamic get isFire => _isFire;
  dynamic get lightsStatus => _lightsStatus;

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

  void setUpdates(dynamic data) {
    _update = data;
    notifyListeners(); // Important: Notify listeners when the data changes
  }

  set isWindowOpen(dynamic data){
    _isWindowOpen = data;
    notifyListeners();
  }

  set isFire(dynamic data){
    _isFire = data;
    notifyListeners();
  }

  set lightsStatus(dynamic data){
    _lightsStatus = data;
    notifyListeners();
  }


}
