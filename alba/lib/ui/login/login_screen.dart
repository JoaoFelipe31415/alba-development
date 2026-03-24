import 'package:alba/domain/dto/credentials_login_dto.dart';
import 'package:alba/domain/validators/login_validator.dart';
import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:alba/ui/design_system/widgets/input_login.dart';
import 'package:alba/ui/home/home_screen.dart';
import 'package:alba/ui/login/login_viewmodel.dart';
import 'package:alba/ui/utils/images.dart';
import 'package:alba/ui/design_system/widgets/row_line.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:alba/ui/register/register_screen.dart';
const double gap = 12.5;
const double radiusEnterButton = Spaces.m + 2;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  
  Widget build(BuildContext context) {
    final viewmodel = LoginViewmodel();
    final validator = LoginValidator();
    final dto = CredentialsLoginDto();

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: .max,
              mainAxisAlignment: .center,
              children: [
                Stack(
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        ImagesConstants.logoNome,
                        width: 128,
                        height: 351,
                      ),
                    ),
                    Positioned(
                      left: 26,
                      bottom: 70,
                      child: Text(
                        'Entre para continuar sua jornada!',
                        style: TextStyle(
                          fontSize: Spaces.xl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spaces.l),
                  child: Form(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InputLogin(
                          labelText: 'seu@email.com',
                          prefixIcon: Icon(Icons.email),
                          validator: validator.byField(dto, 'email'),
                          controller: emailController,
                          onChanged: (value) {
                            dto.setEmail(value);
                          },
                        ),
                        InputLogin(
                          labelText: '••••••••',
                          prefixIcon: Icon(Icons.lock),
                          isPassword: true,
                          validator: validator.byField(dto, 'password'),
                          controller: passwordController,
                          onChanged: (value) {
                            dto.setPassword(value);
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Esqueci minha senha'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                                var result = await viewmodel.login(dto);
                                if (result) {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Falha no login. Verifique suas credenciais.')),
                                  );
                                }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                radiusEnterButton,
                              ),
                            ),
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: Spaces.xxl,
                              color: Colors.white,
                            ),
                          ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
