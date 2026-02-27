// ================= IMPORTS =================
/* [ Dart ] */
import 'package:flutter/material.dart';

/* [ Flutter ] */
/* [ Widgets ] */
/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';

import 'package:frontend_mobile/models/machine.dart';

/* [ Service ] */
import 'package:frontend_mobile/services/machine_create_service.dart';
import 'package:frontend_mobile/services/machine_list_service.dart';
import 'package:frontend_mobile/services/machine_delete_service.dart';
import 'package:frontend_mobile/services/machine_update_service.dart';

// ================= MACHINE LIST PAGE =================
class MachineListPage extends StatefulWidget {
  const MachineListPage({super.key});

  @override
  State<MachineListPage> createState() => _MachineListPageState();
}

// ================= SHOW / LIST MACHINE PAGE =================
class _MachineListPageState extends State<MachineListPage> {
  final List<Machine> _machines = [];

  bool _isLoading = true;
  String? _error;

  Future<void> _loadMachines() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await MachineListService.fetchMachines();

      setState(() {
        _machines.clear();
        _machines.addAll( data.map((item) => Machine.fromJson(item)), );
      });
    } catch (e) { setState(() { _error = e.toString(); });
    } finally { setState(() { _isLoading = false; }); }
  }
  @override
  void initState() {
    super.initState();
    _loadMachines();
  }
  // ================= DELETE =================
void _delete(int index) {
  final machine = _machines[index];

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Удалить аппарат?"),
      content: Text("Вы уверены, что хотите удалить ${machine.name}?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Отмена"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);

            try {
              await MachineDeleteService.delete(machine.id);
              await _loadMachines();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
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

  // ================= SUBTITLE BUILDER =================
  String _buildSubtitle(Machine machine) {
    final parts = <String>[];
    parts.add("Тип: ${machine.type}");
    if (machine.location != null && machine.location!.isNotEmpty) {
      parts.add("Локация: ${machine.location}");
    }
    if (machine.serialNumber != null && machine.serialNumber!.isNotEmpty) {
      parts.add("С/Н: ${machine.serialNumber}");
    }
    return parts.join(" • ");
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        title: const Text("Список аппаратов"),
        backgroundColor: AppStyles.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Добавление нового аппарата
          final newMachine = await Navigator.push<Machine>(
            context,
            MaterialPageRoute(
              builder: (_) => const EditMachinePage(),
            ),
          );

          if (newMachine != null) { await _loadMachines(); }
        },
        backgroundColor: AppStyles.fab,
        child: const Icon(Icons.add),
      ),
body: _isLoading
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : _error != null
        ? Center(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          )
        : _machines.isEmpty
            ? const Center(
                child: Text(
                  "Список пуст",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadMachines,
                child: ListView.builder(
                  itemCount: _machines.length,
                  itemBuilder: (_, index) {
                    final machine = _machines[index];
                    return Card(
                      key: ValueKey(machine.id),
                      color: AppStyles.dashboardCard,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          machine.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _buildSubtitle(machine),
                          style:
                              const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.white70),
                              onPressed: () async {
                                final updatedMachine =
                                    await Navigator.push<Machine>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditMachinePage(
                                      machine: machine,
                                    ),
                                  ),
                                );

                                if (updatedMachine != null) {
                                  await _loadMachines();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => _delete(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}


// ================= EDIT / ADD MACHINE PAGE =================
class EditMachinePage extends StatefulWidget {
  final Machine? machine; // если null → добавление нового

  const EditMachinePage({super.key, this.machine});

  @override
  State<EditMachinePage> createState() => _EditMachinePageState();
}

class _EditMachinePageState extends State<EditMachinePage> {
  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController locationController;
  late TextEditingController serialController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.machine?.name ?? "");
    typeController = TextEditingController(text: widget.machine?.type ?? "");
    locationController = TextEditingController(text: widget.machine?.location ?? "");
    serialController = TextEditingController(text: widget.machine?.serialNumber ?? "");
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
  if (nameController.text.isEmpty || typeController.text.isEmpty) return;

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

    final machineData = response['data']['machine'];
    final machine = Machine.fromJson(machineData);

    if (mounted) {
      Navigator.pop(context, machine);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppStyles.accent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: AppStyles.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.machine != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Редактировать аппарат" : "Добавить аппарат"),
        backgroundColor: AppStyles.primary,
      ),
      backgroundColor: AppStyles.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildTextField("Название", nameController),
            const SizedBox(height: 10),
            _buildTextField("Тип аппарата", typeController),
            const SizedBox(height: 10),
            _buildTextField("Локация (опционально)", locationController),
            const SizedBox(height: 10),
            _buildTextField("Серийный номер (опционально)", serialController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppStyles.accent),
              child: const Text("Сохранить"),
            ),
          ],
        ),
      ),
    );
  }
}
