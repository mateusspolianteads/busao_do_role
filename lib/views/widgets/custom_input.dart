import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String placeholder;
  final IconData icon;
  final bool isPassword;

  const CustomInput({
    super.key, 
    required this.label, 
    required this.placeholder, 
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 38, bottom: 8),
          child: Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        TextField(
          obscureText: isPassword,
          style: const TextStyle(color: AppColors.textMain),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.textMain, size: 18),
            filled: true,
            fillColor: AppColors.glass,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}