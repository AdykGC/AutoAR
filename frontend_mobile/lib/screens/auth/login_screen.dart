import 'dart:convert';                                                // jsonDecode
import 'package:flutter/material.dart';
import 'package:frontend_mobile/widgets/common_widgets.dart';         // [ Widgets ]
import 'package:frontend_mobile/styles/app_styles.dart';              // [ Styles ]
import 'package:frontend_mobile/services/auth_service.dart';          // [ Services ]
import 'package:frontend_mobile/screens/home_screen.dart';            // [ Screens ]
import 'package:frontend_mobile/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty) { _showError('Введите email'); setState(() => _loading = false); return; }
    if (_passwordController.text.isEmpty) { _showError('Введите пароль'); setState(() => _loading = false); return; }

    try {
      await AuthService.login(_emailController.text, _passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Вход успешен!')), );
      // =================== Изменение: Переход на MainScreen ===================
      Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const MainScreen()), );
    } catch (e) {
      debugPrint('Ошибка входа: $e');
      // Ловим ошибки и выводим безопасно в Xcode 
      // Если это JSON от Laravel — пытаемся распарсить
      try {
        final jsonError = jsonDecode(e.toString().replaceAll('Exception: ', ''));
        debugPrint('JSON ошибки Laravel: $jsonError');

        // Если сервер возвращает ошибки
        if (jsonError.containsKey('errors')) {
          final errors = jsonError['errors'] as Map<String, dynamic>;
          String errorMessage = '';
          errors.forEach((key, value) {
            final message = value is List ? value.first : value.toString();
            errorMessage += '$message\n';
          });
          _showError(errorMessage.trim());
        } else {
          _showError('Ошибка входа: ${e.toString()}');
        }
      } catch (_) {
        debugPrint('Не удалось распарсить JSON ошибки');
        _showError('Ошибка входа: ${e.toString()}');
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(text), backgroundColor: Colors.redAccent, ), );
  }

  void _showSuccess(String text) {
    ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(text), ), );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Заголовок
                  Text(
                    'Добро пожаловать',
                    style: TextStyle(
                      color: AppStyles.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStyles.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Войдите в свой аккаунт',
                    style: TextStyle(
                      color: AppStyles.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),

                  // Пароль
                  CustomTextField(
                    label: 'Пароль',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 32),

                  // Кнопка входа с градиентом
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppStyles.accent,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Войти'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Кнопка регистрации
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Создать аккаунт',
                      style: TextStyle(
                        color: AppStyles.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}