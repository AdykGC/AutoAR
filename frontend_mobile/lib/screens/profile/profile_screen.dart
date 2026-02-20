import 'dart:convert';
import 'package:flutter/material.dart';
/* [ Widgets ] */
import 'package:frontend_mobile/widgets/common_widgets.dart';
/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';
/* [ Service ] */
import 'package:frontend_mobile/services/auth_token_service.dart';
import 'package:frontend_mobile/services/auth_update_service.dart';
/* [ Screen ] */
import 'package:frontend_mobile/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
    const ProfileScreen({super.key});

    @override
    State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
    final _nameController = TextEditingController();
    final _surnameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _addressController = TextEditingController();

    bool _isLoading = true;
    bool _isSaving = false;
    String? _errorMessage;
    Map<String, dynamic>? _userData;

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
        _phoneController.dispose(); 
        _addressController.dispose(); 
        super.dispose(); 
    }

    void _navigateToLogin() { 
      Navigator.of(context).pushAndRemoveUntil( MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false, );
    }

    void _showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating, ), );
    }

    void _showSuccess(String message) {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, ), );
    }

    Future<void> _loadUserProfile() async {
        setState(() { _isLoading = true; _errorMessage = null; });
        try {
            final response = await AuthTokenService.getUserProfile();
            debugPrint('📦 Полный ответ: $response');

            // Определяем структуру данных
            Map<String, dynamic> userData;

            if (response.containsKey('user')) {
                // Структура: { "user": { "id": 10, "email": "...", ... } }
                userData = response['user'] as Map<String, dynamic>;
                debugPrint('📦 Данные внутри user: $userData');
            } else {
                // Структура: прямая (без обертки user)
                userData = response;
                debugPrint('📦 Прямые данные: $userData');
            }

            setState(() { 
                _userData = response;
                _nameController.text = userData['name'] ?? ''; 
                _surnameController.text = userData['surname'] ?? ''; 
                _emailController.text = userData['email'] ?? '';
                _phoneController.text = userData['phone'] ?? '';
                _addressController.text = userData['address'] ?? '';
                _isLoading = false; 
            });

            debugPrint('[+] Профиль загружен: ${userData['email']}');

        } catch (e) {
            setState(() { 
                _errorMessage = e.toString().replaceAll('Exception: ', ''); 
                _isLoading = false; 
            });
            debugPrint('[-] Ошибка загрузки профиля: $e');
            if (_errorMessage?.contains('Сессия истекла') ?? false) { 
                _navigateToLogin(); 
            }
        }
    }

    Future<void> _saveProfile() async {

        setState(() => _isSaving = true);

        try {
            await AuthUpdateService.updateUserProfile(
                name: _nameController.text.isNotEmpty ? _nameController.text : null,
                surname: _surnameController.text.isNotEmpty ? _surnameController.text : null, 
                phone: _phoneController.text.isNotEmpty ? _phoneController.text : null, 
                address: _addressController.text.isNotEmpty ? _addressController.text : null,
            );
            
            if (mounted) {
                _showSuccess('Профиль успешно обновлен');
                await _loadUserProfile();
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
                elevation: 0,
                title: const Text(
                    "Профиль",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _isLoading ? null : _loadUserProfile,
                        tooltip: 'Обновить',
                    ),
                ],
            ),
            body: SafeArea(
                child: Center(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : _errorMessage != null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                                            const SizedBox(height: 16),
                                            Text(
                                                _errorMessage!,
                                                style: const TextStyle(color: Colors.red),
                                                textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                                onPressed: _loadUserProfile,
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppStyles.accent,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                    ),
                                                ),
                                                child: const Text('Повторить'),
                                            ),
                                        ],
                                    )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            // Аватар с инициалами
                                            CircleAvatar(
                                                radius: 60,
                                                backgroundColor: AppStyles.accent,
                                                child: Text(
                                                    _getInitials(),
                                                    style: const TextStyle(
                                                        fontSize: 30,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                    ),
                                                ),
                                            ),
                                            const SizedBox(height: 20),
                                            
                                            Text(
                                                '${_nameController.text} ${_surnameController.text}'.trim(),
                                                style: TextStyle(
                                                    color: AppStyles.textPrimary,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                ),
                                            ),
                                            const SizedBox(height: 8),
                                            
                                            Text(
                                                _emailController.text,
                                                style: TextStyle(
                                                    color: AppStyles.textSecondary,
                                                    fontSize: 16,
                                                ),
                                            ),
                                            const SizedBox(height: 40),

                                            // Имя
                                            CustomTextField(
                                                label: 'Имя',
                                                controller: _nameController,
                                                prefixIcon: Icons.person_outline,
                                            ),
                                            const SizedBox(height: 20),

                                            // Фамилия
                                            CustomTextField(
                                                label: 'Фамилия',
                                                controller: _surnameController,
                                                prefixIcon: Icons.person_outline,
                                            ),
                                            const SizedBox(height: 20),

                                            // Email
                                            CustomTextField(
                                                label: 'Email',
                                                controller: _emailController,
                                                keyboardType: TextInputType.emailAddress,
                                                prefixIcon: Icons.email_outlined,
                                            ),
                                            const SizedBox(height: 20),

                                            // Телефон
                                            CustomTextField(
                                                label: 'Телефон',
                                                controller: _phoneController,
                                                keyboardType: TextInputType.phone,
                                                prefixIcon: Icons.phone_outlined,
                                            ),
                                            const SizedBox(height: 32),

                                            // Адрес 👇
                                            CustomTextField(
                                                label: 'Адрес',
                                                controller: _addressController,
                                                prefixIcon: Icons.location_on_outlined,
                                            ),
                                            const SizedBox(height: 32),  // 👈 Отступ перед кнопкой

                                            // Кнопка сохранения
                                            SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                    onPressed: _isSaving ? null : _saveProfile,
                                                    style: ElevatedButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                                        backgroundColor: AppStyles.accent,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                        ),
                                                    ),
                                                    child: _isSaving
                                                        ? const SizedBox(
                                                            height: 20,
                                                            width: 20,
                                                            child: CircularProgressIndicator(
                                                                color: Colors.white,
                                                                strokeWidth: 2,
                                                            ),
                                                        )
                                                        : const Text(
                                                            'Сохранить изменения',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                            ),
                                                        ),
                                                ),
                                            ),

                                            const SizedBox(height: 20),

                                            // Дополнительная информация
                                            if (_userData != null) ...[
                                                const Divider(),
                                                const SizedBox(height: 10),
                                                // Определяем откуда брать данные
                                                _buildInfoRow('ID', _userData!.containsKey('user') ? _userData!['user']['id']?.toString() ?? '—' : _userData!['id']?.toString() ?? '—'),
                                                _buildInfoRow('Email', _userData!.containsKey('user') ? _userData!['user']['email'] ?? '—' : _userData!['email'] ?? '—'),
                                                _buildInfoRow('Телефон', _userData!.containsKey('user') ? _userData!['user']['phone'] ?? '—' : _userData!['phone'] ?? '—'),
                                                _buildInfoRow('Дата регистрации', _formatDate(_userData!.containsKey('user')  ? _userData!['user']['created_at'] : _userData!['created_at'] )),
                                                _buildInfoRow('Последнее обновление', _formatDate( _userData!.containsKey('user') ? _userData!['user']['updated_at'] : _userData!['updated_at'] )),
                                            ],
                                          ],
                                    ),
                              
                        ),
                    ),
                ),
            ),
        );
    }

    // Вспомогательные методы
    Widget _buildInfoRow(String label, String value) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text(
                        label,
                        style: TextStyle(
                            color: AppStyles.textSecondary,
                            fontSize: 14,
                        ),
                    ),
                    Text(
                        value,
                        style: TextStyle(
                            color: AppStyles.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                        ),
                    ),
                ],
            ),
        );
    }

    String _getInitials() {
        String name = _nameController.text.trim();
        String surname = _surnameController.text.trim();
        
        if (name.isNotEmpty && surname.isNotEmpty) {
            return '${name[0]}${surname[0]}'.toUpperCase();
        } else if (name.isNotEmpty) {
            return name[0].toUpperCase();
        } else {
            return '?';
        }
    }

    String _formatDate(String? dateStr) {
        if (dateStr == null) return '—';
        try {
            final date = DateTime.parse(dateStr);
            return '${date.day}.${date.month}.${date.year}';
        } catch (e) {
            return dateStr;
        }
    }
}