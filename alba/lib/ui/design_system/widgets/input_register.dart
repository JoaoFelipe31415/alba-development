import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:flutter/material.dart';

class InputRegister extends StatelessWidget {
  const InputRegister({
    super.key,
    required this.title,
    required this.labelText,
    required this.hintText,
    required this.obscureText,
  });
  final String title;
  final String labelText;
  final String hintText;
  final bool obscureText;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Spaces.m,
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Senha',
            hintText: '••••••••',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spaces.s),
            ),
          ),
        ),
      ],
    );
  }
}
