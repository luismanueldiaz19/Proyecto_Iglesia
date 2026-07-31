import 'package:flutter/material.dart';
import '../../theme/church_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final String? prefixText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.prefixText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ChurchColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ChurchColors.lightGrey, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixText: prefixText,
          hintStyle: const TextStyle(color: ChurchColors.grey, fontSize: 14),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: ChurchColors.primary, size: 20) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: prefixIcon == null ? 16 : 0,
          ),
        ),
      ),
    );
  }
}
