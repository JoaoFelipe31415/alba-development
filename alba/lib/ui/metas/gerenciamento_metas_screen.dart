import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/metas/criar_meta_screen.dart';
import 'package:alba/ui/metas/editar_meta_screen.dart';
import 'package:flutter/material.dart';

class GeraciamentoMetasScreen extends StatefulWidget {
  const GeraciamentoMetasScreen({super.key});

  @override
  State<GeraciamentoMetasScreen> createState() =>
      _GeraciamentoMetasScreenState();
}

class _GeraciamentoMetasScreenState extends State<GeraciamentoMetasScreen> {
  final metasRepository = injector.get<MetasRepository>();
  final searchController = TextEditingController();
  String searchQuery = '';
  String _mesSelecionado = _getMesAtual();

  static String _getMesAtual() {
    final meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return 'Todas';
  }

  int _getMesNumero(String mes) {
    final meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return meses.indexOf(mes) + 1;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _navigateToCriarMeta() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CriarMetaScreen()))
        .then((_) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  void _navigateToEditarMeta(MetaDto meta) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => EditarMetaScreen(meta: meta)),
        )
        .then((_) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  void _excluirMeta(String metaId, MetaDto meta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.greyOne,
        title: Text(
          'Tem certeza?',
          style: TextStyle(
            color: context.colors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Esta ação não pode ser desfeita.',
          style: TextStyle(color: context.colors.textPrimaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.colors.focusColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await metasRepository.excluirMeta(metaId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meta excluída com sucesso!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: context.colors.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: context.colors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.whiteColor,
      appBar: AppBar(
        backgroundColor: context.colors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0532AF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gerenciamento de Metas',
          style: const TextStyle(
            color: Color(0xFF0532AF),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Color(0xFF333333)),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar Meta...',
                hintStyle: const TextStyle(color: Color(0xFFABABAB)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFABABAB)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Metas Atuais',
                  style: TextStyle(
                    color: Color(0xFF0532AF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF84F41E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _mesSelecionado,
                    items:
                        [
                              "Todas",
                              'Janeiro',
                              'Fevereiro',
                              'Março',
                              'Abril',
                              'Maio',
                              'Junho',
                              'Julho',
                              'Agosto',
                              'Setembro',
                              'Outubro',
                              'Novembro',
                              'Dezembro',
                            ]
                            .map(
                              (mes) => DropdownMenuItem(
                                value: mes,
                                child: Text(mes),
                              ),
                            )
                            .toList(),
                    onChanged: (mes) {
                      if (mes != null) {
                        setState(() => _mesSelecionado = mes);
                      }
                    },
                    underline: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MetaDto>>(
              stream: searchQuery.isEmpty
                  ? metasRepository.obterMetasStream()
                  : metasRepository.buscarMetasStream(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar metas',
                      style: TextStyle(color: context.colors.errorColor),
                    ),
                  );
                }

                final todasMetas = snapshot.data ?? [];
                final metasDoMes = _mesSelecionado == "Todas"
                    ? todasMetas
                    : todasMetas.where((meta) {
                        return meta.prazo.month ==
                            _getMesNumero(_mesSelecionado);
                      }).toList();

                final totalMetas = metasDoMes.length;

                if (todasMetas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 64,
                          color: context.colors.textPrimaryColor,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhuma meta encontrada',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (metasDoMes.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0532AF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Existem ${metasDoMes.length} Metas para o\nMês de $_mesSelecionado',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${metasDoMes.length} de $totalMetas',
                          style: const TextStyle(
                            color: Color(0xFF0532AF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: totalMetas == 0
                                ? 0
                                : (metasDoMes.length / totalMetas),
                            minHeight: 8,
                            backgroundColor: const Color(0xFFDDD9D9),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF84F41E),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            '${totalMetas > 0 ? ((metasDoMes.length / totalMetas) * 100).toInt() : 0}%',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Color(0xFF84F41E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      ...metasDoMes.map((meta) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D47A1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  color: Colors.transparent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meta.tituloMeta,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: meta.tag == 'negocio'
                                            ? const Color(0xFF84F41E)
                                            : const Color(0xFF84F41E),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        meta.tag == 'negocio'
                                            ? 'Negócio'
                                            : 'Faculdade',
                                        style: const TextStyle(
                                          color: Color(0xFF0532AF),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color(0xFF84F41E),
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _excluirMeta(meta.id!, meta),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(height: 4),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color(0xFF84F41E),
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _navigateToEditarMeta(meta),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0532AF),
        onPressed: _navigateToCriarMeta,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}
