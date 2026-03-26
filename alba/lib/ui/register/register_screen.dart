import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/auth_repository.dart';
import 'package:alba/domain/dto/credentials_register_dto.dart';
import 'package:alba/domain/validators/register_validator.dart';
import 'package:alba/ui/design_system/widgets/input_register.dart';
import 'package:alba/ui/register/register_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:alba/ui/utils/images.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color textColor = Color(0xFF334155);
  final Color primaryColor = Color(0xFF1D4ED8);
  final Color buttonGreen = Color(0xFF84F41E);

  final viewmodel = RegisterViewmodel(injector.get<AuthRepository>());
  final validator = RegisterValidator();
  final dto = CredentialsRegisterDto();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void listener() {
    final state = viewmodel.state;
    switch (state) {
      case RegisterStateSuccess():
        Navigator.pop(context);
        break;
      case RegisterStateError():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message)));
        break;
      default:
        break;
    }
  }

  void submmit() {
    if (formKey.currentState!.validate()) {
      viewmodel.register(dto);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos corretamente')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    viewmodel.addListener(listener);
  }

  @override
  void dispose() {
    viewmodel.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spaces.xxl),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                      ImagesConstants.retornoPage,
                      width: Spaces.m,
                      height: Spaces.xl,
                    ),
                  ),

                  InputRegister(
                    controller: emailController,
                    title: 'Qual é o seu e-mail?',
                    labelText: 'E-mail',
                    hintText: 'ex.: seu@email.com',
                    obscureText: false,
                    validator: validator.byField(dto, 'email'),
                    onChanged: (value) {
                      dto.setEmail(value);
                    },
                  ),

                  InputRegister(
                    controller: passwordController,
                    title: 'Digite uma Senha',
                    isPassword: true,
                    labelText: 'Senha',
                    hintText: '••••••••',
                    obscureText: true,
                    validator: validator.byField(dto, 'password'),
                    onChanged: (value) {
                      dto.setPassword(value);
                    },
                  ),

                  InputRegister(
                    controller: confirmPasswordController,
                    title: 'Confirme sua Senha',
                    isPassword: true,
                    labelText: 'Confirmar Senha',
                    hintText: '••••••••',
                    obscureText: true,
                    onChanged: (value) {
                      dto.setConfirmPassword(value);
                    },
                    validator: validator.byField(dto, 'confirmPassword'),
                  ),

                  ListenableBuilder(
                    listenable: viewmodel,
                    builder: (context, child) {
                      final isLoading = viewmodel.state is RegisterStateLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : submmit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: buttonGreen,
                          shadowColor: textColor,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Cadastrar',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Spaces.xl,
                                ),
                              ),
                      );
                    },
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
      ),
    );
  }
}
