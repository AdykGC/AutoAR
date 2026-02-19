import 'dart:convert';                                                // jsonDecode
import 'package:flutter/material.dart';
import 'package:frontend_mobile/widgets/common_widgets.dart';         // [ Widgets ]
import 'package:frontend_mobile/styles/app_styles.dart';              // [ Styles ]
import 'package:frontend_mobile/services/auth_service.dart';          // [ Services ]
import 'package:frontend_mobile/screens/auth/login_screen.dart';      // [ Screens ]

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;


  void _register() async {
    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    if (_passwordController.text != _confirmController.text) { ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Пароли не совпадают')), ); setState(() => _loading = false); return; }

    try {
      await AuthService.register( _emailController.text, _passwordController.text, _confirmController.text, );
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Регистрация успешна!')), );
      // =================== Изменение: Переход на MainScreen ===================
      Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const LoginScreen()), );
    } catch (e) {
      debugPrint('Ошибка регистрации: $e');
      try {
        final jsonError = jsonDecode(e.toString().replaceAll('Exception: ', ''));
        debugPrint('JSON ошибки Laravel: $jsonError');
      } catch (_) {
        debugPrint('Не удалось распарсить JSON ошибки');
      }
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Ошибка регистрации: $e')), );
    } finally {
      setState(() => _loading = false);
    }
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
                  Text(
                    'Создать аккаунт',
                    style: TextStyle(
                      color: AppStyles.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStyles.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Введите ваши данные для регистрации',
                    style: TextStyle(
                      color: AppStyles.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

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
                  const SizedBox(height: 20),

                  // Подтверждение пароля
                  CustomTextField(
                    label: 'Подтвердите пароль',
                    controller: _confirmController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 32),

                  // Кнопка регистрации
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
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
                          : const Text('Зарегистрироваться'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Кнопка перехода на логин
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Уже есть аккаунт? Войти',
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
