import 'package:flutter/material.dart';
import 'package:frontend_mobile/models/machine.dart';
import 'package:frontend_mobile/screens/main/machine_details_page.dart';
import 'package:frontend_mobile/styles/app_styles.dart';

class MachineCard extends StatelessWidget {
  final Machine machine;
  final Function(Machine) onUpdate;

  const MachineCard({
    super.key,
    required this.machine,
    required this.onUpdate,
  });

  String _buildSubtitle() {
    final parts = [
      "Тип: ${machine.type}",
      if (machine.location?.isNotEmpty ?? false) "Локация: ${machine.location}",
      if (machine.serialNumber?.isNotEmpty ?? false) "С/Н: ${machine.serialNumber}",
    ];
    return parts.join(" • ");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(machine.id),
      color: AppStyles.dashboardCard,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () async {
          final updatedMachine = await Navigator.push<Machine>(
            context,
            MaterialPageRoute(
              builder: (_) => MachineDetailsPage(machine: machine),
            ),
          );
          if (updatedMachine != null) {
            onUpdate(updatedMachine);
          }
        },
        title: Text(machine.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          _buildSubtitle(),
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}