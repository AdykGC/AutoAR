import 'package:flutter/material.dart';
import 'package:frontend_mobile/styles/app_styles.dart';
import 'package:frontend_mobile/services/auth_logout_service.dart';
import 'package:frontend_mobile/services/notification_service.dart';
import 'package:frontend_mobile/screens/auth/login_screen.dart';
import 'package:frontend_mobile/screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

/// =======================================================
/// SETTINGS PAGE
/// Экран настроек пользователя с рабочими переключателями
/// =======================================================
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// ===== STATE =====
  bool darkMode = false;
  bool pushNotifications = true;
  bool autoSync = true;
  bool biometricLogin = false;

  final LocalAuthentication _auth = LocalAuthentication();

  /// ===== INIT =====
  /// Загружаем сохраненные настройки при старте экрана
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Загружаем сохраненные настройки из SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
      pushNotifications = prefs.getBool('pushNotifications') ?? true;
      autoSync = prefs.getBool('autoSync') ?? true;
      biometricLogin = prefs.getBool('biometricLogin') ?? false;
    });
  }

  /// ===== NAVIGATION =====
  void _goToProfile() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));

  /// ===== LOGOUT =====
  Future<void> _logout() async {
    try {
      await AuthLogoutService.logout();
      if (!mounted) return;
      _navigateToLogin();
      _snack('Выход выполнен успешно', Colors.green);
    } catch (_) {
      await AuthLogoutService.forceLogout();
      _navigateToLogin();
      _snack('Выполнен принудительный выход', Colors.redAccent);
    }
  }

  void _navigateToLogin() => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );

  /// ===== SNACKBAR =====
  void _snack(String text, Color color) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );

  /// ===== SAVE PREFERENCES =====
  /// Сохраняем состояния всех переключателей в SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', darkMode);
    await prefs.setBool('pushNotifications', pushNotifications);
    await prefs.setBool('autoSync', autoSync);
    await prefs.setBool('biometricLogin', biometricLogin);
    _snack('Настройки сохранены', Colors.green);
  }

  /// =======================================================
  /// BUILD
  /// =======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      
      /// ===== BODY =====
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _profileCard(),
              const SizedBox(height: 24),

              // /// SYSTEM PREFERENCES
              // _section('SYSTEM PREFERENCES'),
              // _switch(Icons.dark_mode, 'Dark Mode', darkMode, (v) {
              //   setState(() => darkMode = v);
              //   _snack(v ? 'Темная тема включена' : 'Темная тема выключена', Colors.blue);
              // }),
              // _switch(Icons.notifications, 'Push Notifications', pushNotifications, (v) async {
              //   setState(() => pushNotifications = v);

              //   final prefs = await SharedPreferences.getInstance();
              //   await prefs.setBool('pushNotifications', v);

              //   await _notificationService.subscribeToNotifications(v);

              //   _snack(
              //     v ? 'Push уведомления включены' : 'Push уведомления отключены',
              //     Colors.blue,
              //   );
              // }),
              // _switch(Icons.auto_graph, 'Auto-Sync Analytics', autoSync, (v) {
              //   setState(() => autoSync = v);
              //   _snack(v ? 'Авто-синхронизация включена' : 'Авто-синхронизация отключена', Colors.blue);
              // }),

              // const SizedBox(height: 24),

              // /// SECURITY & PRIVACY
              // _section('SECURITY & PRIVACY'),
              // _switch(Icons.fingerprint, 'Biometric Login', biometricLogin, (v) async {
              //   // Проверяем поддержку биометрии
              //   bool canCheck = await _auth.canCheckBiometrics;
              //   if (canCheck) {
              //     bool authenticated = await _auth.authenticate(
              //       localizedReason: 'Авторизуйтесь для включения биометрии',
              //     );
              //     if (authenticated) {
              //       setState(() => biometricLogin = v);
              //       _snack(v ? 'Вход по отпечатку включен' : 'Вход по отпечатку отключен', Colors.blue);
              //     }
              //   } else {
              //     _snack('Биометрия не поддерживается на этом устройстве', Colors.redAccent);
              //   }
              // }),
              // _tile(Icons.lock, 'Two-Factor Authentication', 'Secure your account access',
              //     onTap: () => _snack('Откроется экран 2FA', Colors.blue)),

              // const SizedBox(height: 24),

              // /// APPLICATION
              // _section('APPLICATION'),
              // _tile(Icons.info, 'About Rubicon', 'Version 2.4.1-build.92',
              //     onTap: () => _snack('Rubicon v2.4.1', Colors.blue)),
              // _tile(Icons.warning, 'Legal & Privacy', 'Terms of service and data policy',
              //     onTap: () => _snack('Откроется политика конфиденциальности', Colors.blue)),
              _tile(Icons.logout, 'Log Out', 'Safely exit your current session',
                  iconColor: Colors.redAccent, onTap: _logout),

              const SizedBox(height: 24),

              // /// SAVE BUTTON
              // _saveButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// =======================================================
  /// UI HELPERS
  /// =======================================================

  /// PROFILE CARD
  Widget _profileCard() => GestureDetector(
        onTap: _goToProfile,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppStyles.fab,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28, color: Colors.white)),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Settings',
                        style: TextStyle(color: Colors.white)),
                    
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
            ],
          ),
        ),
      );

  /// SECTION TITLE
  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      );

  /// LIST TILE
  Widget _tile(
    IconData icon,
    String title,
    String? subtitle, {
    Widget? trailing,
    Color iconColor = Colors.white,
    VoidCallback? onTap,
  }) =>
      ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(color: Colors.white70))
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
        tileColor: AppStyles.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      );

  /// SWITCH TILE
  Widget _switch(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) =>
      ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing:
            Switch(value: value, onChanged: onChanged, activeColor: AppStyles.primary),
        tileColor: AppStyles.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  /// SAVE BUTTON
  Widget _saveButtons() => Column(
        children: [
          ElevatedButton.icon(
            onPressed: _savePreferences,
            icon: const Icon(Icons.save),
            label: const Text('Save Preferences'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      );
}
