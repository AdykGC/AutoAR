import 'package:flutter/material.dart';
import 'package:frontend_mobile/styles/app_styles.dart';
import 'package:frontend_mobile/services/auth_logout_service.dart';
import 'package:frontend_mobile/screens/auth/login_screen.dart';
import 'package:frontend_mobile/screens/profile/profile_screen.dart';

/// =======================================================
/// SETTINGS PAGE
/// Экран настроек пользователя
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

  /// =======================================================
  /// BUILD
  /// =======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,

      /// ===== APPBAR =====
      appBar: AppBar(
        backgroundColor: AppStyles.dashboardCard,
        title: const Text('Settings'),
      ),

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

              

              const SizedBox(height: 24),

              /// SYSTEM
              _section('SYSTEM PREFERENCES'),
              _switch(Icons.dark_mode, 'Dark Mode', darkMode,
                  (v) => setState(() => darkMode = v)),
              _switch(Icons.notifications, 'Push Notifications', pushNotifications,
                  (v) => setState(() => pushNotifications = v)),
              _switch(Icons.auto_graph, 'Auto-Sync Analytics', autoSync,
                  (v) => setState(() => autoSync = v)),

              const SizedBox(height: 24),

              /// SECURITY
              _section('SECURITY & PRIVACY'),
              _switch(Icons.fingerprint, 'Biometric Login', biometricLogin,
                  (v) => setState(() => biometricLogin = v)),
              _tile(Icons.lock, 'Two-Factor Authentication',
                  'Secure your account access'),

              const SizedBox(height: 24),

              /// APP
              _section('APPLICATION'),
              _tile(Icons.info, 'About Rubicon', 'Version 2.4.1-build.92'),
              _tile(Icons.warning, 'Legal & Privacy',
                  'Terms of service and data policy'),
              _tile(Icons.logout, 'Log Out', 'Safely exit your current session',
                  iconColor: Colors.redAccent, onTap: _logout),

              const SizedBox(height: 24),

              _saveButtons(),
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
              CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28)),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name Surname',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Administrator',
                        style: TextStyle(color: Colors.white)),
                    Text('Enterprise Plan',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
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

  /// BADGE
  Widget _badge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.white70),
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

  /// SAVE BUTTONS
  Widget _saveButtons() => Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save),
            label: const Text('Save Preferences'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Restore System Defaults'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      );
}
