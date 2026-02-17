import 'package:flutter/material.dart';
import 'package:dr_shine_app/bootstrap.dart';
import 'package:dr_shine_app/app/app.dart';

void main() async {
  debugPrint('main: Starting app...');
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services and Supabase via bootstrap
  debugPrint('main: Calling bootstrap...');
  await bootstrap();
  debugPrint('main: Bootstrap complete. Running app...');

  // Run the app
  runApp(const DrShineApp());
}
