import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/domain/validators/meta_validator.dart';
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
    setState(() {
      tituloError = MetaValidator.validateTitulo(tituloController.text);
      descricaoError = MetaValidator.validateDescricao(
        descricaoController.text.isEmpty ? null : descricaoController.text,
      );
      tagError = MetaValidator.validateTag(selectedTag);

      try {
        final textoData = prazoController.text;
        if (textoData.length != 10 ||
            textoData[2] != '/' ||
            textoData[5] != '/') {
          prazoError = 'Formato inválido. Use DD/MM/YYYY';
        } else {
          final dia = int.parse(textoData.substring(0, 2));
          final mes = int.parse(textoData.substring(3, 5));
          final ano = int.parse(textoData.substring(6, 10));

          if (dia < 1 || dia > 31 || mes < 1 || mes > 12 || ano < 2024) {
            prazoError = 'Data inválida';
          } else {
            final date = DateTime(ano, mes, dia);
            prazoError = MetaValidator.validatePrazo(date);
          }
        }
      } catch (e) {
        prazoError = 'Informe uma data válida (DD/MM/YYYY)';
      }
    });

    if (tituloError != null ||
        descricaoError != null ||
        prazoError != null ||
        tagError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios.'),
          backgroundColor: Color(0xFFFF0004),
        ),
      );
      return;
    }

    _criarMeta();
  }

  Future<void> _criarMeta() async {
    setState(() {
      isLoading = true;
    });

    try {
      final textoData = prazoController.text;
      final dia = int.parse(textoData.substring(0, 2));
      final mes = int.parse(textoData.substring(3, 5));
      final ano = int.parse(textoData.substring(6, 10));

      final prazo = DateTime(ano, mes, dia);

      final meta = MetaDto(
        tituloMeta: tituloController.text,
        descricao: descricaoController.text.isEmpty
            ? null
            : descricaoController.text,
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
          const SnackBar(
            content: Text('Meta criada com sucesso!'),
            backgroundColor: Color(0xFF00C933),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFF0004),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Criar Meta',
          style: TextStyle(
            color: Color(0xFF0052CC),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0052CC)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: const Color(0xFF0052CC), height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Título da meta',
                style: TextStyle(
                  color: Color(0xFF0052CC),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tituloController,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                onChanged: (_) => setState(() => tituloError = null),
                decoration: InputDecoration(
                  hintText: 'Título...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              if (tituloError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    tituloError!,
                    style: const TextStyle(
                      color: Color(0xFFFF0004),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              const Text(
                'Descrição',
                style: TextStyle(
                  color: Color(0xFF0052CC),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descricaoController,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                maxLines: 4,
                onChanged: (_) => setState(() => descricaoError = null),
                decoration: InputDecoration(
                  hintText: 'Descrição...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              if (descricaoError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    descricaoError!,
                    style: const TextStyle(
                      color: Color(0xFFFF0004),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              const Text(
                'Prazo',
                style: TextStyle(
                  color: Color(0xFF0052CC),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prazoController,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                keyboardType: TextInputType.number,
                inputFormatters: [DateInputFormatter()],
                decoration: InputDecoration(
                  hintText: 'DD/MM/YYYY',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              if (prazoError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    prazoError!,
                    style: const TextStyle(
                      color: Color(0xFFFF0004),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              const Text(
                'TAG\'s',
                style: TextStyle(
                  color: Color(0xFF0052CC),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTag,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                dropdownColor: Colors.white,
                onChanged: (value) => setState(() {
                  selectedTag = value;
                  tagError = null;
                }),
                items: const [
                  DropdownMenuItem(value: 'negocio', child: Text('Negócio')),
                  DropdownMenuItem(
                    value: 'faculdade',
                    child: Text('Faculdade'),
                  ),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              if (tagError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    tagError!,
                    style: const TextStyle(
                      color: Color(0xFFFF0004),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052CC),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Criar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
