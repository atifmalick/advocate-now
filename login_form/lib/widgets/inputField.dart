// components/input_text_field.dart
import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController controller;

  const InputTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          icon: Icon(icon, color: const Color(0xFF1D3557)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $hintText';
          }
          return null;
        },
      ),
    );
  }
}
