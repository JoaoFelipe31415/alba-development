import 'package:alba/config/dependencies.dart';
import 'cancelar_plano_screen.dart';
import 'faq_screen.dart';
import 'detalhes_perfil_screen.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'menu_viewmodel.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuViewModel _viewModel = injector.get<MenuViewModel>();

  bool _isPerfilExpanded = false;
  bool _isAssinaturaExpanded = false;
  bool _isSuporteExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.escutarDadosUsuario();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: Text(
              "Menu",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.colors.azulAlba,
              ),
            ),
            backgroundColor: context.colors.whiteColor,
            elevation: 0,
            centerTitle: true,
          ),
          body: _viewModel.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: context.colors.azulAlba,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_viewModel.errorMessage != null) ...[
                        _buildCardErro(_viewModel.errorMessage!),
                        const SizedBox(height: 16),
                      ],
                      _buildSeccaoPerfil(),
                      const SizedBox(height: 16),
                      _buildSeccaoAssinatura(),
                      const SizedBox(height: 16),
                      _buildSeccaoSuporte(),
                      const SizedBox(height: 36),
                      const Center(
                        child: Text(
                          "Versão 1.0.0",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCardErro(String erro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB3B3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFF0004)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              erro,
              style: const TextStyle(
                color: Color(0xFFFF0004),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccaoPerfil() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPerfilExpanded = !_isPerfilExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: _boxDecorationPadrao(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: context.colors.azulAlba.withOpacity(0.08),
                  child: Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: context.colors.azulAlba,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _viewModel.perfil['nome'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: context.colors.azulAlba,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isPerfilExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: context.colors.azulAlba.withOpacity(0.6),
                ),
              ],
            ),
            if (_isPerfilExpanded) ...[
              const Divider(height: 28),
              _buildLinhaContato(
                Icons.alternate_email_rounded,
                "E-mail",
                _viewModel.perfil['email'],
              ),
              const SizedBox(height: 8),
              _buildLinhaContato(
                Icons.phone_iphone_rounded,
                "Telefone Celular",
                _viewModel.perfil['telefone'],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetalhesPerfilScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18,
                        color: context.colors.focusColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Mais informações",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.colors.focusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeccaoAssinatura() {
    final temAssinatura = _viewModel.assinatura != null;

    final bool isCancelado =
        temAssinatura &&
        _viewModel.assinatura!['statusAssinatura']
            .toString()
            .toLowerCase()
            .contains('cancelado');

    return GestureDetector(
      onTap: () {
        setState(() {
          _isAssinaturaExpanded = !_isAssinaturaExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: _boxDecorationPadrao(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars_rounded, color: context.colors.azulAlba),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Plano e Assinatura",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: context.colors.azulAlba,
                    ),
                  ),
                ),
                Icon(
                  _isAssinaturaExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: context.colors.azulAlba.withOpacity(0.6),
                ),
              ],
            ),
            if (_isAssinaturaExpanded) ...[
              const Divider(height: 24),
              if (!temAssinatura) ...[
                const Text(
                  "Você não possui assinatura ativa.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _viewModel.activarAssinaturaTeste();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.focusColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Ativar Assinatura (Simular Jira)",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isCancelado
                            ? const Color(
                                0xFFFFECEC,
                              ) // Vermelho claro para cancelado
                            : context.colors.neonGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _viewModel.assinatura!['statusAssinatura']
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(
                          color: isCancelado
                              ? const Color(0xFFFF0004)
                              : context.colors.azulAlba,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      "Valor: ${_viewModel.assinatura!['valorPlano']}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colors.azulAlba,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isCancelado
                      ? "Acesso disponível até o fim do ciclo."
                      : "Renovação em: ${_viewModel.assinatura!['dataRenovacao']}",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),
                if (isCancelado) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final sucesso = await _viewModel.reativarAssinatura();
                        if (sucesso && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Sua assinatura foi reativada com sucesso! 🚀",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        "Assinar Plano (Reativar)",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.focusColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CancelarPlanoScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        "Cancelar assinatura",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeccaoSuporte() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSuporteExpanded = !_isSuporteExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: _boxDecorationPadrao(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: context.colors.azulAlba,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Suporte e FAQ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: context.colors.azulAlba,
                    ),
                  ),
                ),
                Icon(
                  _isSuporteExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: context.colors.azulAlba.withOpacity(0.6),
                ),
              ],
            ),
            if (_isSuporteExpanded) ...[
              const Divider(height: 24),
              _buildLinhaInfo(
                Icons.alternate_email_rounded,
                "E-mail",
                "suporte@albaapp.com.br",
              ),
              _buildLinhaInfo(
                Icons.phone_iphone_rounded,
                "Contato",
                "(81) 98888-8888",
              ),
              const Divider(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: context.colors.focusColor.withOpacity(0.1),
                  child: Icon(
                    Icons.help_center_rounded,
                    size: 18,
                    color: context.colors.focusColor,
                  ),
                ),
                title: Text(
                  "Perguntas Frequentes (FAQ)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.colors.azulAlba,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: context.colors.azulAlba,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FaqScreen()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecorationPadrao() {
    return BoxDecoration(
      color: context.colors.whiteColor,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.colors.azulAlba.withOpacity(0.04)),
      boxShadow: [
        BoxShadow(
          color: context.colors.azulAlba.withOpacity(0.03),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildLinhaContato(IconData icon, String label, String? valor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.colors.azulAlba.withOpacity(0.5)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              valor ?? 'Não informado',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.azulAlba,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLinhaInfo(IconData icon, String label, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colors.azulAlba.withOpacity(0.6)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              valor ?? 'Não informado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.colors.azulAlba,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}
