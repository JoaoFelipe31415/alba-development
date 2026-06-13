import 'package:alba/config/dependencies.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'menu_viewmodel.dart';

class CancelarPlanoScreen extends StatefulWidget {
  const CancelarPlanoScreen({super.key});

  @override
  State<CancelarPlanoScreen> createState() => _CancelarPlanoScreenState();
}

class _CancelarPlanoScreenState extends State<CancelarPlanoScreen> {
  final MenuViewModel _viewModel = injector.get<MenuViewModel>();
  final TextEditingController _feedbackController = TextEditingController();

  String? _motivoSelecionado;

  final List<String> _motivos = [
    'Achei o valor da assinatura alto',
    'Não estou usando o aplicativo',
    'Faltam funcionalidades que preciso',
    'Encontrei muitos travamentos ou erros',
    'Outro motivo',
  ];

  void _processarCancelamento() async {
    if (_motivoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor, selecione o motivo principal do cancelamento.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Chama o método estruturado no ViewModel
    final sucesso = await _viewModel.cancelarAssinatura(
      _motivoSelecionado!,
      _feedbackController.text,
    );

    if (mounted) {
      if (sucesso) {
        // Mostra mensagem de sucesso e volta para o Menu atualizado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sua assinatura foi cancelada com sucesso."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        // Mostra o erro caso dê falha
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage ?? "Erro ao cancelar plano."),
            backgroundColor: context.colors.errorColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.colors.azulAlba,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Cancelar Assinatura",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.colors.azulAlba,
          ),
        ),
        backgroundColor: context.colors.whiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.azulAlba),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⚠️ Card de Alerta de Perda de Benefícios
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFB3B3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFFF0004),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "O que você vai perder?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFF0004),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Ao cancelar o plano premium do ALBA, você perderá imediatamente o acesso aos relatórios avançados de evolução acadêmica, limite ilimitado de metas e o suporte prioritário.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF0004).withOpacity(0.8),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  "Poxa, que pena que está nos deixando! Nos ajude a melhorar dizendo o motivo principal:",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.colors.azulAlba,
                  ),
                ),
                const SizedBox(height: 12),

                // 🔘 Lista de Motivos (Radio List)
                Column(
                  children: _motivos.map((motivo) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: context.colors.whiteColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _motivoSelecionado == motivo
                              ? context.colors.focusColor
                              : context.colors.azulAlba.withOpacity(0.04),
                        ),
                      ),
                      child: RadioListTile<String>(
                        title: Text(
                          motivo,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.colors.azulAlba,
                          ),
                        ),
                        value: motivo,
                        groupValue: _motivoSelecionado,
                        activeColor: context.colors.focusColor,
                        onChanged: (value) {
                          setState(() {
                            _motivoSelecionado = value;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                Text(
                  "Quer nos contar mais alguma coisa? (Opcional)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.colors.azulAlba,
                  ),
                ),
                const SizedBox(height: 10),

                // 📝 Campo de Feedback Escrito
                TextField(
                  controller: _feedbackController,
                  maxLines: 3,
                  style: TextStyle(
                    color: context.colors.azulAlba,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: "Escreva aqui sua sugestão ou crítica...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: context.colors.whiteColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.colors.azulAlba.withOpacity(0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: context.colors.azulAlba.withOpacity(0.08),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: context.colors.focusColor),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 🚨 Botão de Confirmação de Cancelamento
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _processarCancelamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.errorColor,
                      foregroundColor: context.colors.whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Confirmar Cancelamento",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 💚 Botão de Desistir e Continuar Premium
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Quero continuar no Plano Premium",
                      style: TextStyle(
                        color: context.colors.azulAlba,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}
