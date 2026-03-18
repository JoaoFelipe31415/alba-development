import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:alba/ui/design_system/widgets/input_login.dart';
import 'package:alba/ui/utils/images.dart';
import 'package:alba/ui/design_system/widgets/row_line.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:alba/ui/register/register_screen.dart';
const double gap = 12.5;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                Image.asset(ImagesConstants.logoNome, height: 300),
                Text('Entre para continuar sua jornada!'),
                Form(
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InputLogin(
                        labelText: 'seu@email.com',
                        prefixIcon: Icon(Icons.email),
                      ),
                      InputLogin(
                        labelText: '••••••••',
                        prefixIcon: Icon(Icons.lock),
                        isPassword: true,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Esqueci minha senha'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text('Entrar'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: RowLine()),
                          SizedBox(width: gap),
                          Text('ou'),
                          SizedBox(width: gap),
                          Expanded(child: RowLine()),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: SignInButton(
                          Buttons.google,
                          onPressed: () {},
                          text: "Entrar com o Google",
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'Não tem uma conta? ',
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Cadastre-se',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(context, 
                                  MaterialPageRoute(builder: (context) => RegisterScreen()));
                                  //TODO: Implementar cadastro
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
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
