import 'package:flutter/material.dart';
import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:alba/ui/utils/images.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spaces.xxl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: .max,
              mainAxisAlignment: .center,
              children: [
                IconButton(onPressed: () {
                  Navigator.pop(context);
                }, icon: Image.asset(ImagesConstants.retornopage, 
                width: 12, 
                height: 24)),
              ], 
            ),
          ),
        ),
      )
    );
  }
}