import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'auth_scope.dart';
import '../features/authentication/data/auth_repository.dart';
import '../features/authentication/presentation/splash_screen.dart';

final AuthRepository _authRepository = AuthRepository(
  baseUrl: const String.fromEnvironment('API_BASE_URL'),
  googleClientId: const String.fromEnvironment('GOOGLE_CLIENT_ID'),
);

/// App shell. Splash is the first screen.
class CircularSaloneApp extends StatelessWidget {
  const CircularSaloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      repository: _authRepository,
      child: MaterialApp(
        title: 'Circular Salone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
