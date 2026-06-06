import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/metas/criar_meta_screen.dart';
import 'package:alba/ui/metas/editar_meta_screen.dart';
import 'package:flutter/material.dart';

const Color albaLightBlue = Color(0xFF7FE2E1);

class GeraciamentoMetasScreen extends StatefulWidget {
  const GeraciamentoMetasScreen({super.key});

  @override
  State<GeraciamentoMetasScreen> createState() =>
      _GeraciamentoMetasScreenState();
}

class _GeraciamentoMetasScreenState extends State<GeraciamentoMetasScreen> {
  final metasRepository = injector.get<MetasRepository>();
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';
  String _mesSelecionado = 'Todas';
  int _anoSelecionado = DateTime.now().year;

  static const List<String> _meses = [
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

  int _getMesNumero(String mes) {
    return _meses.indexOf(mes) + 1;
  }

  List<int> _getAnosDisponiveis(List<MetaDto> metas) {
    final anos = metas.map((meta) => meta.prazo.year).toSet();

    anos.add(DateTime.now().year);

    final lista = anos.toList();
    lista.sort((a, b) => b.compareTo(a));

    return lista;
  }

  List<MetaDto> _filtrarMetasPorBusca(List<MetaDto> metas) {
    final termo = searchQuery.trim().toLowerCase();

    if (termo.isEmpty) {
      return metas;
    }

    return metas.where((meta) {
      final titulo = meta.tituloMeta.toLowerCase();
      final descricao = (meta.descricao ?? '').toLowerCase();
      final tag = meta.tag.toLowerCase();

      return titulo.contains(termo) ||
          descricao.contains(termo) ||
          tag.contains(termo);
    }).toList();
  }

  List<MetaDto> _filtrarMetasPorPeriodo(List<MetaDto> metas) {
    final metasDoAno = metas.where((meta) {
      return meta.prazo.year == _anoSelecionado;
    }).toList();

    if (_mesSelecionado == 'Todas') {
      return metasDoAno;
    }

    return metasDoAno.where((meta) {
      return meta.prazo.month == _getMesNumero(_mesSelecionado) &&
          meta.prazo.year == _anoSelecionado;
    }).toList();
  }

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatarPeriodo() {
    if (_mesSelecionado == 'Todas') {
      return '$_anoSelecionado';
    }

    return '$_mesSelecionado de $_anoSelecionado';
  }

  String _tagLabel(String tag) {
    switch (tag) {
      case 'negocio':
        return 'Negócio';
      case 'faculdade':
        return 'Faculdade';
      default:
        return tag.trim().isEmpty ? 'Sem tag' : tag;
    }
  }

  Color _tagBackgroundColor(BuildContext context, String tag) {
    final colors = context.colors;

    switch (tag) {
      case 'negocio':
        return colors.neonGreen;
      case 'faculdade':
        return colors.primaryColor;
      default:
        return colors.inputColor;
    }
  }

  Color _tagTextColor(BuildContext context, String tag) {
    final colors = context.colors;

    switch (tag) {
      case 'negocio':
        return colors.azulAlba;
      case 'faculdade':
        return colors.whiteColor;
      default:
        return colors.azulAlba;
    }
  }

  Future<void> _alternarConclusaoMeta(MetaDto meta) async {
    final metaId = meta.id;

    if (metaId == null || metaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não foi possível atualizar esta meta.'),
          backgroundColor: context.colors.errorColor,
        ),
      );
      return;
    }

    final novoStatus = !meta.concluida;

