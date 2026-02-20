import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
/* [ Service ] */
import 'services/connect_api_service.dart';
import 'services/auth_token_service.dart';
/* [ Style ] */
import 'styles/app_styles.dart';
/* [ Screen ] */
import 'screens/auth/login_screen.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await ConnectApiService.init();
  final hasToken = await AuthTokenService.hasToken();
  debugPrint('========== ЗАПУСК ПРИЛОЖЕНИЯ ==========');
  debugPrint('Токен при запуске: ${hasToken ? "ЕСТЬ" : "НЕТ"}');
  if (hasToken) {
    final token = await AuthTokenService.getToken();
    debugPrint('Значение токена: $token');
  }
  debugPrint('=======================================');  


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