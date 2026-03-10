// =======================================================
// MACHINE LIST PAGE
// =======================================================

import 'package:flutter/material.dart';
import 'package:frontend_mobile/styles/app_styles.dart';

import 'package:frontend_mobile/models/machine.dart';

import 'package:frontend_mobile/services/machine_create_service.dart';
import 'package:frontend_mobile/services/machine_list_service.dart';
import 'package:frontend_mobile/services/machine_update_service.dart';

import 'package:frontend_mobile/screens/main/machine_details_page.dart';


// =======================================================
// FILTER ENUM
// =======================================================

enum MachineFilter {
  all,
  active,
  inactive,
}


// =======================================================
// MACHINE LIST PAGE
// =======================================================

class MachineListPage extends StatefulWidget {
  const MachineListPage({super.key});

  @override
  State<MachineListPage> createState() => _MachineListPageState();
}

class _MachineListPageState extends State<MachineListPage> {

  // =======================================================
  // STATE
  // =======================================================

  /// Все аппараты
  final List<Machine> _machines = [];

  /// Отфильтрованный список
  final List<Machine> _filteredMachines = [];

  bool _isLoading = true;
  String? _error;

  /// Поиск
  String _searchQuery = "";

  /// Фильтр
  MachineFilter _currentFilter = MachineFilter.all;


