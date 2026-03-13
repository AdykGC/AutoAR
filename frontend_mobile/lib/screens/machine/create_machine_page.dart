/* [ Flutter ] */
import 'package:flutter/material.dart';
/* [ Models ] */
import 'package:frontend_mobile/models/machine.dart';
/* [ Widgets ] */
/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';
/* [ Services ] */
import 'package:frontend_mobile/services/machine_create_service.dart';

class CreateMachinePage extends StatefulWidget {
  const CreateMachinePage({super.key});

  @override
  State<CreateMachinePage> createState() => _CreateMachinePageState();
}

class _CreateMachinePageState extends State<CreateMachinePage> {
  late final TextEditingController nameController;
  late final TextEditingController typeController;
  late final TextEditingController locationController;
  late final TextEditingController serialController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    typeController = TextEditingController();
    locationController = TextEditingController();
    serialController = TextEditingController();
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
      final response = await MachineCreateService.create(
        name: nameController.text,
        type: typeController.text,
        location: locationController.text,
        serialNumber: serialController.text,
      );

      final machine = Machine.fromJson(response['data']['machine']);

      if (mounted) {
        Navigator.pop(context, machine);
      }
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
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        title: const Text("Добавить аппарат"),
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