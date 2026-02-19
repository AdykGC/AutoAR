import 'dart:convert'; // <- добавляем это для jsonDecode
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_widgets.dart';
import '../../styles/app_styles.dart';
import 'register_screen.dart';

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

    // Простая валидация
    if (_emailController.text.isEmpty) {
      _showError('Введите email');
      setState(() => _loading = false);
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Введите пароль');
      setState(() => _loading = false);
      return;
    }

    try {
      await AuthService.login(_emailController.text, _passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Вход успешен!')), );
      // Переход на главный экран
      // Navigator.pushReplacementNamed(context, '/home');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppStyles.errorColor,
      ),
    );
  }

  void _showSuccess(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: AppStyles.screenPadding,
              child: ConstrainedBox(
                constraints: AppStyles.containerConstraints,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Заголовок
                    Text(
                      'Вход',
                      style: AppStyles.titleText,
                    ),
                    const SizedBox(height: 32),
                    
                    // Поле email
                    Padding(
                      padding: AppStyles.fieldPadding,
                      child: CustomTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    
                    // Поле пароля
                    Padding(
                      padding: AppStyles.fieldPadding,
                      child: CustomTextField(
                        label: 'Пароль',
                        controller: _passwordController,
                        obscureText: true,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Кнопка входа
                    PrimaryButton(
                      text: 'Войти',
                      onPressed: _login,
                      isLoading: _loading,
                    ),
                    
                    const SizedBox(height: 16),
                    
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
                      child: const Text('Создать аккаунт'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
