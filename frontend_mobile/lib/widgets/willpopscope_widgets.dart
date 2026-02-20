import 'package:flutter/material.dart';
import 'package:frontend_mobile/styles/app_styles.dart';              // [ Styles ]
import 'package:frontend_mobile/screens/home_screen.dart';
import 'package:frontend_mobile/screens/profile/profile_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AnalysesPage(),
    MachineListPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Перехватываем попытки возврата
  Future<bool> _onWillPop() async {
    return false; // Блокируем возврат на экран логина
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Перехватываем действия возврата
      child: Scaffold(
        backgroundColor: AppStyles.background,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppStyles.primary,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppStyles.accent,
          unselectedItemColor: AppStyles.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analyses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              activeIcon: Icon(Icons.list),
              label: 'Machines',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
