// ================= IMPORTS =================
/* [ Dart ] */

/* [ Flutter ] */
import 'package:flutter/material.dart';

/* [ Widgets ] */

/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';

/* [ Services ] */

/* [ Screens ] */
import 'package:frontend_mobile/screens/main/home_page.dart';
import 'package:frontend_mobile/screens/main/analyses_page.dart';
import 'package:frontend_mobile/screens/main/machine_list_page.dart';
import 'package:frontend_mobile/screens/main/settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      HomePage(),
      AnalysesPage(),
      MachineListPage(),
      SettingsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 40, 37, 63),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.precision_manufacturing, size: 28),
            SizedBox(width: 10),
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
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 40, 37, 63),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 117, 0, 185),
        unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
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
