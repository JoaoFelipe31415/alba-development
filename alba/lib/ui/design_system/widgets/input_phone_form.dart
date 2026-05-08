import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputPhoneForm extends StatefulWidget {
  const InputPhoneForm({
    super.key,
    required this.title,
    required this.labelText,
    required this.hintText,
    required this.obscureText,
    required this.inputFormatters,
    required this.keyboardType,
    this.prefix,
    required this.controller,
    required this.validator,
    required this.onChanged,
    required this.isPassword,
  });
  final String title;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isPassword;
  @override
  State<InputPhoneForm> createState() => _InputPhoneFormState();
}

class _InputPhoneFormState extends State<InputPhoneForm> {
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      controller: widget.controller,
      obscureText: _obscureText,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        prefix: widget.prefix,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: _obscureText
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
                onPressed: () {
                  _obscureText = !_obscureText;
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
    );
  }
}
