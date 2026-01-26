import 'package:flutter/material.dart';
import 'package:dr_shine_app/bootstrap.dart';
import 'package:dr_shine_app/app/app.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services and Firebase via bootstrap
  await bootstrap();
  
  // Run the app
  runApp(const DrShineApp());
}
