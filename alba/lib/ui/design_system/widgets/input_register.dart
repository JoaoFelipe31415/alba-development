import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.isPassword = false,
    this.inputFormatters,
    this.keyboardType,
    this.prefix,
  });
  final String title;
  final String labelText;
  final String hintText;
  late bool obscureText;
  final Function(String)? onChanged;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? prefix;

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
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          controller: widget.controller,
          obscureText: widget.obscureText,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            prefix: widget.prefix,
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
            labelText: widget.labelText,
            hintText: widget.hintText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            errorMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Spaces.s),
            ),
          ),
        ),
      ],
    );
  }
}
