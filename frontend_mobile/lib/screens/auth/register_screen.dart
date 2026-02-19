import 'dart:convert'; // <- для jsonDecode
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_widgets.dart';
import '../../styles/app_styles.dart';
import 'login_screen.dart';

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

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Пароли не совпадают')), );
      setState(() => _loading = false);
      return;
    }

    try {
      await AuthService.register( _emailController.text, _passwordController.text, _confirmController.text, );
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Регистрация успешна!')), );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Ошибка регистрации: $e'); // Ловим ошибки и выводим безопасно в Xcode 
      // Если это JSON от Laravel — пытаемся распарсить
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
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Register',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmController,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          child: const Text('Register'),
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
