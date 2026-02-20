import 'package:flutter/material.dart';
import 'package:frontend_mobile/styles/app_styles.dart';
import 'package:frontend_mobile/screens/auth/login_screen.dart';
import 'package:frontend_mobile/services/auth_token_service.dart';

class ProfileScreen extends StatefulWidget {
    const ProfileScreen({super.key});

    @override
    State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
    final _nameController = TextEditingController();
    final _surnameController = TextEditingController();
    final _emailController = TextEditingController();

    bool _isLoading = true;
    bool _isSaving = false;
    String? _errorMessage;

    @override
    void initState() { 
        super.initState(); 
        _loadUserProfile(); 
    }
    
    @override
    void dispose() { 
        _nameController.dispose(); 
        _surnameController.dispose(); 
        _emailController.dispose(); 
        super.dispose(); 
    }

    void _navigateToLogin() {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()), 
            (route) => false, 
        );
    }

    void _showError(String message) {
        ScaffoldMessenger.of(context).showSnackBar( 
            SnackBar( 
                content: Text(message), 
                backgroundColor: Colors.redAccent, 
                behavior: SnackBarBehavior.floating, 
            ), 
        );
    }

    Future<void> _loadUserProfile() async {
        setState(() { 
            _isLoading = true; 
            _errorMessage = null; 
        });
        
        try {
            final userData = await AuthTokenService.getUserProfile();
            setState(() { 
                _nameController.text = userData['name'] ?? ''; 
                _surnameController.text = userData['surname'] ?? ''; 
                _emailController.text = userData['email'] ?? ''; 
                _isLoading = false; 
            });
        } catch (e) {
            setState(() { 
                _errorMessage = e.toString().replaceAll('Exception: ', ''); 
                _isLoading = false; 
            });
            
            if (_errorMessage?.contains('Сессия истекла') ?? false) { 
                _navigateToLogin(); 
            }
        }
    }

    Future<void> _saveProfile() async {
        if (_nameController.text.isEmpty) { 
            _showError('Введите имя'); 
            return; 
        }
        if (_emailController.text.isEmpty) { 
            _showError('Введите email'); 
            return; 
        }
        if (!_emailController.text.contains('@')) { 
            _showError('Введите корректный email'); 
            return; 
        }

        setState(() => _isSaving = true);
        
        try {
            await AuthTokenService.updateUserProfile(
                name: _nameController.text, 
                email: _emailController.text, 
                surname: _surnameController.text.isNotEmpty ? _surnameController.text : null, 
            );
            
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar( 
                    SnackBar( 
                        content: const Text('Профиль успешно обновлен'), 
                        backgroundColor: Colors.green, 
                        behavior: SnackBarBehavior.floating, 
                    ), 
                );
            }
        } catch (e) {
            String errorMessage = e.toString().replaceAll('Exception: ', '');
            _showError(errorMessage);
        } finally {
            if (mounted) { 
                setState(() => _isSaving = false); 
            }
        }
    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: AppStyles.primary,
        title: const Text("Профиль"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Имя",
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Сохранить"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
