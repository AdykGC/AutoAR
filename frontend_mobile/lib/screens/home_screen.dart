import 'package:flutter/material.dart';
import 'package:frontend_mobile/widgets/willpopscope_widgets.dart';   // [ Widgets ]
import 'package:frontend_mobile/styles/app_styles.dart';              // [ Styles ]
import 'package:frontend_mobile/services/auth_service.dart';          // [ Services ]
import 'package:frontend_mobile/screens/auth/login_screen.dart';      // [ Screens ]
import 'package:frontend_mobile/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [ HomePage(), AnalysesPage(), MachineListPage(), SettingsPage(), ];

  void _onItemTapped(int index) { setState(() { _selectedIndex = index; }); }

  void _logout() async {
    try {
      await AuthService.logout();
      Navigator.pushAndRemoveUntil( context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false, );
    } catch (e){
      debugPrint('Ошибка при выходе: $e');
      ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('Ошибка при выходе: ${e.toString()}'), backgroundColor: Colors.redAccent, ), );
    }
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
            const SizedBox(width: 10), Text( "Rubicon", style: TextStyle( color: AppStyles.textPrimary, fontWeight: FontWeight.bold, fontSize: 18, ), ),
          ],
        ),
        actions: [

          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            color: AppStyles.primary,

            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'profile') {
                Navigator.push( context, MaterialPageRoute(builder: (_) => const ProfileScreen()), );
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row( children: [ Icon(Icons.person), SizedBox(width: 8), Text('Профиль'), ], ),
              ),
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

class MachineListPage extends StatefulWidget {
  const MachineListPage({super.key});
  @override
  State<MachineListPage> createState() => _MachineListPageState();
}

class _MachineListPageState extends State<MachineListPage> {
  final List<String> _machines = [];

  void _showDialog({int? index}) {
    final controller = TextEditingController(
      text: index != null ? _machines[index] : "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(index == null ? "Добавить" : "Редактировать"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Название аппарата"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isEmpty) return;

              setState(() {
                if (index == null) {
                  _machines.add(controller.text); // CREATE
                } else {
                  _machines[index] = controller.text; // UPDATE
                }
              });

              Navigator.pop(context);
            },
            child: const Text("Сохранить"),
          )
        ],
      ),
    );
  }

  void _delete(int index) {
    setState(() {
      _machines.removeAt(index); // DELETE
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      ),
      body: _machines.isEmpty
          ? const Center(child: Text("Список пуст"))
          : ListView.builder(
              itemCount: _machines.length,
              itemBuilder: (_, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(_machines[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showDialog(index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _delete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) { return const Center(child: Text('Settings Page')); }
}
