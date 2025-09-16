import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../utils/app_state.dart';
import 'android_integration_service.dart';

/// Firebase service manager for the Advantis IoT module
/// 
/// Provides centralized Firebase initialization, database connections,
/// and real-time data synchronization across all module screens.
class FirebaseService {
  static FirebaseService? _instance;
  static bool _initialized = false;
  
  FirebaseApp? _firebaseApp;
  FirebaseDatabase? _database;
  String? _fcmToken;
  
  // Database references and subscriptions
  DatabaseReference? _updatesRef;
  DatabaseReference? _windowRef;
  DatabaseReference? _fireRef;
  DatabaseReference? _lightsRef;
  
  StreamSubscription<DatabaseEvent>? _updatesSubscription;
  StreamSubscription<DatabaseEvent>? _windowSubscription;
  StreamSubscription<DatabaseEvent>? _fireSubscription;
  StreamSubscription<DatabaseEvent>? _lightsSubscription;
  
  // Database URL configuration
  static const String _databaseUrl = 
      'https://iot9systemintegration-default-rtdb.asia-southeast1.firebasedatabase.app/';
  
  // Private constructor
  FirebaseService._();
  
  /// Get singleton instance
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }
  
  /// Initialize Firebase service
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _firebaseApp = await Firebase.initializeApp();
      _database = FirebaseDatabase.instanceFor(
        app: _firebaseApp!,
        databaseURL: _databaseUrl,
      );
      
      // Initialize FCM token
      await _initializeFCMToken();
      
      _initialized = true;
    } catch (e) {
      print('Error initializing Firebase service: $e');
      rethrow;
    }
  }
  
  /// Check if service is initialized
  bool get isInitialized => _initialized;
  
  /// Get Firebase app instance
  FirebaseApp? get firebaseApp => _firebaseApp;
  
  /// Get Firebase database instance
  FirebaseDatabase? get database => _database;
  
  /// Get FCM token
  String? get fcmToken => _fcmToken;
  
  /// Initialize FCM token
  Future<void> _initializeFCMToken() async {
    try {
      _fcmToken = await FirebaseMessaging.instance.getToken();
      if (_fcmToken != null) {
        print('FCM Token initialized: $_fcmToken');
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }
  
  /// Start listening to all Firebase data streams and update AppState
  Future<void> startDataStreams(BuildContext context) async {
    if (!_initialized || _database == null) {
      throw Exception('Firebase service not initialized');
    }
    
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Initialize database references
    _updatesRef = _database!.ref("updates");
    _windowRef = _database!.ref("window_status");
    _fireRef = _database!.ref("fire_status");
    _lightsRef = _database!.ref("lights_status");
    
    // Listen to updates
    _updatesSubscription = _updatesRef!.onValue.listen(
      (DatabaseEvent event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value;
          appState.setUpdates(data);
          print('Updates data received: $data');
          
          // Send to Android if integration is enabled
          if (AndroidIntegrationService.isAndroidIntegration) {
            AndroidIntegrationService.sendStateUpdate(appState.toMap());
          }
        } else {
          appState.setUpdates(null);
        }
      },
      onError: (error) {
        print('Error listening to updates: $error');
        if (AndroidIntegrationService.isAndroidIntegration) {
          AndroidIntegrationService.sendAlert('error', 'Firebase Error', 'Error listening to updates: $error');
        }
      },
    );
    
    // Listen to window status
    _windowSubscription = _windowRef!.onValue.listen(
      (DatabaseEvent event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value;
          appState.isWindowOpen = data;
          print('Window status received: $data');
          
          // Send to Android if integration is enabled
          if (AndroidIntegrationService.isAndroidIntegration) {
            AndroidIntegrationService.sendStateUpdate(appState.toMap());
            if (data == true) {
              AndroidIntegrationService.sendAlert('warning', 'Window Alert', 'Window is open');
            }
          }
        } else {
          appState.isWindowOpen = null;
        }
      },
      onError: (error) {
        print('Error listening to window status: $error');
      },
    );
    
    // Listen to fire status
    _fireSubscription = _fireRef!.onValue.listen(
      (DatabaseEvent event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value;
          appState.isFire = data;
          print('Fire status received: $data');
          
          // Send to Android if integration is enabled
          if (AndroidIntegrationService.isAndroidIntegration) {
            AndroidIntegrationService.sendStateUpdate(appState.toMap());
            if (data == true) {
              AndroidIntegrationService.sendAlert('critical', 'Fire Alert', 'Fire detected!');
            }
          }
        } else {
          appState.isFire = null;
        }
      },
      onError: (error) {
        print('Error listening to fire status: $error');
      },
    );
    
    // Listen to lights status
    _lightsSubscription = _lightsRef!.onValue.listen(
      (DatabaseEvent event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value;
          appState.lightsStatus = data;
          print('Lights status received: $data');
        } else {
          appState.lightsStatus = null;
        }
      },
      onError: (error) {
        print('Error listening to lights status: $error');
      },
    );
    
    // Store FCM token in database if available
    if (_fcmToken != null) {
      await _storeFCMToken();
    }
  }
  
  /// Store FCM token in database
  Future<void> _storeFCMToken() async {
    if (_updatesRef != null && _fcmToken != null) {
      try {
        await _updatesRef!.child("fcmDeviceToken").set(_fcmToken);
        print('FCM Token stored in database: $_fcmToken');
      } catch (e) {
        print('Error storing FCM token: $e');
      }
    }
  }
  
  /// Store access token in database
  Future<void> storeAccessToken(String accessToken) async {
    if (_updatesRef != null) {
      try {
        await _updatesRef!.child('accessToken').set(accessToken);
        print('Access token stored: $accessToken');
      } catch (e) {
        print('Error storing access token: $e');
      }
    }
  }
  
  /// Stop all data streams
  void stopDataStreams() {
    _updatesSubscription?.cancel();
    _windowSubscription?.cancel();
    _fireSubscription?.cancel();
    _lightsSubscription?.cancel();
    
    _updatesSubscription = null;
    _windowSubscription = null;
    _fireSubscription = null;
    _lightsSubscription = null;
    
    print('All Firebase data streams stopped');
  }
  
  /// Write data to a specific path
  Future<void> writeData(String path, dynamic value) async {
    if (_database == null) {
      throw Exception('Firebase database not initialized');
    }
    
    try {
      await _database!.ref(path).set(value);
      print('Data written to $path: $value');
    } catch (e) {
      print('Error writing data to $path: $e');
      rethrow;
    }
  }
  
  /// Read data from a specific path
  Future<dynamic> readData(String path) async {
    if (_database == null) {
      throw Exception('Firebase database not initialized');
    }
    
    try {
      final snapshot = await _database!.ref(path).get();
      if (snapshot.exists) {
        return snapshot.value;
      }
      return null;
    } catch (e) {
      print('Error reading data from $path: $e');
      rethrow;
    }
  }
  
  /// Dispose and cleanup resources
  void dispose() {
    stopDataStreams();
    _firebaseApp = null;
    _database = null;
    _fcmToken = null;
    _updatesRef = null;
    _windowRef = null;
    _fireRef = null;
    _lightsRef = null;
    _initialized = false;
    _instance = null;
  }
}