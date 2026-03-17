import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:flutter/material.dart';

class InputLogin extends StatelessWidget {
  const InputLogin({
    super.key,
    required this.labelText,
    this.prefixIcon,
    this.isPassword = false,
  });
  final String labelText;
  final Widget? prefixIcon;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: labelText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spaces.l),
        ),
      ),
    );
  }
}
