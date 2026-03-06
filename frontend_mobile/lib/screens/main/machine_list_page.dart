// =======================================================
// IMPORTS
// =======================================================

import 'package:flutter/material.dart';
import 'package:frontend_mobile/styles/app_styles.dart';
import 'package:frontend_mobile/models/machine.dart';
import 'package:frontend_mobile/services/machine_create_service.dart';
import 'package:frontend_mobile/services/machine_list_service.dart';
import 'package:frontend_mobile/services/machine_delete_service.dart';
import 'package:frontend_mobile/services/machine_update_service.dart';
import 'package:frontend_mobile/screens/main/machine_details_page.dart';


// =======================================================
// ENUM ДЛЯ ФИЛЬТРА
// =======================================================

enum MachineFilter { all, active, inactive }


// =======================================================
// MACHINE LIST PAGE
// =======================================================

class MachineListPage extends StatefulWidget {
  const MachineListPage({super.key});

  @override
  State<MachineListPage> createState() => _MachineListPageState();
}

class _MachineListPageState extends State<MachineListPage> {

  // ------------------ STATE ------------------

  final List<Machine> _machines = [];           // Все аппараты с сервера
  final List<Machine> _filteredMachines = [];   // Отфильтрованные аппараты

  bool _isLoading = true;                       // Индикатор загрузки
  String? _error;                               // Текст ошибки

  String _searchQuery = "";                     // Поисковый запрос
  MachineFilter _currentFilter = MachineFilter.all; // Текущий фильтр


  // =======================================================
  // INIT
  // =======================================================

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }


  // =======================================================
  // ЗАГРУЗКА АППАРАТОВ С БЭКЕНДА
  // =======================================================

  Future<void> _loadMachines() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await MachineListService.fetchMachines();

      _machines
        ..clear()
        ..addAll(data.map((item) => Machine.fromJson(item)));

      _applySearchAndFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // =======================================================
  // ПОИСК + ФИЛЬТР
  // =======================================================

  void _applySearchAndFilter() {
    List<Machine> result = List.from(_machines);

    // ----- Фильтр по активности -----
    switch (_currentFilter) {
      case MachineFilter.active:
        result = result.where((m) => m.isActive == true).toList();
        break;

      case MachineFilter.inactive:
        result = result.where((m) => m.isActive == false).toList();
        break;

      case MachineFilter.all:
        break;
    }

    // ----- Поиск по названию -----
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((m) =>
              m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredMachines
        ..clear()
        ..addAll(result);
    });
  }


  // =======================================================
  // УДАЛЕНИЕ АППАРАТА
  // =======================================================

  void _deleteMachine(int index) {
    final machine = _filteredMachines[index];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Удалить аппарат?"),
        content: Text("Вы уверены, что хотите удалить ${machine.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена",
            style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await MachineDeleteService.delete(machine.id);
                await _loadMachines();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text(
              "Удалить",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }


  // =======================================================
  // ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ
  // =======================================================

  /// Формирование строки описания аппарата
  String _buildSubtitle(Machine machine) {
    final parts = [
      "Тип: ${machine.type}",
      if (machine.location?.isNotEmpty ?? false)
        "Локация: ${machine.location}",
      if (machine.serialNumber?.isNotEmpty ?? false)
        "С/Н: ${machine.serialNumber}",
    ];

    return parts.join(" • ");
  }

  /// Панель фильтров
  Widget _buildFilterBar() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildFilterButton(
        icon: Icons.list,
        filter: MachineFilter.all,
        label: "All",
      ),
      _buildFilterButton(
        icon: Icons.check_circle,
        filter: MachineFilter.active,
        label: "Active",
      ),
      _buildFilterButton(
        icon: Icons.cancel,
        filter: MachineFilter.inactive,
        label: "Inactive",
      ),
    ],
  );
}

