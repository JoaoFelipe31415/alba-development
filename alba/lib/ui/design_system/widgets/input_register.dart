import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:flutter/material.dart';

class InputRegister extends StatefulWidget {
  InputRegister({
    super.key,
    required this.title,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    required this.controller,
    this.validator,
    this.onChanged,
  });
  final String title;
  final String labelText;
  final String hintText;
  late bool obscureText;
  final Function(String)? onChanged;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  //TODO: Organizar melhor esses estados

  @override
  State<InputRegister> createState() => _InputRegisterState();
}

class _InputRegisterState extends State<InputRegister> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Spaces.m,
      crossAxisAlignment: .start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextFormField(
          validator: widget.validator,
          onChanged: widget.onChanged,
          controller: widget.controller,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: widget.obscureText
                  ? Icon(Icons.visibility)
                  : Icon(Icons.visibility_off),
              onPressed: () {
                widget.obscureText = !widget.obscureText;
                setState(() {});
              },
            ),
            labelText: widget.labelText,
            hintText: widget.hintText,
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
