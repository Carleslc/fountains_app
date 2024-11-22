import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../exceptions/error.dart';
import '../firebase_options.dart';
import '../utils/logger.dart';

class FirebaseService {
  // Singleton service
  factory FirebaseService() => _instance;
  static final _instance = FirebaseService._();
  FirebaseService._();

  /// Ensure Firebase services are initialized
  static bool isInitialized = false;

  /// Firebase Auth
  FirebaseAuth get auth {
    if (!isInitialized) {
      throw FirebaseNotInitializedException();
    }
    return _auth!;
  }

  FirebaseAuth? _auth;

  /// Firebase Analytics
  FirebaseAnalytics get analytics {
    if (!isInitialized) {
      throw FirebaseNotInitializedException();
    }
    return _analytics!;
  }

  FirebaseAnalytics? _analytics;

  /// Firebase Crashlytics
  FirebaseCrashlytics? _crashlytics;

  /// Initialize Firebase
  Future<void> initialize() async {
    // Initialize Firebase app
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Auth
    _auth = FirebaseAuth.instance;

    // Initialize Firebase Analytics
    _analytics = FirebaseAnalytics.instance;

    // Initialize Firebase Crashlytics
    _initializeCrashlytics();

    isInitialized = true;

    debug('Firebase initialized');
  }

  /// Initialize Firebase Crashlytics to handle uncaught errors
  void _initializeCrashlytics() {
    final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
    _crashlytics = crashlytics;

    // Pass all uncaught fatal errors from the Flutter framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      // Log error to console (custom error logger)
      exception(
        errorDetails.exception,
        stackTrace: errorDetails.stack,
        report: false, // reported below
        fatal: true,
      );

      // Report error to Crashlytics
      crashlytics.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that are not handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      // Log error to console and report to Crashlytics (custom error logger handler)
      exception(
        error,
        stackTrace: stack,
        report: true,
        fatal: true,
      );
      // handled (avoid default uncaught error handler)
      return true;
    };
  }

  /// Report [error] with [reason] and [stackTrace] to Crashlytics
  void reportError(
    dynamic error, {
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) {
    if (!isInitialized) return;

    _crashlytics!.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }
}

/// Firebase is not initialized
class FirebaseNotInitializedException extends AppException {
  @override
  String get message => 'Firebase is not initialized';
}
