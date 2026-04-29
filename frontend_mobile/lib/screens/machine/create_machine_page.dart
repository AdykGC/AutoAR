/* ================= IMPORTS ================= */

/* [ Flutter ] */
import 'package:flutter/material.dart';

/* [ Models ] */
import 'package:frontend_mobile/models/machine.dart';

/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';

/* [ Services ] */
import 'package:frontend_mobile/services/machine/machine_create_service.dart';
/* [ Widgets ] */
import 'package:frontend_mobile/widgets/common_widgets.dart';


/* ================= PAGE ================= */

class CreateMachinePage extends StatefulWidget {
  final List<Machine> machines;

  const CreateMachinePage({
    super.key,
    required this.machines,
  });

  @override
  State<CreateMachinePage> createState() => _CreateMachinePageState();
}


/* ================= STATE ================= */

class _CreateMachinePageState extends State<CreateMachinePage> {

  // ---------- Controllers для полей ----------
  late final TextEditingController nameController;
  late final TextEditingController locationController;
  late final TextEditingController macAddressController;

  // ---------- Выбранный тип ----------
  String? selectedType;

  // ---------- Список типов аппаратов ----------
  final List<String> machineTypes = [
    'Water',
    'Coffee',
    'Snack/Soda',
    'Other',
  ];


  /* ================= LIFECYCLE ================= */

  @override
  void initState() {
    super.initState();

    // Инициализация контроллеров
    nameController = TextEditingController();
    locationController = TextEditingController();
    macAddressController = TextEditingController();
  }

  @override
  void dispose() {
    // Освобождение памяти (очень важно!)
    nameController.dispose();
    locationController.dispose();
    macAddressController.dispose();
    super.dispose();
  }


  /* ================= LOGIC ================= */

  /// Основная функция сохранения аппарата
  Future<void> _save() async {
    final name = nameController.text.trim();

    // ---------- Валидация ----------
    if (name.isEmpty || selectedType == null) {
      _showError('Название или тип аппарата не заполнены');
      return;
    }

    // ---------- Проверка на дубликат ----------
    final isDuplicate = widget.machines.any(
      (machine) => machine.name.toLowerCase() == name.toLowerCase(),
    );

    if (isDuplicate) {
      _showError('Такое название уже существует');
      return;
    }

    // ---------- Отправка на сервер ----------
    try {
      final response = await MachineCreateService.create(
        name: name,
        type: selectedType!,
        location: locationController.text,
        macAddress: macAddressController.text,
      );

      // Преобразование JSON в объект
      final machine = Machine.fromJson(response['machine']);

      // Возврат назад с результатом
      if (mounted) {
        Navigator.pop(context, machine);
      }

    } catch (e) {
      // Обработка ошибки
      if (mounted) {
        _showError(e.toString());
      }
    }
  }


  /* ================= UI HELPERS ================= */

  /// Универсальное поле ввода
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),

        filled: true,
        fillColor: AppStyles.secondary,

        // Граница (обычная)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),

        // Граница (при фокусе)
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


  /// Dropdown для выбора типа аппарата
  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      dropdownColor: AppStyles.secondary,
      style: const TextStyle(color: Colors.white),

      decoration: _inputDecoration("Тип аппарата"),

      items: machineTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),

      onChanged: (value) {
        setState(() {
          selectedType = value;
        });
      },
    );
  }


  /// Общий стиль для InputDecoration (чтобы не дублировать код)
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
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
        borderSide: BorderSide(
          color: AppStyles.accent,
          width: 2,
        ),
      ),
    );
  }


  /// Показ ошибки через SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }


  /* ================= UI ================= */

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

          // ---------- Название ----------
          CustomTextField(
            label: 'Название',
            controller: nameController,
          ),

          const SizedBox(height: 20),

          // ---------- Тип ----------
          DropdownButtonFormField<String>(
            value: selectedType,
            dropdownColor: AppStyles.background,
            style: const TextStyle(color: Colors.white),

            decoration: const InputDecoration(
              labelText: "Тип аппарата",
              labelStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: AppStyles.background,
              border: OutlineInputBorder(),
            ),

            items: machineTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),

            onChanged: (value) {
              setState(() {
                selectedType = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // ---------- Локация ----------
          CustomTextField(
            label: 'Локация (опционально)',
            controller: locationController,
            prefixIcon: Icons.location_on_outlined,
          ),

          const SizedBox(height: 20),

          // ---------- MAC address ----------
          CustomTextField(
            label: 'MAC-адрес (опционально)',
            controller: macAddressController,
            prefixIcon: Icons.wifi,
          ),

          const SizedBox(height: 30),

          // ---------- Кнопка ----------
          ElevatedButton(
            onPressed: _save,

            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),

            child: const Text(
              "Сохранить",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}
  }
