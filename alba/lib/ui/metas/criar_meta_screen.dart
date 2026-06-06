import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/domain/validators/meta_validator.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CriarMetaScreen extends StatefulWidget {
  const CriarMetaScreen({super.key});

  @override
  State<CriarMetaScreen> createState() => _CriarMetaScreenState();
}

class _CriarMetaScreenState extends State<CriarMetaScreen> {
  final metasRepository = injector.get<MetasRepository>();
  final auth = FirebaseAuth.instance;

  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final prazoController = TextEditingController();

  String? selectedTag;
  bool isLoading = false;

  String? tituloError;
  String? descricaoError;
  String? prazoError;
  String? tagError;

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    prazoController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final titulo = tituloController.text;
    final descricao = descricaoController.text;
    final prazoTexto = prazoController.text;
    final tag = selectedTag;

    setState(() {
      tituloError = MetaValidator.validateTitulo(titulo);
      descricaoError = MetaValidator.validateDescricao(
        descricao.trim().isEmpty ? null : descricao,
      );
      prazoError = MetaValidator.validatePrazoTexto(prazoTexto);
      tagError = MetaValidator.validateTag(tag);
    });

    if (tituloError != null ||
        descricaoError != null ||
        prazoError != null ||
        tagError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Revise os campos destacados.'),
          backgroundColor: context.colors.errorColor,
        ),
      );
      return;
    }

    _criarMeta();
  }

  Future<void> _criarMeta() async {
    final prazo = MetaValidator.parseDate(prazoController.text);

    if (prazo == null) {
      setState(() {
        prazoError = MetaValidator.validatePrazoTexto(prazoController.text);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Informe uma data válida.'),
          backgroundColor: context.colors.errorColor,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final meta = MetaDto(
        tituloMeta: tituloController.text.trim(),
        descricao: descricaoController.text.trim().isEmpty
            ? null
            : descricaoController.text.trim(),
        prazo: prazo,
        tag: selectedTag!,
        userId: auth.currentUser?.uid ?? '',
        dataCriacao: DateTime.now(),
      );

      await metasRepository.criarMeta(meta);

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Meta criada com sucesso!'),
            backgroundColor: context.colors.successColor,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: context.colors.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        backgroundColor: colors.whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colors.azulAlba,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Criar Meta',
          style: TextStyle(
            color: colors.azulAlba,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: colors.azulAlba,
            height: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(text: 'Título da meta'),
              const SizedBox(height: 12),
              _TextInput(
                controller: tituloController,
                hintText: 'Título...',
                errorText: tituloError,
                textInputAction: TextInputAction.next,
                onChanged: (_) {
                  if (tituloError != null) {
                    setState(() => tituloError = null);
                  }
                },
              ),
              const SizedBox(height: 28),

              _FieldLabel(text: 'Descrição'),
              const SizedBox(height: 12),
              _TextInput(
                controller: descricaoController,
                hintText: 'Descrição...',
                errorText: descricaoError,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                onChanged: (_) {
                  if (descricaoError != null) {
                    setState(() => descricaoError = null);
                  }
                },
              ),
              const SizedBox(height: 28),

              _FieldLabel(text: 'Prazo'),
              const SizedBox(height: 12),
              _TextInput(
                controller: prazoController,
                hintText: 'DD/MM/AAAA',
                errorText: prazoError,
                keyboardType: TextInputType.number,
                inputFormatters: [DateInputFormatter()],
                textInputAction: TextInputAction.next,
                suffixIcon: Icon(
                  Icons.calendar_today_rounded,
                  color: colors.greyThree,
                  size: 22,
                ),
                onChanged: (_) {
                  if (prazoError != null) {
                    setState(() => prazoError = null);
                  }
                },
              ),
              const SizedBox(height: 28),

              _FieldLabel(text: 'TAG\'s'),
              const SizedBox(height: 12),
              _TagDropdown(
                value: selectedTag,
                errorText: tagError,
                onChanged: (value) {
                  setState(() {
                    selectedTag = value;
                    tagError = null;
                  });
                },
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.azulAlba,
                    disabledBackgroundColor: colors.azulAlba.withOpacity(0.55),
                    elevation: 8,
                    shadowColor: colors.azulAlba.withOpacity(0.25),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.whiteColor,
                            ),
                          ),
                        )
                      : Text(
                          'Criar Meta',
                          style: TextStyle(
                            color: colors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Text(
      text,
      style: TextStyle(
        color: colors.azulAlba,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const _TextInput({
    required this.controller,
    required this.hintText,
    required this.errorText,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          style: TextStyle(
            color: colors.blackColor.withOpacity(0.82),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: colors.greyThree,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: colors.whiteColor,
            contentPadding: EdgeInsets.symmetric(
              vertical: maxLines > 1 ? 20 : 18,
              horizontal: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: hasError ? colors.errorColor : colors.greyThree,
                width: 1.4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: hasError ? colors.errorColor : colors.greyThree,
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: hasError ? colors.errorColor : colors.azulAlba,
                width: 1.8,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: TextStyle(
              color: colors.errorColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _TagDropdown extends StatelessWidget {
  final String? value;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  const _TagDropdown({
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: colors.whiteColor,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.greyFive,
            size: 30,
          ),
          style: TextStyle(
            color: colors.blackColor.withOpacity(0.82),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.whiteColor,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: hasError ? colors.errorColor : colors.greyThree,
                width: 1.4,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: hasError ? colors.errorColor : colors.greyThree,
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: hasError ? colors.errorColor : colors.azulAlba,
                width: 1.8,
              ),
            ),
          ),
          hint: Text(
            'Selecione uma tag',
            style: TextStyle(
              color: colors.greyThree,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          items: [
            DropdownMenuItem(
              value: 'negocio',
              child: _TagOption(
                label: 'Negócio',
                backgroundColor: colors.neonGreen,
                textColor: colors.azulAlba,
              ),
            ),
            DropdownMenuItem(
              value: 'faculdade',
              child: _TagOption(
                label: 'Faculdade',
                backgroundColor: colors.primaryColor,
                textColor: colors.whiteColor,
              ),
            ),
          ],
          onChanged: onChanged,
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: TextStyle(
              color: colors.errorColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _TagOption extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _TagOption({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length > 8) {
      text = text.substring(0, 8);
    }

    String formattedText = '';

    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        formattedText += '/';
      }

      formattedText += text[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: formattedText.length),
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}