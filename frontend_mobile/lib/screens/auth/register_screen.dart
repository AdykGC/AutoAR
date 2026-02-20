import 'dart:convert';
import 'package:flutter/material.dart';
/* [ Widgets ] */
import 'package:frontend_mobile/widgets/common_widgets.dart';
/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';
/* [ Service ] */
import 'package:frontend_mobile/services/auth_register_service.dart';
/* [ Screen ] */
import 'package:frontend_mobile/screens/auth/login_screen.dart';
import 'package:frontend_mobile/screens/home_screen.dart';

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
  String? _emailError; String? _passwordError; String? _confirmError;


  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmailOnChange);
    _passwordController.addListener(_validatePasswordOnChange);
    _confirmController.addListener(_validateConfirmOnChange);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmailOnChange);
    _passwordController.removeListener(_validatePasswordOnChange);
    _confirmController.removeListener(_validateConfirmOnChange);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _validateEmailOnChange() {
    setState(() { _emailError = AuthRegisterService.validateEmail(_emailController.text); });
  }

  void _validatePasswordOnChange() {
    setState(() { _passwordError = AuthRegisterService.validatePassword(_passwordController.text); });
    if (_confirmController.text.isNotEmpty) { _validateConfirmOnChange(); }
  }

  void _validateConfirmOnChange() {
    setState(() { _confirmError = AuthRegisterService.validatePasswordConfirmation( _passwordController.text, _confirmController.text ); });
  }


  bool _validateForm() {
    setState(() {
      _emailError = AuthRegisterService.validateEmail(_emailController.text);
      _passwordError = AuthRegisterService.validatePassword(_passwordController.text);
      _confirmError = AuthRegisterService.validatePasswordConfirmation( _passwordController.text,  _confirmController.text );
    });
    return _emailError == null && _passwordError == null && _confirmError == null;
  }


  void _register() async {
    if (!_validateForm()) { setState(() => _loading = false); return; }

    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    try {
      await AuthRegisterService.register(  email: _emailController.text,  password: _passwordController.text, passwordConfirmation: _confirmController.text, );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Регистрация успешна!')), );
        Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const MainScreen()), );
      }
    } catch (e) {
      debugPrint('Ошибка регистрации: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(errorMessage), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating, ), );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 20),

                  // Пароль
                  CustomTextField(
                    label: 'Пароль',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    errorText: _passwordError,
                  ),
                  const SizedBox(height: 20),

                  // Подтверждение пароля
                  CustomTextField(
                    label: 'Подтвердите пароль',
                    controller: _confirmController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    errorText: _confirmError,
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
