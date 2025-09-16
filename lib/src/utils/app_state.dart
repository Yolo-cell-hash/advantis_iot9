import 'package:flutter/foundation.dart';

/// Global app state management for Advantis IoT module
/// 
/// Manages all application state including authentication, device data,
/// and real-time Firebase synchronization across module screens.
class AppState extends ChangeNotifier {
  static AppState? _instance;
  
  String _phoneNumber = '';
  String _accessToken = '';
  String _lockID = '';
  bool _spinner = false;
  bool _otpSent = false;
  dynamic _otp;
  dynamic _update;
  dynamic _isWindowOpen;
  dynamic _isFire;
  dynamic _lightsStatus;
  bool _firebaseConnected = false;
  DateTime? _lastUpdated;
  
  // Singleton pattern for external access
  AppState._();
  
  factory AppState() {
    _instance ??= AppState._();
    return _instance!;
  }
  
  /// Get singleton instance for external access
  static AppState get instance {
    _instance ??= AppState._();
    return _instance!;
  }

  // Getters
  dynamic get otp => _otp;
  dynamic get update => _update;
  dynamic get isWindowOpen => _isWindowOpen;
  dynamic get isFire => _isFire;
  dynamic get lightsStatus => _lightsStatus;
  bool get firebaseConnected => _firebaseConnected;
  DateTime? get lastUpdated => _lastUpdated;

  String get phoneNumber => _phoneNumber;
  String get accessToken => _accessToken;
  String get lockID => _lockID;

  bool get spinner => _spinner;
  bool get otpSent => _otpSent;


  // Setters
  set phoneNumber(String newValue) {
    _phoneNumber = newValue;
    _updateTimestamp();
    notifyListeners();
  }

  set otp(dynamic newValue) {
    _otp = newValue;
    _updateTimestamp();
    notifyListeners();
  }

  set accessToken(String newValue) {
    _accessToken = newValue;
    _updateTimestamp();
    notifyListeners();
  }

  set spinner(bool newValue) {
    _spinner = newValue;
    notifyListeners();
  }

  set otpSent(bool newValue) {
    _otpSent = newValue;
    _updateTimestamp();
    notifyListeners();
  }

  set lockID(String newValue) {
    _lockID = newValue;
    _updateTimestamp();
    notifyListeners();
  }

  set isWindowOpen(dynamic data) {
    _isWindowOpen = data;
    _updateTimestamp();
    notifyListeners();
  }

  set isFire(dynamic data) {
    _isFire = data;
    _updateTimestamp();
    notifyListeners();
  }

  set lightsStatus(dynamic data) {
    _lightsStatus = data;
    _updateTimestamp();
    notifyListeners();
  }

  set firebaseConnected(bool connected) {
    _firebaseConnected = connected;
    _updateTimestamp();
    notifyListeners();
  }

  // Methods
  void setUpdates(dynamic data) {
    _update = data;
    _updateTimestamp();
    notifyListeners();
  }

  void _updateTimestamp() {
    _lastUpdated = DateTime.now();
  }

  /// Reset all state to initial values
  void reset() {
    _phoneNumber = '';
    _accessToken = '';
    _lockID = '';
    _spinner = false;
    _otpSent = false;
    _otp = null;
    _update = null;
    _isWindowOpen = null;
    _isFire = null;
    _lightsStatus = null;
    _firebaseConnected = false;
    _lastUpdated = null;
    notifyListeners();
  }

  /// Get current state as a Map for external access
  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': _phoneNumber,
      'accessToken': _accessToken,
      'lockID': _lockID,
      'spinner': _spinner,
      'otpSent': _otpSent,
      'otp': _otp,
      'update': _update,
      'isWindowOpen': _isWindowOpen,
      'isFire': _isFire,
      'lightsStatus': _lightsStatus,
      'firebaseConnected': _firebaseConnected,
      'lastUpdated': _lastUpdated?.toIso8601String(),
    };
  }

  /// Update state from external data
  void updateFromMap(Map<String, dynamic> data) {
    _phoneNumber = data['phoneNumber'] ?? '';
    _accessToken = data['accessToken'] ?? '';
    _lockID = data['lockID'] ?? '';
    _spinner = data['spinner'] ?? false;
    _otpSent = data['otpSent'] ?? false;
    _otp = data['otp'];
    _update = data['update'];
    _isWindowOpen = data['isWindowOpen'];
    _isFire = data['isFire'];
    _lightsStatus = data['lightsStatus'];
    _firebaseConnected = data['firebaseConnected'] ?? false;
    
    if (data['lastUpdated'] != null) {
      _lastUpdated = DateTime.tryParse(data['lastUpdated']);
    }
    
    notifyListeners();
  }


}
