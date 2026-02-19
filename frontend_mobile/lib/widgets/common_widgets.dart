import 'package:flutter/material.dart';
import 'package:frontend_mobile/styles/app_styles.dart';              // [ Styles ]

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon; // ← добавили сюда

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon, // ← и сюда
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: AppStyles.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppStyles.textSecondary),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppStyles.textSecondary) : null,
        filled: true,
        fillColor: AppStyles.secondary.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppStyles.accent),
        ),
      ),
    );
  }
}
