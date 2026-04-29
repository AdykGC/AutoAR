/* ================= IMPORTS ================= */

/* [ Flutter ] */
import 'package:flutter/material.dart';

/* [ Models ] */
import 'package:frontend_mobile/models/machine.dart';
import 'package:frontend_mobile/models/machine_filter.dart';

/* [ Widgets ] */
import 'package:frontend_mobile/widgets/widget_for_machines/filter_bar.dart';
import 'package:frontend_mobile/widgets/widget_for_machines/machine_card.dart';
import 'package:frontend_mobile/widgets/widget_for_machines/search_field.dart';

/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';

/* [ Services ] */
import 'package:frontend_mobile/services/machine/machine_list_service.dart';

/* [ Screens ] */
import 'package:frontend_mobile/screens/machine/create_machine_page.dart';


/* ================= PAGE ================= */

class MachineListPage extends StatefulWidget {
  const MachineListPage({super.key});

  @override
  State<MachineListPage> createState() => _MachineListPageState();
}


/* ================= STATE ================= */

class _MachineListPageState extends State<MachineListPage> {

  // ---------- Основной список ----------
  final List<Machine> _machines = [];

  // ---------- Отфильтрованный список ----------
  final List<Machine> _filteredMachines = [];

  // ---------- Состояния ----------
  bool _isLoading = true;
  String? _error;

  // ---------- Поиск и фильтр ----------
  String _searchQuery = "";
  MachineFilter _currentFilter = MachineFilter.all;


  /* ================= LIFECYCLE ================= */

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }


  /* ================= DATA ================= */

  /// Загрузка списка аппаратов с сервера
  Future<void> _loadMachines() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await MachineListService.fetchMachines();

      // Очистка и заполнение списка
      _machines
        ..clear()
        ..addAll(data.map((e) => Machine.fromJson(e)));

      _applySearchAndFilter();

    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }


  /* ================= FILTER & SEARCH ================= */

  /// Применение фильтра и поиска
  void _applySearchAndFilter() {
    List<Machine> result = List.from(_machines);

    // ---------- Фильтр ----------
    result = _applyFilter(result);

    // ---------- Поиск ----------
    result = _applySearch(result);

    // ---------- Обновление UI ----------
    setState(() {
      _filteredMachines
        ..clear()
        ..addAll(result);
    });
  }

  /// Фильтрация по статусу
  List<Machine> _applyFilter(List<Machine> machines) {
    switch (_currentFilter) {
      case MachineFilter.active:
        return machines.where((m) => m.isActive).toList();

      case MachineFilter.inactive:
        return machines.where((m) => !m.isActive).toList();

      case MachineFilter.all:
        return machines;
    }
  }

  /// Поиск по названию
  List<Machine> _applySearch(List<Machine> machines) {
    if (_searchQuery.isEmpty) return machines;

    return machines.where((m) {
      return m.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }


  /* ================= UPDATE ================= */

  /// Обновление одного аппарата в списке
  void _updateMachineInList(Machine updated) {
    final index = _machines.indexWhere((m) => m.id == updated.id);

    if (index != -1) {
      _machines[index] = updated;
      _applySearchAndFilter();
    }
  }


  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,

      appBar: AppBar(
        backgroundColor: AppStyles.background,
        bottom: _buildAppBarContent(),
      ),

      floatingActionButton: _buildFAB(),

      body: _buildBody(),
    );
  }


  /* ================= UI COMPONENTS ================= */

  /// Верхняя панель (поиск + фильтр)
  PreferredSize _buildAppBarContent() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),

      child: Column(
        children: [

          // ---------- Поиск ----------
          SearchField(
            onChanged: (value) {
              _searchQuery = value;
              _applySearchAndFilter();
            },
          ),

          // ---------- Фильтр ----------
          FilterBar(
            currentFilter: _currentFilter,
            onFilterChanged: (filter) {
              setState(() => _currentFilter = filter);
              _applySearchAndFilter();
            },
          ),
        ],
      ),
    );
  }


  /// Floating Action Button (добавление аппарата)
  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: AppStyles.fab,
      child: const Icon(Icons.add),

      onPressed: () async {
        final newMachine = await Navigator.push<Machine>(
          context,
          MaterialPageRoute(
            builder: (_) => CreateMachinePage(machines: _machines),
          ),
        );

        // Если вернулся новый аппарат — обновляем список
        if (newMachine != null) {
          await _loadMachines();
        }
      },
    );
  }


  /// Основное тело страницы
  Widget _buildBody() {

    // ---------- Загрузка ----------
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ---------- Ошибка ----------
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    // ---------- Пустой список ----------
    if (_filteredMachines.isEmpty) {
      return Center(
        child: Text(
          "Список пуст",
          style: TextStyle(color: AppStyles.textPrimary),
        ),
      );
    }

    // ---------- Список ----------
    return RefreshIndicator(
      onRefresh: _loadMachines,

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredMachines.length,

        itemBuilder: (_, index) {
          return MachineCard(
            machine: _filteredMachines[index],
            onUpdate: _updateMachineInList,
          );
        },
      ),
    );
  }
}
