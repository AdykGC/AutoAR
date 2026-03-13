import 'package:flutter/material.dart';

class MachineDetailRow extends StatelessWidget {
    final String label;
    final String value;
    final VoidCallback onEdit;

    const MachineDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.onEdit,
    });

    @override
    Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                ),
                ),
                const SizedBox(height: 4),
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
        IconButton(
            icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
            onPressed: onEdit,
        ),
        ],
    );
    }
}