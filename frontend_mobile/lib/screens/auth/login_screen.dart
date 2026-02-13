import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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
    // Закрываем клавиатуру
    FocusScope.of(context).unfocus();
    
    // Простая валидация
    if (_emailController.text.isEmpty) {
      _showError('Введите email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Введите пароль');
      return;
    }
    
    setState(() => _loading = true);
    
    try {
      await ApiService.login(_emailController.text, _passwordController.text);
      _showSuccess('Вход успешен!');
      // TODO: перейти на главный экран
      // Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showError('Ошибка: $e');
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
      SnackBar(content: Text(text)),
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