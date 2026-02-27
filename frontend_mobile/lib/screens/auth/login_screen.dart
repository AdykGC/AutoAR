// ================= IMPORTS =================
/* [ Dart ] */
import 'dart:convert';

/* [ Flutter ] */
import 'package:flutter/material.dart';

/* [ Widgets ] */
import 'package:frontend_mobile/widgets/common_widgets.dart';

/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';

/* [ Services ] */
import 'package:frontend_mobile/services/auth_login_service.dart';
import 'package:frontend_mobile/services/auth_token_service.dart';

/* [ Screens ] */
import 'package:frontend_mobile/screens/main/main_screen.dart';
import 'package:frontend_mobile/screens/auth/register_screen.dart';


// ================= WIDGET =================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


// ================= STATE =================

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Loading state
  bool _loading = false;
  bool _passwordVisible = false;

  // ================= LIFECYCLE =================
  @override
    void initState() {
        super.initState();
        _checkExistingToken();
    }

  // ================= AUTH LOGIC =================
    Future<void> _checkExistingToken() async {
        final hasToken = await AuthTokenService.hasToken();
        if (hasToken) {
            debugPrint('Найден существующий токен, переходим на главную');
            if (mounted) { Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const MainScreen()), ); }
        }
    }

    void _login() async {
    setState(() => _loading = true);
    FocusScope.of(context).unfocus();

    // Валидация на клиенте
    if (_emailController.text.isEmpty) { 
        _showError('Введите email'); 
        setState(() => _loading = false); 
        return; 
    }
    
    if (!_emailController.text.contains('@')) {
        _showError('Введите корректный email');
        setState(() => _loading = false);
        return;
    }
    
    if (_passwordController.text.isEmpty) { 
        _showError('Введите пароль'); 
        setState(() => _loading = false); 
        return; 
    }
    
    if (_passwordController.text.length < 6) {
        _showError('Пароль должен содержать минимум 6 символов');
        setState(() => _loading = false);
        return;
    }

    try {
        await AuthLoginService.login(_emailController.text, _passwordController.text);
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Успешный вход
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar( 
                SnackBar(
                    content: const Text('Вход успешен!'),
                    backgroundColor: Colors.green,
                ), 
            );
            
            // Переход на главный экран
            Navigator.pushReplacement( 
                context, 
                MaterialPageRoute(builder: (context) => const MainScreen()), 
            );
        }
        
    } catch (e) {
      
        debugPrint('Ошибка входа: $e');
        
        // Показываем пользователю понятное сообщение
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        // Специфические сообщения для разных ошибок
        if (errorMessage.contains('email') && errorMessage.contains('password')) {
            errorMessage = 'Неверный email или пароль';
        } else if (errorMessage.contains('connection')) {
            errorMessage = 'Проверьте подключение к интернету';
        }
        
        _showError(errorMessage);
        
    } finally { 
        if (mounted) {
            setState(() => _loading = false); 
        }
    }
}


  // ================= UI HELPERS =================

  /// Показ ошибки
  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(text), backgroundColor: Colors.redAccent, ), );
  }

  /// Показ успеха
  void _showSuccess(String text) {
    ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(text), ), );
  }


  // ================= UI =================

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

                  // -------- TITLE --------

                  Text(
                    'Добро пожаловать',
                    style: TextStyle(
                      color: AppStyles.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStyles.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ), const SizedBox(height: 12),

                  Text(
                    'Войдите в свой аккаунт',
                    style: TextStyle(
                      color: AppStyles.textSecondary,
                      fontSize: 16,
                    ),
                  ), const SizedBox(height: 40),

                  // -------- EMAIL --------

                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 20),

                  // -------- PASSWORD --------

                  CustomTextField(
                    label: 'Пароль',
                    controller: _passwordController,
                    obscureText: !_passwordVisible, // управление видимостью
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() { _passwordVisible = !_passwordVisible; });
                      },
                    ),
                  ),


                  const SizedBox(height: 32),

                  // -------- LOGIN BUTTON --------

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
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

                  // -------- REGISTER BUTTON --------

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