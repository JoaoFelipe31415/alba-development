import 'package:alba/config/dependencies.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'menu_viewmodel.dart';

class DetalhesPerfilScreen extends StatefulWidget {
  const DetalhesPerfilScreen({super.key});

  @override
  State<DetalhesPerfilScreen> createState() => _DetalhesPerfilScreenState();
}

class _DetalhesPerfilScreenState extends State<DetalhesPerfilScreen> {
  final MenuViewModel _viewModel = injector.get<MenuViewModel>();

  String _ramoSelecionado = 'Alimentos';

  final List<String> _ramosNegocio = [
    'Alimentos',
    'Artesanato',
    'Aulas Particulares / Monitoria',
    'Design / Freelas de Tecnologia',
    'Doces / Confeitaria',
    'Moda / Brechó Universitário',
    'Papelaria / Impressões',
    'Beleza / Estética',
    'Outro(as)',
  ];

  final List<String> _periodosDisponiveis = List.generate(
    10,
    (index) => '${index + 1}º Período',
  );

  @override
  void initState() {
    super.initState();
    _viewModel.initControllers();
    if (_viewModel.perfil['ramoNegocio'] != null &&
        _viewModel.perfil['ramoNegocio'].toString().isNotEmpty) {
      _ramoSelecionado = _viewModel.perfil['ramoNegocio'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (!_viewModel.isEditing && _viewModel.perfil['ramoNegocio'] != null) {
          _ramoSelecionado = _viewModel.perfil['ramoNegocio'];
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: Text(
              _viewModel.isEditing ? "Editar Perfil" : "Dados do Perfil",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.colors.azulAlba,
              ),
            ),
            backgroundColor: context.colors.whiteColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.colors.azulAlba,
              ),
              onPressed: () {
                if (_viewModel.isEditing) {
                  _viewModel.alternarEdicao();
                }
                Navigator.pop(context);
              },
            ),
            actions: [
              if (!_viewModel.isEditing)
                TextButton.icon(
                  onPressed: _viewModel.alternarEdicao,
                  icon: Icon(
                    Icons.edit_rounded,
                    color: context.colors.focusColor,
                    size: 18,
                  ),
                  label: Text(
                    "Editar",
                    style: TextStyle(
                      color: context.colors.focusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: context.colors.azulAlba.withOpacity(
                          0.08,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: context.colors.azulAlba,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _viewModel.perfil['nome'] ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: context.colors.azulAlba,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _viewModel.telefoneFormatado,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colors.whiteColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: context.colors.azulAlba.withOpacity(0.04),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.azulAlba.withOpacity(0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_viewModel.isEditing) ...[
                        _buildInputField(
                          "Nome Completo",
                          _viewModel.nameController,
                        ),
                        _buildInputField(
                          "Telefone Celular (Não modificável)",
                          _viewModel.phoneController,
                          habilitado: false,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: TextFormField(
                            initialValue: _viewModel.perfil['email'],
                            style: TextStyle(
                              color: context.colors.azulAlba,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: "E-mail",
                              labelStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (novoEmail) {
                              _viewModel.perfil['email'] = novoEmail.trim();
                            },
                          ),
                        ),
                        _buildInputField("Curso", _viewModel.cursoController),
                        _buildInputField(
                          "Universidade / Faculdade",
                          _viewModel.uniController,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Período Atual",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value:
                                    _periodosDisponiveis.contains(
                                      _viewModel.periodoController.text,
                                    )
                                    ? _viewModel.periodoController.text
                                    : '1º Período',
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: TextStyle(
                                  color: context.colors.azulAlba,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: context.colors.azulAlba,
                                ),
                                items: _periodosDisponiveis.map((
                                  String periodo,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: periodo,
                                    child: Text(periodo),
                                  );
                                }).toList(),
                                onChanged: (novoPeriodo) {
                                  if (novoPeriodo != null) {
                                    _viewModel.periodoController.text =
                                        novoPeriodo;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ramo do seu Empreendimento",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _ramosNegocio.contains(_ramoSelecionado)
                                    ? _ramoSelecionado
                                    : 'Alimentos',
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                style: TextStyle(
                                  color: context.colors.azulAlba,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: context.colors.azulAlba,
                                ),
                                items: _ramosNegocio.map((String ramo) {
                                  return DropdownMenuItem<String>(
                                    value: ramo,
                                    child: Text(ramo),
                                  );
                                }).toList(),
                                onChanged: (novoRamo) {
                                  if (novoRamo != null) {
                                    setState(() {
                                      _ramoSelecionado = novoRamo;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: _viewModel.isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: context.colors.azulAlba,
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.colors.azulAlba,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    _viewModel.perfil['ramoNegocio'] =
                                        _ramoSelecionado;

                                    if (_viewModel
                                        .periodoController
                                        .text
                                        .isEmpty) {
                                      _viewModel.periodoController.text =
                                          '1º Período';
                                    }

                                    await _viewModel.salvarPerfil();

                                    if (_viewModel.errorMessage == null &&
                                        mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Alterações salvas com sucesso!",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Salvar Alterações",
                                    style: TextStyle(
                                      color: context.colors.whiteColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _viewModel.alternarEdicao,
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        _buildItemInfo(
                          "Telefone de Contato",
                          _viewModel.telefoneFormatado,
                        ),
                        _buildItemInfo(
                          "E-mail de Acesso",
                          _viewModel.perfil['email'],
                        ),
                        _buildItemInfo(
                          "Curso Universitário",
                          _viewModel.perfil['curso'],
                        ),
                        _buildItemInfo(
                          "Instituição de Ensino",
                          _viewModel.perfil['universidade'],
                        ),
                        _buildItemInfo("Período", _viewModel.perfil['periodo']),
                        _buildItemInfo(
                          "Segmento de Negócio / Renda Extra",
                          _viewModel.perfil['ramoNegocio'],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemInfo(String label, String? valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor ?? 'Não informado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.colors.azulAlba,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade100, height: 1),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool habilitado = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextField(
        controller: controller,
        enabled: habilitado,
        style: TextStyle(
          color: habilitado ? context.colors.azulAlba : Colors.grey.shade500,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: label,
          filled: !habilitado,
          fillColor: habilitado ? Colors.transparent : Colors.grey.shade100,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}
