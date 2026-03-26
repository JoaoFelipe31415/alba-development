import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:flutter/material.dart';

class InputLogin extends StatefulWidget {
  InputLogin({
    super.key,
    required this.labelText,
    this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.controller,
    this.onChanged,
    this.obscureText = false,
  });
  final String labelText;
  final Widget? prefixIcon;
  bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  bool obscureText;

  @override
  State<InputLogin> createState() => _InputLoginState();
}

class _InputLoginState extends State<InputLogin> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: widget.obscureText
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
                onPressed: () {
                  widget.obscureText = !widget.obscureText;
                  setState(() {});
                },
              )
            : null,
        hintText: widget.labelText,
        prefixIcon: widget.prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spaces.l),
        ),
      ),
    );
  }
}
