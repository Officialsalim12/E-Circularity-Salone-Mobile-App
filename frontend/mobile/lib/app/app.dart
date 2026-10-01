import 'package:flutter/material.dart';

/// Root widget for the Circular Salone mobile application.
///
/// Product screens are not part of this foundation. Navigation, theme,
/// and startup behavior will be attached here when feature work begins.
class CircularSaloneApp extends StatelessWidget {
  const CircularSaloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Circular Salone',
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('Circular Salone'),
          ),
        ),
      ),
    );
  }
}
