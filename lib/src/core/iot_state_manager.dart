import 'package:flutter/foundation.dart';

/// Minimal IoT state manager for core functionality
/// 
/// Manages only essential IoT device states: fire detection,
/// window status, and lights status with Firebase sync.
class IoTStateManager extends ChangeNotifier {
  static IoTStateManager? _instance;
  
  // Core IoT states
  bool? _isFire;
  bool? _isWindowOpen;
  bool? _lightsStatus;
  bool _firebaseConnected = false;
  DateTime? _lastUpdated;
  
  // Singleton pattern
  IoTStateManager._();
  
  factory IoTStateManager() {
    _instance ??= IoTStateManager._();
    return _instance!;
  }
  
  /// Get singleton instance
  static IoTStateManager get instance {
    _instance ??= IoTStateManager._();
    return _instance!;
  }

  // Getters for core IoT states
  bool? get isFire => _isFire;
  bool? get isWindowOpen => _isWindowOpen;
  bool? get lightsStatus => _lightsStatus;
  bool get firebaseConnected => _firebaseConnected;
  DateTime? get lastUpdated => _lastUpdated;

  // Setters for core IoT states
  set isFire(bool? value) {
    if (_isFire != value) {
      _isFire = value;
      _updateTimestamp();
      notifyListeners();
    }
  }

  set isWindowOpen(bool? value) {
    if (_isWindowOpen != value) {
      _isWindowOpen = value;
      _updateTimestamp();
      notifyListeners();
    }
  }

  set lightsStatus(bool? value) {
    if (_lightsStatus != value) {
      _lightsStatus = value;
      _updateTimestamp();
      notifyListeners();
    }
  }

  set firebaseConnected(bool connected) {
    if (_firebaseConnected != connected) {
      _firebaseConnected = connected;
      _updateTimestamp();
      notifyListeners();
    }
  }

  void _updateTimestamp() {
    _lastUpdated = DateTime.now();
  }

  /// Convert state to map for external access (Android integration)
  Map<String, dynamic> toMap() {
    return {
      'isFire': _isFire,
      'isWindowOpen': _isWindowOpen,
      'lightsStatus': _lightsStatus,
      'firebaseConnected': _firebaseConnected,
      'lastUpdated': _lastUpdated?.toIso8601String(),
    };
  }

  /// Update state from external data (Android integration)
  void updateFromMap(Map<String, dynamic> data) {
    _isFire = data['isFire'];
    _isWindowOpen = data['isWindowOpen'];
    _lightsStatus = data['lightsStatus'];
    _firebaseConnected = data['firebaseConnected'] ?? false;
    
    if (data['lastUpdated'] != null) {
      _lastUpdated = DateTime.tryParse(data['lastUpdated']);
    }
    
    notifyListeners();
  }

  /// Reset all states
  void reset() {
    _isFire = null;
    _isWindowOpen = null;
    _lightsStatus = null;
    _firebaseConnected = false;
    _lastUpdated = null;
    notifyListeners();
  }

  /// Check if any critical alert is active
  bool get hasCriticalAlert => _isFire == true;
  
  /// Check if any warning alert is active
  bool get hasWarningAlert => _isWindowOpen == true;

  /// Get status summary for display
  String get statusSummary {
    if (_isFire == true) return "FIRE DETECTED";
    if (_isWindowOpen == true) return "WINDOW OPEN";
    if (_lightsStatus == true) return "LIGHTS ON";
    return "All OK";
  }
}