import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:dr_shine_app/core/services/service_locator.dart';

/// Global flag to check if Firebase is available
bool isFirebaseInitialized = false;
bool isSupabaseInitialized = false;

/// Handles initializations before the app runs.
Future<void> bootstrap() async {
  try {
    // Initialize Supabase (New Backend)
    await Supabase.initialize(
      url: 'https://fldobwbrdelmxtesnkte.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsZG9id2JyZGVsbXh0ZXNua3RlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMTA5NTksImV4cCI6MjA4Njg4Njk1OX0.OewXyfQe1kRMtFazjQJIKwyz_prithpCHgnsoYUE_2Y',
    );
    isSupabaseInitialized = true;
    developer.log('Supabase initialized successfully');
  } catch (e) {
    developer.log('Error initializing Supabase: $e');
    isSupabaseInitialized = false;
  }

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
