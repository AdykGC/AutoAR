// ================= IMPORTS =================
/* [ Dart ] */
import 'dart:convert';

/* [ Flutter ] */
import 'package:flutter/material.dart';

/* [ Widgets ] */
import 'package:frontend_mobile/widgets/common_widgets.dart';

/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';

/* [ Service ] */
import 'package:frontend_mobile/services/auth_register_service.dart';

/* [ Screen ] */
import 'package:frontend_mobile/screens/auth/login_screen.dart';
import 'package:frontend_mobile/screens/main/main_screen.dart';


// ================= WIDGET =================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


// ================= STATE =================

class _RegisterScreenState extends State<RegisterScreen> {
  // -------- CONTROLLERS --------
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // -------- UI STATE --------
  bool _loading = false;
  bool _passwordVisible = false;

  // -------- ERROR STATES --------
  String? _emailError; String? _passwordError; String? _confirmError;


  // ================= LIFECYCLE =================

  @override
  void initState() {
    super.initState();
    // Реалтайм валидация
    _emailController.addListener(_validateEmailOnChange);
    _passwordController.addListener(_validatePasswordOnChange);
    _confirmController.addListener(_validateConfirmOnChange);
  }

  @override
  void dispose() {
    // Удаление listeners
    _emailController.removeListener(_validateEmailOnChange);
    _passwordController.removeListener(_validatePasswordOnChange);
    _confirmController.removeListener(_validateConfirmOnChange);

    // Освобождение ресурсов
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();

    super.dispose();
  }


// ================= VALIDATION (REALTIME) =================
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


// ================= FORM VALIDATION =================

  bool _validateForm() {
    setState(() {
      _emailError = AuthRegisterService.validateEmail(_emailController.text);
      _passwordError = AuthRegisterService.validatePassword(_passwordController.text);
      _confirmError = AuthRegisterService.validatePasswordConfirmation( _passwordController.text,  _confirmController.text );
    });
    return _emailError == null && _passwordError == null && _confirmError == null;
  }


  // ================= AUTH LOGIC =================

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
      if (mounted) { setState(() => _loading = false); }
    }
  }


  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  
                  // -------- TITLE --------
                  Text(
                    'Создать аккаунт',
                    style: TextStyle(
                      color: AppStyles.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStyles.fontFamily,
                    ),
                  ), const SizedBox(height: 32),

                  // -------- EMAIL --------
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    errorText: _emailError,
                  ), const SizedBox(height: 20),

                  // -------- PASSWORD --------
                  CustomTextField(
                    label: 'Пароль',
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
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
                    errorText: _passwordError,
                  ), const SizedBox(height: 20),

                  // -------- CONFIRM PASSWORD --------
                  CustomTextField(
                    label: 'Подтвердите пароль',
                    controller: _confirmController,
                    obscureText: !_passwordVisible,
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
                    errorText: _confirmError,
                  ), const SizedBox(height: 32),


                  // -------- REGISTER BUTTON --------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppStyles.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Зарегистрироваться'),
                    ),
                  ),

                  // -------- LOGIN NAVIGATION --------
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Уже есть аккаунт? Войти',
                      style: TextStyle(color: AppStyles.accent),
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
