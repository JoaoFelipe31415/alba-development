import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/utils/images.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      _showMessage('Se o e-mail existir, enviaremos as instruções.');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Não foi possível enviar o e-mail. Tente novamente.';

      if (e.code == 'invalid-email') {
        message = 'Informe um e-mail válido.';
      }

      _showMessage(message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Informe seu e-mail.';
    if (!_emailRegex.hasMatch(email)) return 'Informe um e-mail válido.';

    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.colors.azulAlba,
        content: Text(
          message,
          style: TextStyle(
            color: context.colors.whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: context.colors.whiteColor,
      body: SafeArea(
        child: Stack(
          children: [
            const _ForgotPasswordBackground(),
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + keyboard),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _Header(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 46),
                    _MainCard(
                      emailController: _emailController,
                      validateEmail: _validateEmail,
                      isLoading: _isLoading,
                      onSubmit: _sendPasswordResetEmail,
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

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({
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
        SvgPicture.asset(
          ImagesConstants.logoNome,
          width: 118,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        const SizedBox(width: 44),
      ],
    );
  }
}

class _MainCard extends StatelessWidget {
  final TextEditingController emailController;
  final String? Function(String?) validateEmail;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _MainCard({
    required this.emailController,
    required this.validateEmail,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
      decoration: BoxDecoration(
        color: context.colors.whiteColor.withOpacity(0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: context.colors.azulAlba.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.azulAlba.withOpacity(0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: context.colors.azulAlba.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              color: context.colors.azulAlba,
              size: 42,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Esqueceu sua senha?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.azulAlba,
              fontSize: 29,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Informe seu e-mail cadastrado e enviaremos as instruções para você recuperar o acesso.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.blackColor.withOpacity(0.58),
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 30),
          _EmailInput(
            controller: emailController,
            validator: validateEmail,
          ),
          const SizedBox(height: 26),
          _SendButton(
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 18),
          Text(
            'Verifique também a caixa de spam ou promoções.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.blackColor.withOpacity(0.42),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;

  const _EmailInput({
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      style: TextStyle(
        fontSize: 16,
        color: context.colors.blackColor.withOpacity(0.82),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colors.inputColor.withOpacity(0.75),
        hintText: 'seu@email.com',
        hintStyle: TextStyle(
          fontSize: 15.5,
          color: context.colors.blackColor.withOpacity(0.38),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.mail_outline_rounded,
          size: 23,
          color: context.colors.azulAlba.withOpacity(0.78),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 17,
          horizontal: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.greyThree.withOpacity(0.55),
            width: 1.3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.greyThree.withOpacity(0.55),
            width: 1.3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.focusColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.errorColor,
            width: 1.4,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.errorColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SendButton({
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
        onPressed: isLoading ? null : onPressed,
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
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: context.colors.whiteColor,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Enviar e-mail',
                style: TextStyle(
                  color: context.colors.whiteColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _ForgotPasswordBackground extends StatelessWidget {
  const _ForgotPasswordBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -115,
            right: -110,
            child: _SoftCircle(
              size: 245,
              color: context.colors.focusColor.withOpacity(0.12),
            ),
          ),
          Positioned(
            top: 245,
            left: -125,
            child: _SoftCircle(
              size: 230,
              color: context.colors.neonGreen.withOpacity(0.10),
            ),
          ),
          Positioned(
            bottom: -125,
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