  // =======================================================
  // INIT
  // =======================================================

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }


  // =======================================================
  // LOAD MACHINES
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
        ..addAll(data.map((e) => Machine.fromJson(e)));

      _applySearchAndFilter();

    } catch (e) {

      _error = e.toString();

    } finally {

      setState(() => _isLoading = false);

    }
  }


  // =======================================================
  // SEARCH + FILTER
  // =======================================================

  void _applySearchAndFilter() {

    List<Machine> result = List.from(_machines);

    /// Фильтр по активности
    switch (_currentFilter) {

      case MachineFilter.active:
        result = result.where((m) => m.isActive).toList();
        break;

      case MachineFilter.inactive:
        result = result.where((m) => !m.isActive).toList();
        break;

      case MachineFilter.all:
        break;
    }

    /// Поиск по имени
    if (_searchQuery.isNotEmpty) {

      result = result.where((m) {
        return m.name
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();

    }

    setState(() {
      _filteredMachines
        ..clear()
        ..addAll(result);
    });
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


  // =======================================================
  // APP BAR
  // =======================================================

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


  // =======================================================
  // SEARCH FIELD
  // =======================================================

  Widget _buildSearchField() {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      child: TextField(

        style: const TextStyle(color: Colors.white),

        onChanged: (value) {
          _searchQuery = value;
          _applySearchAndFilter();
        },

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


  // =======================================================
  // FILTER BAR
  // =======================================================

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


  Widget _buildFilterButton({
    required IconData icon,
    required MachineFilter filter,
    required String label,
  }) {

    final isSelected = _currentFilter == filter;

    return InkWell(

      borderRadius: BorderRadius.circular(12),

      onTap: () {

        setState(() {
          _currentFilter = filter;
        });

        _applySearchAndFilter();
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(
              icon,
              color: isSelected
                  ? AppStyles.selected
                  : AppStyles.unselected,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppStyles.selected
                    : AppStyles.unselected,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // =======================================================
  // BODY
  // =======================================================

  Widget _buildBody() {

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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

        itemBuilder: (_, index) {
          return _buildMachineCard(
            _filteredMachines[index],
          );
        },
      ),
    );
  }


  // =======================================================
  // MACHINE CARD
  // =======================================================

  Widget _buildMachineCard(Machine machine) {

    return Card(

      key: ValueKey(machine.id),

      color: AppStyles.dashboardCard,

      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(

        onTap: () async {

          final updatedMachine =
              await Navigator.push<Machine>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MachineDetailsPage(machine: machine),
            ),
          );

          if (updatedMachine != null) {

            final index = _machines.indexWhere(
              (m) => m.id == updatedMachine.id,
            );

            if (index != -1) {

              _machines[index] = updatedMachine;

              _applySearchAndFilter();
            }
          }
        },

        title: Text(
          machine.name,
          style: const TextStyle(color: Colors.white),
        ),

        subtitle: Text(
          _buildSubtitle(machine),
          style: const TextStyle(color: Colors.white70),
        ),

        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
      ),
    );
  }


  // =======================================================
  // MACHINE DESCRIPTION
  // =======================================================

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


  // =======================================================
  // FLOATING BUTTON
  // =======================================================

  Widget _buildFab() {

    return FloatingActionButton(

      backgroundColor: AppStyles.fab,

      child: const Icon(Icons.add),

      onPressed: () async {

        final newMachine =
            await Navigator.push<Machine>(
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
// EDIT / ADD MACHINE PAGE
// =======================================================

class EditMachinePage extends StatefulWidget {

  /// Если machine != null → редактирование
  /// Если null → создание
  final Machine? machine;

  const EditMachinePage({
    super.key,
    this.machine,
  });

  @override
  State<EditMachinePage> createState() => _EditMachinePageState();
}


class _EditMachinePageState extends State<EditMachinePage> {

  // =======================================================
  // CONTROLLERS
  // =======================================================

  late final TextEditingController nameController;
  late final TextEditingController typeController;
  late final TextEditingController locationController;
  late final TextEditingController serialController;


  // =======================================================
  // INIT
  // =======================================================

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


  // =======================================================
  // DISPOSE
  // =======================================================

  @override
  void dispose() {

    nameController.dispose();
    typeController.dispose();
    locationController.dispose();
    serialController.dispose();

    super.dispose();
  }


  // =======================================================
  // SAVE MACHINE
  // =======================================================

  Future<void> _save() async {

    if (nameController.text.isEmpty ||
        typeController.text.isEmpty) {
      return;
    }

    try {

      final isEditing = widget.machine != null;

      final response = isEditing

          // ---------- UPDATE ----------
          ? await MachineUpdateService.update(
              id: widget.machine!.id,
              name: nameController.text,
              type: typeController.text,
              location: locationController.text,
              serialNumber: serialController.text,
            )

          // ---------- CREATE ----------
          : await MachineCreateService.create(
              name: nameController.text,
              type: typeController.text,
              location: locationController.text,
              serialNumber: serialController.text,
            );


      final machine =
          Machine.fromJson(response['data']['machine']);

      if (mounted) {
        Navigator.pop(context, machine);
      }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );

      }
    }
  }


  // =======================================================
  // TEXT FIELD WIDGET
  // =======================================================

  Widget _buildField(
    String label,
    TextEditingController controller,
  ) {

    return TextField(

      controller: controller,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(

        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),

        filled: true,
        fillColor: AppStyles.secondary,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.white24,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppStyles.accent,
            width: 2,
          ),
        ),
      ),
    );
  }


  // =======================================================
  // UI
  // =======================================================

  @override
  Widget build(BuildContext context) {

    final isEditing = widget.machine != null;

    return Scaffold(

      backgroundColor: AppStyles.background,

      appBar: AppBar(
        title: Text(
          isEditing
              ? "Редактировать аппарат"
              : "Добавить аппарат",
        ),
        backgroundColor: AppStyles.primary,
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [

            // ---------- NAME ----------
            _buildField(
              "Название",
              nameController,
            ),

            const SizedBox(height: 10),

            // ---------- TYPE ----------
            _buildField(
              "Тип аппарата",
              typeController,
            ),

            const SizedBox(height: 10),

            // ---------- LOCATION ----------
            _buildField(
              "Локация (опционально)",
              locationController,
            ),

            const SizedBox(height: 10),

            // ---------- SERIAL ----------
            _buildField(
              "Серийный номер (опционально)",
              serialController,
            ),

            const SizedBox(height: 20),

            // ---------- SAVE BUTTON ----------
            ElevatedButton(

              onPressed: _save,

              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.accent,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),

              child: const Text(
                "Сохранить",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
