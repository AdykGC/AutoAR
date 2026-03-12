import 'package:flutter/material.dart';
import 'package:frontend_mobile/models/machine.dart';
import 'package:frontend_mobile/services/machine_create_service.dart';
import 'package:frontend_mobile/services/machine_update_service.dart';
import 'package:frontend_mobile/styles/app_styles.dart';

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

      final machine = Machine.fromJson(response['data']['machine']);
      if (mounted) Navigator.pop(context, machine);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Widget _buildField(String label, TextEditingController controller) {
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
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppStyles.accent, width: 2),
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
        title: Text(isEditing ? "Редактировать аппарат" : "Добавить аппарат"),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Сохранить", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}