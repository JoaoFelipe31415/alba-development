import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'menu_viewmodel.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Paleta de Cores Padrão do ALBA
  final Color primaryColor = const Color(0xFFFF7A00); // Laranja Alba
  final Color textColor = const Color(0xFF1F2937); // Cinza Escuro
  final Color backgroundColor = const Color(0xFFF3F4F6);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuViewModel>().carregarDadosUsuario();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MenuViewModel>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Menu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fluxo de Erro Cadastrado no Jira
                  if (viewModel.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        "⚠️ ${viewModel.errorMessage!}",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildSeccaoPerfil(viewModel),
                  const SizedBox(height: 20),
                  _buildSeccaoAssinatura(viewModel),
                  const SizedBox(height: 20),
                  _buildSeccaoSuporte(),
                  const SizedBox(height: 32),

                  // Versão do Aplicativo (Critério de Aceitação)
                  const Center(
                    child: Text(
                      "Versão 1.0.0",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // --- SEÇÃO PERFIL ---
  Widget _buildSeccaoPerfil(MenuViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, size: 36, color: primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.perfil['nome'] ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      viewModel.perfil['email'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      viewModel.perfil['telefone'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  viewModel.isEditing ? Icons.close : Icons.edit,
                  color: primaryColor,
                ),
                onPressed: viewModel.alternarEdicao,
              ),
            ],
          ),
          const Divider(height: 24),
          if (viewModel.isEditing) ...[
            _buildCampoTexto("Nome", viewModel.nameController),
            _buildCampoTexto("Curso", viewModel.cursoController),
            _buildCampoTexto("Universidade/Faculdade", viewModel.uniController),
            _buildCampoTexto("Período", viewModel.periodoController),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: viewModel.salvarPerfil,
                child: const Text(
                  "Salvar Alterações",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            _buildItemInfo(
              Icons.school_outlined,
              "Curso",
              viewModel.perfil['curso'],
            ),
            _buildItemInfo(
              Icons.account_balance_outlined,
              "Instituição",
              viewModel.perfil['universidade'],
            ),
            _buildItemInfo(
              Icons.timeline,
              "Período",
              viewModel.perfil['periodo'],
            ),
          ],
        ],
      ),
    );
  }

  // --- SEÇÃO ASSINATURA ---
  Widget _buildSeccaoAssinatura(MenuViewModel viewModel) {
    final hasAssinatura = viewModel.assinatura != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                "Sua Assinatura",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (!hasAssinatura)
            // Fluxo Alternativo do Jira
            const Text(
              "Você não possui assinatura ativa.",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    viewModel.assinatura!['statusAssinatura']
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Text(
                  viewModel.assinatura!['valorPlano'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Renovação em: ${viewModel.assinatura!['dataRenovacao']}",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  // --- SEÇÃO SUPORTE ---
  Widget _buildSeccaoSuporte() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.headset_mic_rounded, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                "Contato & Suporte",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildItemInfo(
            Icons.email_outlined,
            "E-mail de Suporte",
            "suporte@albaapp.com.br",
          ),
          _buildItemInfo(
            Icons.phone_android_outlined,
            "WhatsApp Suporte",
            "(81) 98888-8888",
          ),
          const Divider(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.help_outline_rounded, color: primaryColor),
            title: const Text(
              "FAQ - Perguntas Frequentes",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              // Navegar para FAQ interna ou abrir link
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE PADRONIZAÇÃO ---
  Widget _buildItemInfo(IconData icon, String label, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Expanded(
            child: Text(
              valor ?? 'Não informado',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoTexto(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
      ),
    );
  }
}