    try {
      await metasRepository.atualizarConclusaoMeta(
        metaId: metaId,
        concluida: novoStatus,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: context.colors.errorColor,
        ),
      );
    }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Excluir meta?',
          style: TextStyle(
            color: context.colors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'A meta "${meta.tituloMeta}" será excluída. Esta ação não pode ser desfeita.',
          style: TextStyle(color: context.colors.textPrimaryColor),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    SnackBar(
                      content: const Text('Meta excluída com sucesso!'),
                      backgroundColor: context.colors.successColor,
                    ),
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        backgroundColor: colors.whiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Gerenciamento de Metas',
          style: TextStyle(
            color: colors.azulAlba,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<List<MetaDto>>(
        stream: metasRepository.obterMetasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Não foi possível atualizar suas metas.',
                style: TextStyle(color: colors.greyFive),
              ),
            );
          }

          final todasMetas = snapshot.data ?? [];
          final anosDisponiveis = _getAnosDisponiveis(todasMetas);

          if (!anosDisponiveis.contains(_anoSelecionado)) {
            _anoSelecionado = anosDisponiveis.first;
          }

          final metasBuscadas = _filtrarMetasPorBusca(todasMetas);
          final metasFiltradas = _filtrarMetasPorPeriodo(metasBuscadas);

          final totalPeriodo = metasFiltradas.length;
          final totalConcluidas =
              metasFiltradas.where((meta) => meta.concluida).length;

          final porcentagem = totalPeriodo == 0
              ? 0.0
              : (totalConcluidas / totalPeriodo).clamp(0.0, 1.0);

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: colors.greyFive,
                      ),
                      hintText: 'Buscar metas...',
                      hintStyle: TextStyle(
                        color: colors.greyFive,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      suffixIcon: searchQuery.trim().isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                searchController.clear();

                                setState(() {
                                  searchQuery = '';
                                });
                              },
                              icon: Icon(
                                Icons.clear,
                                color: colors.greyFive,
                              ),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: colors.greyThree,
                          width: 1.4,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: colors.greyThree,
                          width: 1.4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: albaLightBlue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Metas',
                        style: TextStyle(
                          color: colors.azulAlba,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      _buildFiltroMes(colors),
                      const SizedBox(width: 8),
                      _buildFiltroAno(colors, anosDisponiveis),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (todasMetas.isEmpty)
                    _buildSemConexaoOuVazio(
                      'Nenhuma meta encontrada.',
                      colors,
                    )
                  else if (metasFiltradas.isEmpty)
                    _buildSemConexaoOuVazio(
                      searchQuery.trim().isEmpty
                          ? 'Nenhuma meta em ${_formatarPeriodo()}.'
                          : 'Nenhuma meta encontrada.',
                      colors,
                    )
                  else ...[
                    _SummaryCard(
                      totalPeriodo: totalPeriodo,
                      totalConcluidas: totalConcluidas,
                      periodo: _formatarPeriodo(),
                      porcentagem: porcentagem,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      '$totalPeriodo ${totalPeriodo == 1 ? 'meta encontrada' : 'metas encontradas'}',
                      style: TextStyle(
                        color: colors.azulAlba,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...metasFiltradas.map((meta) {
                      return _MetaCard(
                        meta: meta,
                        tagLabel: _tagLabel(meta.tag),
                        tagBackgroundColor:
                            _tagBackgroundColor(context, meta.tag),
                        tagTextColor: _tagTextColor(context, meta.tag),
                        dataFormatada: _formatarData(meta.prazo),
                        onToggleComplete: () => _alternarConclusaoMeta(meta),
                        onEdit: () => _navigateToEditarMeta(meta),
                        onDelete: () {
                          final metaId = meta.id;

                          if (metaId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Não foi possível excluir esta meta.',
                                ),
                                backgroundColor: colors.errorColor,
                              ),
                            );
                            return;
                          }

                          _excluirMeta(metaId, meta);
                        },
                      );
                    }),
                  ],
                  const SizedBox(height: 90),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.azulAlba,
        onPressed: _navigateToCriarMeta,
        child: Icon(Icons.add, color: colors.whiteColor),
      ),
    );
  }

  Widget _buildFiltroMes(AppColors colors) {
    return PopupMenuButton<String>(
      onSelected: (String novoMes) {
        setState(() {
          _mesSelecionado = novoMes;
        });
      },
      itemBuilder: (context) {
        return ['Todas', ..._meses]
            .map((mes) => PopupMenuItem(value: mes, child: Text(mes)))
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.neonGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              _mesSelecionado,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: colors.azulAlba),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroAno(AppColors colors, List<int> anosDisponiveis) {
    return PopupMenuButton<int>(
      onSelected: (int novoAno) {
        setState(() {
          _anoSelecionado = novoAno;
        });
      },
      itemBuilder: (context) {
        return anosDisponiveis
            .map((ano) => PopupMenuItem(value: ano, child: Text('$ano')))
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.neonGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              '$_anoSelecionado',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: colors.azulAlba),
          ],
        ),
      ),
    );
  }

  Widget _buildSemConexaoOuVazio(String texto, AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.greyFive),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int totalPeriodo;
  final int totalConcluidas;
  final String periodo;
  final double porcentagem;

  const _SummaryCard({
    required this.totalPeriodo,
    required this.totalConcluidas,
    required this.periodo,
    required this.porcentagem,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final percentualTexto = (porcentagem * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.azulAlba,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.azulAlba.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.neonGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: colors.azulAlba,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '$totalConcluidas de $totalPeriodo ${totalPeriodo == 1 ? 'meta concluída' : 'metas concluídas'}',
                  style: TextStyle(
                    color: colors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Período: $periodo',
            style: TextStyle(
              color: colors.whiteColor.withOpacity(0.82),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '$totalConcluidas concluídas',
                style: TextStyle(
                  color: colors.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '$percentualTexto%',
                style: TextStyle(
                  color: colors.neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: porcentagem,
              minHeight: 8,
              backgroundColor: colors.whiteColor.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation<Color>(colors.neonGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final MetaDto meta;
  final String tagLabel;
  final Color tagBackgroundColor;
  final Color tagTextColor;
  final String dataFormatada;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MetaCard({
    required this.meta,
    required this.tagLabel,
    required this.tagBackgroundColor,
    required this.tagTextColor,
    required this.dataFormatada,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final descricao = meta.descricao?.trim();
    final isConcluida = meta.concluida;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isConcluida ? 0.78 : 1,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.azulAlba,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colors.blackColor.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onToggleComplete,
              borderRadius: BorderRadius.circular(99),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConcluida ? colors.neonGreen : Colors.transparent,
                  border: Border.all(
                    color: colors.neonGreen,
                    width: 2.5,
                  ),
                ),
                child: isConcluida
                    ? Icon(
                        Icons.check_rounded,
                        color: colors.azulAlba,
                        size: 23,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.tituloMeta,
                    style: TextStyle(
                      color: colors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      height: 1.2,
                      decoration: isConcluida
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: colors.whiteColor,
                      decorationThickness: 2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (descricao != null && descricao.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      descricao,
                      style: TextStyle(
                        color: colors.whiteColor.withOpacity(0.78),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        height: 1.25,
                        decoration: isConcluida
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: colors.whiteColor.withOpacity(0.78),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ChipInfo(
                        label: tagLabel,
                        icon: Icons.sell_rounded,
                        backgroundColor: tagBackgroundColor,
                        textColor: tagTextColor,
                        iconColor: tagTextColor,
                      ),
                      _ChipInfo(
                        label: dataFormatada,
                        icon: Icons.calendar_today_rounded,
                        backgroundColor: colors.whiteColor.withOpacity(0.14),
                        textColor: colors.whiteColor,
                        iconColor: colors.whiteColor,
                      ),
                      if (isConcluida)
                        _ChipInfo(
                          label: 'Concluída',
                          icon: Icons.check_circle_rounded,
                          backgroundColor: colors.neonGreen,
                          textColor: colors.azulAlba,
                          iconColor: colors.azulAlba,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_rounded,
                    color: colors.neonGreen,
                    size: 24,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_rounded,
                    color: colors.neonGreen,
                    size: 24,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const _ChipInfo({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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