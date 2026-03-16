/* [ Flutter ] */
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
/* [ Models ] */
import 'package:frontend_mobile/models/machine.dart';
/* [ Widgets ] */
import 'package:frontend_mobile/widgets/widget_for_machines/machine_detail_row.dart';
import 'package:frontend_mobile/widgets/widget_for_machines/machine_status_row.dart';
import 'package:frontend_mobile/widgets/widget_for_machines/machine_map_widget.dart';
/* [ Styles ] */
import 'package:frontend_mobile/styles/app_styles.dart';
/* [ Services ] */
import 'package:frontend_mobile/services/machine_update_service.dart';
import 'package:frontend_mobile/services/machine_delete_service.dart';
/* [ Screens ] */
import 'package:frontend_mobile/screens/machine/select_location_page.dart';


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
    machine = widget.machine;
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
                  MachineDetailRow( label: "Название", value: machine.name, onEdit: () => _editField("Название", machine.name, "name"), ), const SizedBox(height: 16),
                  MachineDetailRow( label: "Тип", value: machine.type, onEdit: () => _editField("Тип", machine.type, "type"), ), const SizedBox(height: 16),
                  MachineDetailRow( label: "Тип соединения", value: machine.connectionType?.isNotEmpty == true ? machine.connectionType! : "", onEdit: () => _editField("Тип соединения", machine.connectionType ?? "", "connectionType"), ), const SizedBox(height: 16),
                  MachineDetailRow( label: "Регулировка цены (%)", value: machine.priceAdjustment != null ? "${machine.priceAdjustment} %" : "", onEdit: () => _editField("Регулировка цены (%)", machine.priceAdjustment?.toString() ?? "", "priceAdjustment"), ), const SizedBox(height: 16),
                  MachineDetailRow( label: "Локация", value: machine.location?.isNotEmpty == true ? machine.location! : "", onEdit: () => _editField("Локация", machine.location ?? "", "location"), ), const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Row( children: [ const Text( "Координаты", style: TextStyle( color: Colors.white70, fontSize: 14, ), ), const Spacer(),
                  TextButton.icon( onPressed: _openMap, icon: const Icon(Icons.map, color: Colors.white), label: const Text( "Изменить на карте", style: TextStyle(color: Colors.white), ), ), ], ), const SizedBox(height: 8),
                  Text( machine.latitude != null && machine.longitude != null ? "${machine.latitude}, ${machine.longitude}" : "Координаты не указаны", style: const TextStyle( color: Colors.white, fontSize: 16, ), ),

                  // MachineDetailRow( label: "Latitude", value: machine.latitude?.toString() ?? "", onEdit: () => _editField("Latitude", machine.latitude?.toString() ?? "", "latitude"), ), const SizedBox(height: 16),
                  // MachineDetailRow( label: "Longitude", value: machine.longitude?.toString() ?? "", onEdit: () => _editField("Longitude", machine.longitude?.toString() ?? "", "longitude"), ), const SizedBox(height: 16),
                  
                  // if (machine.latitude != null && machine.longitude != null) ...[ 
                    // MachineMapWidget( latitude: machine.latitude!, longitude: machine.longitude!, onTap: (point) { setState(() { machine = machine.copyWith( latitude: point.latitude, longitude: point.longitude, ); }); }, ), const SizedBox(height: 12),
                    // ElevatedButton( onPressed: _updateCoordinates, style: ElevatedButton.styleFrom( backgroundColor: AppStyles.primary, foregroundColor: Colors.white, ), child: const Text("Сохранить координаты"), ),
                  // ] else
                    // const Text( "Координаты не указаны", style: TextStyle(color: Colors.white54), ), const SizedBox(height: 16),
                  MachineDetailRow( label: "Серийный номер", value: machine.serialNumber?.isNotEmpty == true ? machine.serialNumber! : "", onEdit: () => _editField("Серийный номер", machine.serialNumber ?? "", "serialNumber"), ), const SizedBox(height: 16),
                  MachineStatusRow( isActive: machine.isActive ?? false, onChanged: _updateStatus, ),
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

Future<void> _openMap() async {

  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SelectLocationPage(
        latitude: machine.latitude,
        longitude: machine.longitude,
        location: machine.location,
      ),
    ),
  );

  if (result != null) {

    setState(() {

      machine = machine.copyWith(
        latitude: result["latitude"],
        longitude: result["longitude"],
        location: result["location"],
      );

    });

    await _updateCoordinates();
  }

}
}