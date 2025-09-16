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
                  'FIRE ALERT', 
                  'Fire detected in IoT system!'
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
      print('All core IoT data streams started successfully');
      
    } catch (e) {
      print('Error starting core data streams: $e');
      _streamsActive = false;
      stateManager.firebaseConnected = false;
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
    IoTStateManager.instance.firebaseConnected = false;
    
    print('All core IoT data streams stopped');
  }
  
  /// Control device state (lights, window)
  Future<void> controlDevice(String deviceType, bool state) async {
    if (!_initialized || _database == null) {
      throw StateError('Firebase service not initialized');
    }
    
    try {
      DatabaseReference? ref;
      
      switch (deviceType) {
        case 'lights':
          ref = _lightsRef;
          break;
        case 'windowOpen':
          ref = _windowRef;
          break;
        default:
          throw ArgumentError('Unknown device type: $deviceType');
      }
      
      if (ref != null) {
        await ref.set(state);
        print('Device $deviceType set to $state');
      }
      
    } catch (e) {
      print('Error controlling device $deviceType: $e');
      throw e;
    }
  }
  
  /// Handle Firebase connection errors
  void _handleFirebaseError(String dataType, dynamic error) {
    print('Firebase error for $dataType: $error');
    
    // Update connection status
    IoTStateManager.instance.firebaseConnected = false;
    
    // Attempt reconnection after delay
    Timer(Duration(seconds: 5), () {
      if (_initialized && !_streamsActive) {
        print('Attempting to reconnect $dataType stream...');
        startCoreDataStreams();
      }
    });
  }
  
  /// Dispose and cleanup
  void dispose() {
    stopCoreDataStreams();
    _initialized = false;
    _firebaseApp = null;
    _database = null;
    print('Minimal Firebase service disposed');
  }
}