/// Универсальная кнопка фильтра (иконка + текст)
Widget _buildFilterButton({
  required IconData icon,
  required MachineFilter filter,
  required String label,
}) {
  final isSelected = _currentFilter == filter;

  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      setState(() => _currentFilter = filter);
      _applySearchAndFilter();
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppStyles.selected : AppStyles.unselected,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppStyles.selected : AppStyles.unselected,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}



  // =======================================================
  // UI
  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFab(),
      body: _buildBody(),
    );
  }


  // ------------------ APP BAR ------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppStyles.background,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          children: [
            _buildSearchField(),
            _buildFilterBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          _searchQuery = value;
          _applySearchAndFilter();
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Поиск по названию",
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon:
              const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: AppStyles.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }


  // ------------------ BODY ------------------

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (_filteredMachines.isEmpty) {
      return Center(
        child: Text(
          "Список пуст",
          style: TextStyle(color: AppStyles.textPrimary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMachines,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredMachines.length,
        itemBuilder: (_, index) =>
            _buildMachineCard(_filteredMachines[index], index),
      ),
    );
  }


  // ------------------ CARD ------------------

  Widget _buildMachineCard(Machine machine, int index) {
  return Card(
    key: ValueKey(machine.id),
    color: AppStyles.dashboardCard,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MachineDetailsPage(machine: machine),
          ),
        );
      },
      title: Text(
        machine.name,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        _buildSubtitle(machine),
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteMachine(index),
          ),
        ],
      ),
    ),
  );
}



  // ------------------ FAB ------------------

  Widget _buildFab() {
    return FloatingActionButton(
      backgroundColor: AppStyles.fab,
      child: const Icon(Icons.add),
      onPressed: () async {
        final newMachine = await Navigator.push<Machine>(
          context,
          MaterialPageRoute(
            builder: (_) => const EditMachinePage(),
          ),
        );

        if (newMachine != null) {
          await _loadMachines();
        }
      },
    );
  }
}


// =======================================================
// EDIT / ADD PAGE
// =======================================================

class EditMachinePage extends StatefulWidget {
  final Machine? machine;

  const EditMachinePage({super.key, this.machine});

  @override
  State<EditMachinePage> createState() => _EditMachinePageState();
}

class _EditMachinePageState extends State<EditMachinePage> {

  late final TextEditingController nameController;
  late final TextEditingController typeController;
  late final TextEditingController locationController;
  late final TextEditingController serialController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.machine?.name ?? "");
    typeController =
        TextEditingController(text: widget.machine?.type ?? "");
    locationController =
        TextEditingController(text: widget.machine?.location ?? "");
    serialController =
        TextEditingController(text: widget.machine?.serialNumber ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    locationController.dispose();
    serialController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameController.text.isEmpty ||
        typeController.text.isEmpty) return;

    try {
      final isEditing = widget.machine != null;

      final response = isEditing
          ? await MachineUpdateService.update(
              id: widget.machine!.id,
              name: nameController.text,
              type: typeController.text,
              location: locationController.text,
              serialNumber: serialController.text,
            )
          : await MachineCreateService.create(
              name: nameController.text,
              type: typeController.text,
              location: locationController.text,
              serialNumber: serialController.text,
            );

      final machine =
          Machine.fromJson(response['data']['machine']);

      if (mounted) Navigator.pop(context, machine);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Widget _buildField(
      String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: AppStyles.secondary,
        enabledBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppStyles.accent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.machine != null;

    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        title: Text(
            isEditing ? "Редактировать аппарат" : "Добавить аппарат"),
        backgroundColor: AppStyles.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildField("Название", nameController),
            const SizedBox(height: 10),
            _buildField("Тип аппарата", typeController),
            const SizedBox(height: 10),
            _buildField("Локация (опционально)", locationController),
            const SizedBox(height: 10),
            _buildField("Серийный номер (опционально)", serialController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.accent,
              ),
              child: const Text("Сохранить"),
            ),
          ],
        ),
      ),
    );
  }
}