import 'package:flutter/material.dart';
import 'package:frontend_mobile/styles/app_styles.dart';              // [ Styles ]
import 'package:frontend_mobile/screens/auth/login_screen.dart';      // [ Screens ]

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [ HomePage(), AnalysesPage(), MachineListPage(), SettingsPage(), ];

  void _onItemTapped(int index) { setState(() { _selectedIndex = index; }); }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,

      // ======= TOP APP BAR =======
      appBar: AppBar(
        backgroundColor: AppStyles.primary,
        elevation: 0,
        title: Row(
          children: [
            // 🔹 ЛОГО (пока иконка, можно заменить на Image.asset)
            const Icon(Icons.precision_manufacturing, size: 28),
            const SizedBox(width: 10),
            Text(
              "Rubicon",
              style: TextStyle(
                color: AppStyles.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            color: AppStyles.primary,
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row( children: [ Icon(Icons.logout), SizedBox(width: 8), Text('Выйти'), ], ),
              ),
            ],
          ),
        ],
      ),

      body: _pages[_selectedIndex],

      // ======= BOTTOM NAVIGATION =======
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppStyles.primary,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppStyles.accent,
        unselectedItemColor: AppStyles.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem( icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home', ),
          BottomNavigationBarItem( icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Analyses', ),
          BottomNavigationBarItem( icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list), label: 'Machines', ),
          BottomNavigationBarItem( icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings', ),
        ],
      ),
    );
  }
}

//
// =================== PAGES ===================
//

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) { return const Center(child: Text('Home Page')); }
}

class AnalysesPage extends StatelessWidget {
  const AnalysesPage({super.key});
  @override
  Widget build(BuildContext context) { return const Center(child: Text('Analyses Page')); }
}

class MachineListPage extends StatelessWidget {
  const MachineListPage({super.key});
  @override
  Widget build(BuildContext context) { return const Center(child: Text('Machine List Page')); }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) { return const Center(child: Text('Settings Page')); }
}
