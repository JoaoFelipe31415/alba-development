import 'package:alba/ui/design_system/widgets/input_register.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:alba/ui/utils/images.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF334155);
    const Color primaryColor = Color(0xFF1D4ED8);
    const Color buttonGreen = Color(0xFF84F41E);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spaces.xxl),
          child: SingleChildScrollView(
            child: Column(
              spacing: Spaces.xxl,
              mainAxisSize: .max,
              mainAxisAlignment: .center,
              crossAxisAlignment: .start,
              children: [
                const SizedBox(height: Spaces.l),

                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    ImagesConstants.retornopage,
                    width: Spaces.m,
                    height: Spaces.xl,
                  ),
                ),

                InputRegister(
                  title: 'Qual é o seu e-mail?',
                  labelText: 'E-mail',
                  hintText: 'ex.: seu@email.com',
                  obscureText: false,
                ),

                InputRegister(
                  title: 'Digite uma Senha',
                  labelText: 'Senha',
                  hintText: '••••••••',
                  obscureText: true,
                ),

                InputRegister(
                  title: 'Confirme sua Senha',
                  labelText: 'Confirmar Senha',
                  hintText: '••••••••',
                  obscureText: true,
                ),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: buttonGreen,
                    shadowColor: textColor,
                  ),
                  child: Text(
                    'Cadastrar',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: Spaces.xl,
                    ),
                  ),
                ),

                const SizedBox(height: Spaces.l),

                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'Já possui uma conta? ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Entrar',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: primaryColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              //TODO: Implementar Whatsapp
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
