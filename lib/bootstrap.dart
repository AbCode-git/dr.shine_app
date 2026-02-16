import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:dr_shine_app/core/services/service_locator.dart';

/// Global flag to check if Firebase is available
bool isFirebaseInitialized = false;

/// Handles initializations before the app runs.
Future<void> bootstrap() async {
  try {
    if (kIsWeb) {
      developer.log(
          'Bootstrap: Running on web. Skipping Firebase init for mock testing.');
      isFirebaseInitialized = false;
      locator.setup();
      return;
    }

    // Initialize Firebase for mobile
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
    developer.log('Firebase initialized successfully');
  } catch (e) {
    developer.log('Error initializing Firebase: $e');
    isFirebaseInitialized = false;
  } finally {
    locator.setup();
  }
}
