import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color _backgroundColor = Color(0xFFF1F2F6);
  static const Color _primaryBlue = Color(0xFF123DBE);
  static const Color _inputBackgroundColor = Color(0xFFD9DEE7);

  static const String _title = 'ESQUECEU\nA SENHA?';
  static const String _emailHint = 'informe seu email';
  static const String _sendButtonText = 'Enviar email';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  bool _isLoading = false;
  bool _isPressed = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      _showMessage('Se o e-mail existir, enviaremos instruções.');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Erro ao enviar e-mail';
      if (e.code == 'invalid-email') {
        message = 'E-mail inválido';
      }

      _showMessage(message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Erro inesperado');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Informe seu e-mail';
    if (!_emailRegex.hasMatch(email)) return 'E-mail inválido';

    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + keyboard),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                const SizedBox(height: 165),
                _buildTitle(),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 60),
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Transform.translate(
      offset: const Offset(-4, 0),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: _primaryBlue,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _title,
      style: GoogleFonts.poppins(
        color: _primaryBlue,
        fontSize: 42,
        fontWeight: FontWeight.w500,
        height: 1.02,
        letterSpacing: -0.6,
      ),
    );
  }

  Widget _buildEmailField() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 312,
        child: Container(
          height: 34,
          decoration: BoxDecoration(
            color: _inputBackgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextFormField(
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: _emailHint,
              hintStyle: TextStyle(fontSize: 12),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 8, right: 6),
                child: Icon(Icons.mail_outline, size: 18),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 30),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _isLoading ? null : _sendPasswordResetEmail,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 312,
          height: 56,
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          decoration: BoxDecoration(
            color: _primaryBlue,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isPressed ? 0.15 : 0.25),
                blurRadius: _isPressed ? 8 : 14,
                offset: Offset(0, _isPressed ? 3 : 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  _sendButtonText,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
