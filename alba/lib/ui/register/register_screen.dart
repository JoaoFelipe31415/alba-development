import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/auth_repository.dart';
import 'package:alba/domain/dto/credentials_register_dto.dart';
import 'package:alba/domain/validators/register_validator.dart';
import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/design_system/widgets/input_phone_form.dart';
import 'package:alba/ui/design_system/widgets/input_register.dart';
import 'package:alba/ui/register/register_viewmodel.dart';
import 'package:alba/ui/utils/images.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final viewmodel = RegisterViewmodel(injector.get<AuthRepository>());
  final validator = RegisterValidator();
  final dto = CredentialsRegisterDto();

  String _countryCode = '+55';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void listener() {
    final state = viewmodel.state;

    switch (state) {
      case RegisterStateSuccess():
        Navigator.pop(context);
        break;

      case RegisterStateError():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.colors.errorColor,
            content: Text(
              state.message,
              style: TextStyle(
                color: context.colors.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        break;

      default:
        break;
    }
  }

  void submmit() {
    if (formKey.currentState!.validate()) {
      viewmodel.register(dto);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.colors.errorColor,
        content: Text(
          'Preencha todos os campos corretamente.',
          style: TextStyle(
            color: context.colors.whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    viewmodel.addListener(listener);
  }

  @override
  void dispose() {
    viewmodel.removeListener(listener);
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: context.colors.whiteColor,
      body: SafeArea(
        child: Stack(
          children: [
            const _RegisterDecorations(),
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(24, 14, 24, 24 + keyboard),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RegisterHeader(
                      onBack: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 22),
                    _TitleBlock(),
                    const SizedBox(height: 24),
                    _RegisterCard(
                      child: Column(
                        children: [
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
                          const SizedBox(height: 18),
                          InputRegister(
                            controller: passwordController,
                            title: 'Digite uma senha',
                            isPassword: true,
                            labelText: 'Senha',
                            hintText: '••••••••',
                            obscureText: true,
                            validator: validator.byField(dto, 'password'),
                            onChanged: (value) {
                              dto.setPassword(value);
                            },
                          ),
                          const SizedBox(height: 18),
                          InputRegister(
                            controller: confirmPasswordController,
                            title: 'Confirme sua senha',
                            isPassword: true,
                            labelText: 'Confirmar senha',
                            hintText: '••••••••',
                            obscureText: true,
                            validator:
                                validator.byField(dto, 'confirmPassword'),
                            onChanged: (value) {
                              dto.setConfirmPassword(value);
                            },
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 56,
                                margin: const EdgeInsets.only(bottom: 2),
                                decoration: BoxDecoration(
                                  color: context.colors.whiteColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: context.colors.greyThree
                                        .withOpacity(0.70),
                                    width: 1.2,
                                  ),
                                ),
                                child: CountryCodePicker(
                                  padding: EdgeInsets.zero,
                                  onChanged: (value) {
                                    _countryCode = value.dialCode ?? '+55';
                                  },
                                  initialSelection: 'BR',
                                  favorite: const ['+55', 'BR'],
                                  showCountryOnly: false,
                                  showOnlyCountryWhenClosed: false,
                                  alignLeft: false,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: InputPhoneForm(
                                  isPassword: false,
                                  controller: phoneController,
                                  title: 'Qual é o seu telefone?',
                                  labelText: 'Telefone',
                                  hintText: 'XX XXXXX-XXXX',
                                  obscureText: false,
                                  validator: validator.byField(dto, 'phone'),
                                  onChanged: (value) {
                                    final phone =
                                        _countryCode.substring(1) + value;
                                    dto.setPhone(
                                      phone
                                          .replaceAll(' ', '')
                                          .replaceAll('-', ''),
                                    );
                                  },
                                  inputFormatters: [
                                    MaskTextInputFormatter(
                                      mask: '## ##### ####',
                                      filter: {'#': RegExp(r'[0-9]')},
                                      type: MaskAutoCompletionType.lazy,
                                    ),
                                  ],
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListenableBuilder(
                      listenable: viewmodel,
                      builder: (context, child) {
                        final isLoading =
                            viewmodel.state is RegisterStateLoading;

                        return _RegisterButton(
                          isLoading: isLoading,
                          onPressed: isLoading ? null : submmit,
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'Já possui uma conta? ',
                          style: TextStyle(
                            color: context.colors.blackColor.withOpacity(0.78),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Entrar',
                              style: TextStyle(
                                color: context.colors.azulAlba,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.underline,
                                decorationColor: context.colors.azulAlba,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pop(context);
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Spaces.l),
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

class _RegisterHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _RegisterHeader({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: context.colors.azulAlba.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.colors.azulAlba,
                size: 20,
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crie sua conta',
          style: TextStyle(
            color: context.colors.azulAlba,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure seu acesso e comece sua jornada com mais organização, metas e acompanhamento.',
          style: TextStyle(
            color: context.colors.blackColor.withOpacity(0.58),
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _RegisterCard extends StatelessWidget {
  final Widget child;

  const _RegisterCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: context.colors.whiteColor.withOpacity(0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.colors.azulAlba.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.azulAlba.withOpacity(0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _RegisterButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            context.colors.azulAlba,
            context.colors.focusColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.azulAlba.withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: context.colors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: context.colors.whiteColor,
                ),
              )
            : Text(
                'Cadastrar',
                style: TextStyle(
                  color: context.colors.whiteColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}

class _RegisterDecorations extends StatelessWidget {
  const _RegisterDecorations();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -105,
            child: _SoftCircle(
              size: 245,
              color: context.colors.focusColor.withOpacity(0.12),
            ),
          ),
          Positioned(
            top: 285,
            left: -120,
            child: _SoftCircle(
              size: 220,
              color: context.colors.neonGreen.withOpacity(0.09),
            ),
          ),
          Positioned(
            bottom: -130,
            right: -105,
            child: _SoftCircle(
              size: 270,
              color: context.colors.azulAlba.withOpacity(0.07),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}