import 'package:flutter/material.dart';
import 'styles/app_styles.dart';
import 'screens/auth/login_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppStyles.primary,
        scaffoldBackgroundColor: AppStyles.background,
        colorScheme: ColorScheme.dark(
          primary: AppStyles.primary,
          secondary: AppStyles.secondary,
          background: AppStyles.background,
          onPrimary: AppStyles.textPrimary,
          onSecondary: AppStyles.textPrimary,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppStyles.textPrimary, fontFamily: AppStyles.fontFamily),
          bodySmall: TextStyle(color: AppStyles.textSecondary, fontFamily: AppStyles.fontFamily),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}