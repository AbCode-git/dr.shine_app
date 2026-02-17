import 'package:flutter/material.dart';

void main() {
  print('TEST MAIN: App starting...');
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'TEST SUCCESSFUL: Flutter is Rendering!',
            style: TextStyle(fontSize: 24, color: Colors.green),
          ),
        ),
      ),
    ),
  );
}
