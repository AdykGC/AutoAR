// machine_details_page.dart

import 'package:flutter/material.dart';
import 'package:frontend_mobile/models/machine.dart';
import 'package:frontend_mobile/services/machine_update_service.dart';
import 'package:frontend_mobile/styles/app_styles.dart';
import 'package:frontend_mobile/services/machine_delete_service.dart';
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

    
    // Если координаты null, задаём тестовые
    machine = machine.copyWith(
      latitude: machine.latitude ?? 43.2075,
     longitude: machine.longitude ?? 76.6699,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Возвращаем обновлённый объект при закрытии
        Navigator.pop(context, machine);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppStyles.background,
        appBar: AppBar(
          title: const Text("Детали аппарата"),
          backgroundColor: AppStyles.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _deleteMachine,
            ),
          ],
        ),
        body: SingleChildScrollView(
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

                  const SizedBox(height: 16),

                  // =============================
                  // ADDED: Latitude
                  // =============================
                  _buildDetailRow(
                    "Latitude",
                    machine.latitude?.toString() ?? "",
                    "latitude",
                  ),

                  const SizedBox(height: 16),

                  // =============================
                  // ADDED: Longitude
                  // =============================
                  _buildDetailRow(
                    "Longitude",
                    machine.longitude?.toString() ?? "",
                    "longitude",
                  ),

                  // Карту показываем только если есть координаты
                  _buildMapWidget(),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: _updateCoordinates,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primary, // цвет кнопки
                      foregroundColor: Colors.white,      // цвет текста
                      
                    ),
                    child: const Text("Сохранить координаты"),
                  ),

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
                value.isEmpty ? "Не указано" : value,
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

        connectionType: fieldKey == "connectionType" ? newValue : machine.connectionType,
        priceAdjustment: fieldKey == "priceAdjustment" ? double.tryParse(newValue) : machine.priceAdjustment,
        installPrice: machine.installPrice,
        latitude: fieldKey == "latitude" ? double.tryParse(newValue) : machine.latitude,
        longitude: fieldKey == "longitude" ? double.tryParse(newValue) : machine.longitude,
        isActive: machine.isActive,
      );

      // Обновляем локальную модель
      final updatedMachine = Machine.fromJson(response['data']['machine']);
      setState(() {
        machine = Machine.fromJson(response['data']['machine']);
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

        connectionType: machine.connectionType,
        installPrice: machine.installPrice,
        priceAdjustment: machine.priceAdjustment,
        latitude: machine.latitude,
        longitude: machine.longitude,
        isActive: value,
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
  // Сохранение координат
  // =======================================================
  Future<void> _updateCoordinates() async {
    try {
      final response = await MachineUpdateService.update(
        id: machine.id,
        name: machine.name,
        type: machine.type,
        location: machine.location,
        serialNumber: machine.serialNumber,
        connectionType: machine.connectionType,
        installPrice: machine.installPrice,
        priceAdjustment: machine.priceAdjustment,
        latitude: machine.latitude,
        longitude: machine.longitude,
        isActive: machine.isActive,
      );

      setState(() {
        machine = Machine.fromJson(response['data']['machine']);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
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
          key: ValueKey("${machine.latitude}_${machine.longitude}"),
          options: MapOptions(
            // начальный центр и уровень зума
            initialCenter: LatLng(lat, lng),
            initialZoom: 15.0,

            onTap: (tapPosition, point) {
              setState(() {
                machine = machine.copyWith(
                  latitude: point.latitude,
                  longitude: point.longitude,
                );
              });
            },
          ),
          children: [
            // Слой с OSM‑тайлами
            TileLayer(
              urlTemplate: 'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}{r}.png',
              subdomains: ['a','b','c','d'],
              userAgentPackageName: 'com.example.app', // оставь свой package name
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

  Future<void> _deleteMachine() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Удалить аппарат?"),
      content: Text("Вы уверены, что хотите удалить ${machine.name}?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            "Отмена",
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            "Удалить",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    await MachineDeleteService.delete(machine.id);

    if (mounted) {
      Navigator.pop(context); // возвращаемся к списку
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

}
