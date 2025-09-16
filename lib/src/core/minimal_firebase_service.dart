import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'iot_state_manager.dart';
import '../services/android_integration_service.dart';

/// Minimal Firebase service for core IoT monitoring
/// 
/// Provides Firebase connectivity for only the essential
/// IoT states: fire detection, window status, and lights status.
class MinimalFirebaseService {
  static MinimalFirebaseService? _instance;
  
  FirebaseApp? _firebaseApp;
  FirebaseDatabase? _database;
  
  // Database references for core IoT data
  DatabaseReference? _windowRef;
  DatabaseReference? _fireRef;
  DatabaseReference? _lightsRef;
  
  // Stream subscriptions for core data
  StreamSubscription<DatabaseEvent>? _windowSubscription;
  StreamSubscription<DatabaseEvent>? _fireSubscription;
  StreamSubscription<DatabaseEvent>? _lightsSubscription;
  
  // Database configuration
  static const String databaseURL = "https://smart-lock-93f0a-default-rtdb.firebaseio.com/";
  
  bool _initialized = false;
  bool _streamsActive = false;
  
  // Singleton pattern
  MinimalFirebaseService._();
  
  static MinimalFirebaseService get instance {
    _instance ??= MinimalFirebaseService._();
    return _instance!;
  }
  
  bool get isInitialized => _initialized;
  bool get streamsActive => _streamsActive;
  
  /// Initialize Firebase connection
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _firebaseApp = await Firebase.initializeApp();
      _database = FirebaseDatabase.instanceFor(
        app: _firebaseApp!,
        databaseURL: databaseURL,
      );
      
      // Set up database references for core IoT data
      _windowRef = _database!.ref().child("windowOpen");
      _fireRef = _database!.ref().child("fire");
      _lightsRef = _database!.ref().child("lights");
      
      _initialized = true;
      print('Minimal Firebase service initialized successfully');
      
    } catch (e) {
      print('Error initializing Firebase: $e');
      throw e;
    }
  }
  
  /// Start listening to core IoT data streams
  Future<void> startCoreDataStreams() async {
    if (!_initialized) {
      throw StateError('Firebase service must be initialized before starting streams');
    }
    
    if (_streamsActive) return;
    
    final stateManager = IoTStateManager.instance;
    
    try {
      // Listen to window status
      _windowSubscription = _windowRef!.onValue.listen(
        (DatabaseEvent event) {
          if (event.snapshot.exists) {
            final data = event.snapshot.value;
            final isOpen = data == true;
            stateManager.isWindowOpen = isOpen;
            print('Window status updated: $isOpen');
            
            // Send to Android if integration is enabled
            if (AndroidIntegrationService.isAndroidIntegration) {
              AndroidIntegrationService.sendStateUpdate(stateManager.toMap());
              if (isOpen) {
                AndroidIntegrationService.sendAlert(
                  'warning', 
                  'Window Alert', 
                  'Window is open'
                );
              }
            }
          } else {
            stateManager.isWindowOpen = null;
          }
        },
        onError: (error) {
          print('Error listening to window status: $error');
          _handleFirebaseError('window', error);
        },
      );
      
      // Listen to fire status
      _fireSubscription = _fireRef!.onValue.listen(
        (DatabaseEvent event) {
          if (event.snapshot.exists) {
            final data = event.snapshot.value;
            final fireDetected = data == true;
            stateManager.isFire = fireDetected;
            print('Fire status updated: $fireDetected');
            
            // Send to Android if integration is enabled
            if (AndroidIntegrationService.isAndroidIntegration) {
              AndroidIntegrationService.sendStateUpdate(stateManager.toMap());
              if (fireDetected) {
                AndroidIntegrationService.sendAlert(
                  'critical', 
                  'Fire Alert', 
                  'Fire detected!'
                );
              }
            }
          } else {
            stateManager.isFire = null;
          }
        },
        onError: (error) {
          print('Error listening to fire status: $error');
          _handleFirebaseError('fire', error);
        },
      );
      
      // Listen to lights status
      _lightsSubscription = _lightsRef!.onValue.listen(
        (DatabaseEvent event) {
          if (event.snapshot.exists) {
            final data = event.snapshot.value;
            final lightsOn = data == true;
            stateManager.lightsStatus = lightsOn;
            print('Lights status updated: $lightsOn');
            
            // Send to Android if integration is enabled
            if (AndroidIntegrationService.isAndroidIntegration) {
              AndroidIntegrationService.sendStateUpdate(stateManager.toMap());
            }
          } else {
            stateManager.lightsStatus = null;
          }
        },
        onError: (error) {
          print('Error listening to lights status: $error');
          _handleFirebaseError('lights', error);
        },
      );
      
      _streamsActive = true;
      stateManager.firebaseConnected = true;
      
      // Notify Android of connection status
      if (AndroidIntegrationService.isAndroidIntegration) {
        AndroidIntegrationService.sendFirebaseStatus(true);
      }
      
      print('Core IoT data streams started successfully');
      
    } catch (e) {
      print('Error starting core data streams: $e');
      throw e;
    }
  }
  
  /// Stop all core data streams
  void stopCoreDataStreams() {
    _windowSubscription?.cancel();
    _fireSubscription?.cancel();
    _lightsSubscription?.cancel();
    
    _windowSubscription = null;
    _fireSubscription = null;
    _lightsSubscription = null;
    
    _streamsActive = false;
    
    final stateManager = IoTStateManager.instance;
    stateManager.firebaseConnected = false;
    
    // Notify Android of disconnection
    if (AndroidIntegrationService.isAndroidIntegration) {
      AndroidIntegrationService.sendFirebaseStatus(false);
    }
    
    print('Core IoT data streams stopped');
  }
  
  /// Write data to Firebase (for controlling devices)
  Future<void> writeData(String path, dynamic value) async {
    if (!_initialized) {
      throw StateError('Firebase service must be initialized before writing data');
    }
    
    try {
      await _database!.ref().child(path).set(value);
      print('Data written to Firebase path: $path, value: $value');
    } catch (e) {
      print('Error writing data to Firebase: $e');
      throw e;
    }
  }
  
  /// Read data from Firebase
  Future<dynamic> readData(String path) async {
    if (!_initialized) {
      throw StateError('Firebase service must be initialized before reading data');
    }
    
    try {
      final snapshot = await _database!.ref().child(path).get();
      if (snapshot.exists) {
        return snapshot.value;
      }
      return null;
    } catch (e) {
      print('Error reading data from Firebase: $e');
      throw e;
    }
  }
  
  void _handleFirebaseError(String dataType, dynamic error) {
    if (AndroidIntegrationService.isAndroidIntegration) {
      AndroidIntegrationService.sendAlert(
        'error',
        'Firebase Error',
        'Error listening to $dataType data: $error'
      );
    }
  }
  
  /// Dispose of all resources
  void dispose() {
    stopCoreDataStreams();
    _database = null;
    _firebaseApp = null;
    _initialized = false;
  }
}