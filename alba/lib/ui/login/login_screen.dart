import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/auth_repository.dart';
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
import 'package:alba/ui/esqueci_senha/senha.dart';

const double gap = 12.5;
const double radiusEnterButton = Spaces.m + 2;

const Color azulAlba = Color(0xFF0532AF);
const Color azulClaroAlba = Color(0xFF7FE2E1);
const Color verdeAlba = Color(0xFF7FFF00);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final viewmodel = LoginViewmodel(injector.get<AuthRepository>());
  final validator = LoginValidator();
  final dto = CredentialsLoginDto();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (viewmodel.isLoggedIn) {
      viewmodel.logout();
    }

    viewmodel.addListener(_listener);
  }

  @override
  void dispose() {
    viewmodel.removeListener(_listener);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _listener() async {
    if (context.mounted && viewmodel.isLoggedIn) {
      if (await viewmodel.verificarConfirmacao()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email nao verificado.')));
      }
    }

    if (context.mounted && !viewmodel.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha no login. Verifique suas credenciais.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            const _LoginDecorations(),
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    const _LoginHeader(),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spaces.l),
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InputLogin(
                            labelText: 'seu@email.com',
                            prefixIcon: const Icon(Icons.email),
                            validator: validator.byField(dto, 'email'),
                            controller: emailController,
                            onChanged: (value) {
                              dto.setEmail(value);
                            },
                          ),
                          InputLogin(
                            labelText: '••••••••',
                            prefixIcon: const Icon(Icons.lock),
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: azulAlba,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          _EnterButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                await viewmodel.login(dto);
                              }
                            },
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(child: RowLine()),
                              const SizedBox(width: gap),
                              Text(
                                'ou',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.55),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: gap),
                              const Expanded(child: RowLine()),
                            ],
                          ),
                          const SizedBox(height: 2),
                          _GoogleLoginButton(
                            onPressed: () {
                              viewmodel.loginWithGoogle();
                            },
                          ),
                          const SizedBox(height: 6),
                          Text.rich(
                            TextSpan(
                              text: 'Não tem uma conta? ',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.78),
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Cadastre-se',
                                  style: const TextStyle(
                                    color: azulAlba,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
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
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Container(
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: azulAlba.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
                child: Center(
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 82,
                    height: 82,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Entre para continuar\nsua jornada!',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: azulAlba,
                  height: 1.08,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acesse sua conta e continue evoluindo com a ALBA.',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.52),
                  height: 1.20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EnterButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusEnterButton),
        gradient: const LinearGradient(
          colors: [azulAlba, Color(0xFF0A58FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: azulAlba.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusEnterButton),
          ),
          minimumSize: const Size(double.infinity, 54),
        ),
        child: const Text(
          'Entrar',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GoogleLoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.075),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SignInButton(
          Buttons.google,
          onPressed: onPressed,
          text: 'Entrar com o Google',
        ),
      ),
    );
  }
}

class _LoginDecorations extends StatelessWidget {
  const _LoginDecorations();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -105,
            right: -105,
            child: Container(
              width: 235,
              height: 235,
              decoration: BoxDecoration(
                color: azulClaroAlba.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: -120,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                color: verdeAlba.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
