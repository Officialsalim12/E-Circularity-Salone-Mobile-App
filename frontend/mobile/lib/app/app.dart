import 'package:flutter/material.dart';

import 'app_colors.dart';
import '../features/authentication/presentation/splash_screen.dart';

/// Root widget for the Circular Salone mobile application.
class CircularSaloneApp extends StatelessWidget {
  const CircularSaloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circular Salone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      home: const SplashScreen(),
    );
  }
}
