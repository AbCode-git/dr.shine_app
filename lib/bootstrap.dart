import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:dr_shine_app/core/services/service_locator.dart';

bool isSupabaseInitialized = false;

/// Handles initializations before the app runs.
Future<void> bootstrap() async {
  debugPrint('bootstrap: Starting initialization...');
  try {
    debugPrint('bootstrap: Initializing Supabase...');
    await Supabase.initialize(
      url: 'https://fldobwbrdelmxtesnkte.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsZG9id2JyZGVsbXh0ZXNua3RlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMTA5NTksImV4cCI6MjA4Njg4Njk1OX0.OewXyfQe1kRMtFazjQJIKwyz_prithpCHgnsoYUE_2Y',
    );
    isSupabaseInitialized = true;
    debugPrint('bootstrap: Supabase initialized successfully');
  } catch (e) {
    debugPrint('bootstrap: Error initializing Supabase: $e');
    isSupabaseInitialized = false;
  } finally {
    debugPrint('bootstrap: Setting up service locator...');
    locator.setup();
    debugPrint('bootstrap: Initialization finished.');
  }
}
