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
import 'package:frontend_mobile/services/machine_list_service.dart';

/* [ Screens ] */
import 'package:frontend_mobile/screens/machine/create_machine_page.dart';

class MachineListPage extends StatefulWidget {
  const MachineListPage({super.key});

  @override
  State<MachineListPage> createState() => _MachineListPageState();
}

class _MachineListPageState extends State<MachineListPage> {
  final List<Machine> _machines = [];
  final List<Machine> _filteredMachines = [];

  bool _isLoading = true;
  String? _error;

  String _searchQuery = "";
  MachineFilter _currentFilter = MachineFilter.all;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

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

  void _applySearchAndFilter() {
    List<Machine> result = List.from(_machines);

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

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredMachines
        ..clear()
        ..addAll(result);
    });
  }

  void _updateMachineInList(Machine updated) {
    final index = _machines.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _machines[index] = updated;
      _applySearchAndFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: AppStyles.background,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              SearchField(
                onChanged: (value) {
                  _searchQuery = value;
                  _applySearchAndFilter();
                },
              ),
              FilterBar(
                currentFilter: _currentFilter,
                onFilterChanged: (filter) {
                  setState(() => _currentFilter = filter);
                  _applySearchAndFilter();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyles.fab,
        child: const Icon(Icons.add),
        onPressed: () async {
          final newMachine = await Navigator.push<Machine>(
            context,
            MaterialPageRoute(builder: (_) => const CreateMachinePage()),
          );
          if (newMachine != null) await _loadMachines();
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
      );
    }
    if (_filteredMachines.isEmpty) {
      return Center(
        child: Text("Список пуст", style: TextStyle(color: AppStyles.textPrimary)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadMachines,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredMachines.length,
        itemBuilder: (_, index) => MachineCard(
          machine: _filteredMachines[index],
          onUpdate: _updateMachineInList,
        ),
      ),
    );
  }
}