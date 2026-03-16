import 'package:flutter/material.dart';

class MachineStatusRow extends StatelessWidget {
  final bool isActive;
  final Function(bool) onChanged;

  const MachineStatusRow({
    super.key,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Статус",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Switch(
          value: isActive,
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
      ],
    );
  }
}