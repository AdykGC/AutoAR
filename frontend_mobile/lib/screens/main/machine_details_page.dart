import 'package:flutter/material.dart';
import 'package:frontend_mobile/models/machine.dart';
import 'package:frontend_mobile/services/machine_update_service.dart';
import 'package:frontend_mobile/styles/app_styles.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


/// Страница деталей аппарата с возможностью редактирования полей
class MachineDetailsPage extends StatefulWidget {
  final Machine machine;

  const MachineDetailsPage({super.key, required this.machine});

  @override
  State<MachineDetailsPage> createState() => _MachineDetailsPageState();
}

class _MachineDetailsPageState extends State<MachineDetailsPage> {
  late Machine machine;

  @override
  void initState() {
    super.initState();
    // Копируем данные машины из переданных параметров
    machine = widget.machine;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        title: const Text("Детали аппарата"),
        backgroundColor: AppStyles.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Card(
            color: AppStyles.dashboardCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Название аппарата
                  _buildDetailRow("Название", machine.name, "name"),
                  const SizedBox(height: 16),

                  // Тип аппарата
                  _buildDetailRow("Тип", machine.type, "type"),
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),

                  _buildDetailRow(
                    "Тип соединения",
                    machine.connectionType?.isNotEmpty == true
                        ? machine.connectionType!
                        : "",
                    "connectionType",
                  ),

                  const SizedBox(height: 16),

                  _buildDetailRow(
                    "Регулировка цены (%)",
                    machine.priceAdjustment != null
                        ? "${machine.priceAdjustment} %"
                        : "",
                    "priceAdjustment",
                  ),

                  // Локация (если указана)
                  _buildDetailRow(
                    "Локация",
                    machine.location?.isNotEmpty == true ? machine.location! : "",
                    "location",
                  ),

                  // Карту показываем только если есть координаты
                  _buildMapWidget(),
                  const SizedBox(height: 16),

                  // Серийный номер (если указан)
                  _buildDetailRow(
                    "Серийный номер",
                    machine.serialNumber?.isNotEmpty == true ? machine.serialNumber! : "",
                    "serialNumber",
                  ),
                  const SizedBox(height: 16),

                  // Статус с переключателем
                  _buildStatusRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // Строка параметра с кнопкой редактирования
  // =======================================================
  Widget _buildDetailRow(String label, String value, String fieldKey) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Подпись поля
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),

              // Значение поля
              Text(
                value.isNotEmpty ? value : "Не указано",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Кнопка редактирования
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
          onPressed: () => _editField(label, value, fieldKey),
        ),
      ],
    );
  }

  // =======================================================
  // Статус аппарата (с переключателем)
  // =======================================================
  Widget _buildStatusRow() {
    return Row(
      children: [
        const Text(
          "Статус",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const Spacer(),

        // Переключатель статуса
        Switch(
          value: machine.isActive == true,
          activeColor: Colors.green,
          onChanged: (value) => _updateStatus(value),
        ),
      ],
    );
  }

  // =======================================================
  // Редактирование текстового поля через диалог
  // =======================================================
  Future<void> _editField(
    String label,
    String currentValue,
    String fieldKey,
  ) async {
    final controller = TextEditingController(text: currentValue);

    // Открываем диалог для ввода нового значения
    final newValue = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppStyles.dashboardCard,
        title: Text("Изменить $label"),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
                foregroundColor: Colors.white, // цвет текста
            ),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: TextButton.styleFrom(
                foregroundColor: Colors.white, // цвет текста
            ),
            child: const Text("Сохранить"),
          ),
        ],
      ),
    );

    // Если значение не изменилось — выходим
    if (newValue == null || newValue == currentValue) return;

    try {
      // Отправляем обновление на сервер
      final response = await MachineUpdateService.update(
        id: machine.id,
        name: fieldKey == "name" ? newValue : machine.name,
        type: fieldKey == "type" ? newValue : machine.type,
        location: fieldKey == "location" ? newValue : machine.location,
        serialNumber: fieldKey == "serialNumber" ? newValue : machine.serialNumber,
      );

      // Обновляем локальную модель
      final updatedMachine = Machine.fromJson(response['data']['machine']);
      setState(() {
        machine = updatedMachine;
      });
    } catch (e) {
      // Показываем ошибку, если есть
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // =======================================================
  // Обновление статуса аппарата
  // =======================================================
  Future<void> _updateStatus(bool value) async {
    try {
      // Отправляем обновление на сервер (тут логика без изменения полей, кроме isActive на сервере)
      final response = await MachineUpdateService.update(
        id: machine.id,
        name: machine.name,
        type: machine.type,
        location: machine.location,
        serialNumber: machine.serialNumber,
      );

      // Обновляем локальную модель
      final updatedMachine = Machine.fromJson(response['data']['machine']);
      setState(() {
        machine = updatedMachine;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
  // =======================================================
  // Карта с местоположением аппарата (для flutter_map 8+)
  // =======================================================
  Widget _buildMapWidget() {
    if (machine.latitude == null || machine.longitude == null) {
     return const Text(
        "Координаты не указаны",
       style: TextStyle(color: Colors.white54),
     );
    }

   final lat = machine.latitude!;
    final lng = machine.longitude!;

    return Container(
     margin: const EdgeInsets.only(top: 12),
     height: 200,
     decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(16),
       border: Border.all(color: Colors.white54),
     ),
     child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FlutterMap(
          options: MapOptions(
            // начальный центр и уровень зума
            initialCenter: LatLng(lat, lng),
            initialZoom: 15.0,
          ),
          children: [
           // Слой с OSM‑тайлами
           TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.app',
           ),

            // Слой с маркером
           MarkerLayer(
             markers: [
               Marker(
                  point: LatLng(lat, lng),
                 width: 40,
                 height: 40,
                 alignment: Alignment.center,
                 // Вместо builder используем child
                 child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                   size: 32,
                 ),
               ),
              ],
           ),
         ],
       ),
     ),
    );
  }


}


