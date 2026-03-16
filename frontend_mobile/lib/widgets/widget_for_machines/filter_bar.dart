import 'package:flutter/material.dart';
import 'package:frontend_mobile/models/machine_filter.dart';
import 'package:frontend_mobile/styles/app_styles.dart';

class FilterBar extends StatelessWidget {
  final MachineFilter currentFilter;
  final Function(MachineFilter) onFilterChanged;

  const FilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  Widget _buildFilterButton({
    required IconData icon,
    required MachineFilter filter,
    required String label,
  }) {
    final isSelected = currentFilter == filter;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onFilterChanged(filter),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppStyles.selected : AppStyles.unselected,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppStyles.selected : AppStyles.unselected,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFilterButton(
          icon: Icons.list,
          filter: MachineFilter.all,
          label: "All",
        ),
        _buildFilterButton(
          icon: Icons.check_circle,
          filter: MachineFilter.active,
          label: "Active",
        ),
        _buildFilterButton(
          icon: Icons.cancel,
          filter: MachineFilter.inactive,
          label: "Inactive",
        ),
      ],
    );
  }
}