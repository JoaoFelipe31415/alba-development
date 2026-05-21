import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/domain/entities/recorrencia.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/tarefas/criar_tarefa_screen.dart';
import 'package:alba/ui/tarefas/editar_tarefa_screen.dart';
import 'package:flutter/material.dart';

class GerenciamentoTarefasScreen extends StatefulWidget {
  const GerenciamentoTarefasScreen({super.key});

  @override
  State<GerenciamentoTarefasScreen> createState() =>
      _GerenciamentoTarefasScreenState();
}

class _GerenciamentoTarefasScreenState
    extends State<GerenciamentoTarefasScreen> {
  final List<String> _meses = [
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

  final TarefasRepository _tarefasRepository = TarefasRepository();
  final TextEditingController _buscaController = TextEditingController();

  String _mesSelecionado = 'Abril';
  String _mesDoCalendario = 'Abril';
  String _busca = '';

  int _offsetDias = 0;

  DateTime _dataSelecionada = DateTime.now();

  final Map<String, bool> _statusLocalConcluido = {};

  @override
  void initState() {
    super.initState();

    _mesDoCalendario = _meses[_dataSelecionada.month - 1];
    _mesSelecionado = _meses[_dataSelecionada.month - 1];
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  DateTime _apenasData(DateTime data) {
    final local = data.toLocal();

    return DateTime(
      local.year,
      local.month,
      local.day,
    );
  }

  bool _mesmoDia(DateTime a, DateTime b) {
    final dataA = _apenasData(a);
    final dataB = _apenasData(b);

    return dataA.year == dataB.year &&
        dataA.month == dataB.month &&
        dataA.day == dataB.day;
  }

  String _nomeDiaInterno(DateTime data) {
    switch (data.weekday) {
      case DateTime.monday:
        return 'segunda';
      case DateTime.tuesday:
        return 'terca';
      case DateTime.wednesday:
        return 'quarta';
      case DateTime.thursday:
        return 'quinta';
      case DateTime.friday:
        return 'sexta';
      case DateTime.saturday:
        return 'sabado';
      case DateTime.sunday:
        return 'domingo';
      default:
        return '';
    }
  }

  List<String> _diasDaTarefa(TarefaDto tarefa) {
    final diasConfig = tarefa.configuracaoRecorrencia?.diasSemana;

    if (tarefa.tipoRecorrencia == TipoRecorrencia.personalizado &&
        diasConfig != null &&
        diasConfig.isNotEmpty) {
      return diasConfig
          .map((dia) => dia.toLowerCase().trim())
          .where((dia) => dia.isNotEmpty)
          .toList();
    }

    return tarefa.diasRealizacao
        .map((dia) => dia.toLowerCase().trim())
        .where((dia) => dia.isNotEmpty)
        .toList();
  }

  bool _tarefaAconteceNoDia(TarefaDto tarefa, DateTime data) {
    final dataSelecionadaLimpa = _apenasData(data);
    final dataInicio = _apenasData(tarefa.dataInicial ?? tarefa.dataCriacao);

    if (dataSelecionadaLimpa.isBefore(dataInicio)) {
      return false;
    }

    final diaSemanaSelecionado = _nomeDiaInterno(dataSelecionadaLimpa);
    final dias = _diasDaTarefa(tarefa);

    switch (tarefa.tipoRecorrencia) {
      case TipoRecorrencia.naoRepete:
        return _mesmoDia(dataInicio, dataSelecionadaLimpa);

      case TipoRecorrencia.diaria:
        return true;

      case TipoRecorrencia.segAVinco:
        return dataSelecionadaLimpa.weekday >= DateTime.monday &&
            dataSelecionadaLimpa.weekday <= DateTime.friday;

      case TipoRecorrencia.semanal:
        if (dias.isNotEmpty) {
          return dias.contains(diaSemanaSelecionado);
        }

        return dataSelecionadaLimpa.weekday == dataInicio.weekday;

      case TipoRecorrencia.mensal:
        return dataSelecionadaLimpa.day == dataInicio.day;

      case TipoRecorrencia.anual:
        return dataSelecionadaLimpa.day == dataInicio.day &&
            dataSelecionadaLimpa.month == dataInicio.month;

      case TipoRecorrencia.personalizado:
        return dias.contains(diaSemanaSelecionado);
    }
  }

  bool _tarefaAconteceNoMes(TarefaDto tarefa, int mes, int ano) {
    final primeiroDiaMes = DateTime(ano, mes, 1);
    final ultimoDiaMes = DateTime(ano, mes + 1, 0);

    final dataInicio = _apenasData(tarefa.dataInicial ?? tarefa.dataCriacao);

    if (ultimoDiaMes.isBefore(dataInicio)) {
      return false;
    }

    if (tarefa.tipoRecorrencia == TipoRecorrencia.naoRepete) {
      return dataInicio.month == mes && dataInicio.year == ano;
    }

    var dataAtual = primeiroDiaMes;

    while (!dataAtual.isAfter(ultimoDiaMes)) {
      if (_tarefaAconteceNoDia(tarefa, dataAtual)) {
        return true;
      }

      dataAtual = dataAtual.add(const Duration(days: 1));
    }

    return false;
  }

  List<TarefaDto> _filtrarTarefasDoDiaSelecionado(List<TarefaDto> tarefas) {
    return tarefas.where((tarefa) {
      final naoConcluida = !_estaConcluidaLocal(tarefa);

      if (!naoConcluida) {
        return false;
      }

      return _tarefaAconteceNoDia(tarefa, _dataSelecionada);
    }).toList();
  }

  List<TarefaDto> _filtrarTarefasDoMesSelecionado(List<TarefaDto> tarefas) {
    final mes = _meses.indexOf(_mesSelecionado) + 1;
    final ano = DateTime.now().year;

    final filtradas = tarefas.where((tarefa) {
      return _tarefaAconteceNoMes(tarefa, mes, ano);
    }).toList();

    filtradas.sort((a, b) {
      final dataA = a.dataInicial ?? a.dataCriacao;
      final dataB = b.dataInicial ?? b.dataCriacao;

      return dataA.compareTo(dataB);
    });

    return filtradas;
  }

  bool _estaConcluidaLocal(TarefaDto tarefa) {
    if (tarefa.id == null) {
      return tarefa.status.toLowerCase() == 'concluida';
    }

    return _statusLocalConcluido[tarefa.id!] ??
        (tarefa.status.toLowerCase() == 'concluida');
  }

  void _toggleStatusLocal(TarefaDto tarefa) {
    if (tarefa.id == null) return;

    setState(() {
      final statusAtual = _estaConcluidaLocal(tarefa);
      _statusLocalConcluido[tarefa.id!] = !statusAtual;
    });
  }

  Future<void> _toggleStatusTarefa(TarefaDto tarefa) async {
    if (tarefa.id == null) return;

    final estaConcluida = _estaConcluidaLocal(tarefa);
    final novoStatus = estaConcluida ? 'pendente' : 'concluida';

    _toggleStatusLocal(tarefa);

    try {
      await _tarefasRepository.atualizarStatus(tarefa.id!, novoStatus);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarefa marcada como $novoStatus!'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      _toggleStatusLocal(tarefa);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar no banco de dados.'),
        ),
      );
    }
  }

  Future<void> _confirmarExclusao(TarefaDto tarefa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).extension<AppColors>()!;

        return AlertDialog(
          title: const Text('Tem certeza?'),
          content: const Text('Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryColor,
                elevation: 0,
              ),
              child: Text(
                'Excluir',
                style: TextStyle(
                  color: colors.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true || tarefa.id == null) {
      return;
    }

    try {
      await _tarefasRepository.excluirTarefa(tarefa.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa excluída com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _mostrarOpcoesTarefa(TarefaDto tarefa) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        final appColors = Theme.of(context).extension<AppColors>()!;

        return SafeArea(
          child: Wrap(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 5,
                  ),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.edit,
                  color: appColors.azulAlba,
                ),
                title: const Text(
                  'Editar',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditarTarefaScreen(tarefa: tarefa),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: appColors.primaryColor,
                ),
                title: const Text(
                  'Excluir',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarExclusao(tarefa);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  String _formatarTag(String? tag) {
    if (tag == null || tag.isEmpty) return '';

    final normalized = tag.toLowerCase();

    if (normalized == 'negocio') return 'Negócio';
    if (normalized == 'faculdade') return 'Faculdade';

    return tag[0].toUpperCase() + tag.substring(1);
  }

  Color _corTag(String? tag, AppColors colors) {
    if (tag == null || tag.isEmpty) {
      return colors.greyThree;
    }

    return tag.toLowerCase() == 'negocio'
        ? colors.neonGreen
        : colors.primaryColor;
  }

  String _formatarHorario(TarefaDto tarefa) {
    final inicio = tarefa.horarioInicio ?? tarefa.horario;
    final fim = tarefa.horarioFim;

    if (inicio == null || inicio.trim().isEmpty) {
      return '';
    }

    if (fim == null || fim.trim().isEmpty) {
      return inicio;
    }

    return '$inicio - $fim';
  }

  String _formatarRecorrencia(TarefaDto tarefa) {
    switch (tarefa.tipoRecorrencia) {
      case TipoRecorrencia.naoRepete:
        return 'Não repete';

      case TipoRecorrencia.diaria:
        return 'Diária';

      case TipoRecorrencia.segAVinco:
        return 'Seg à Sex';

      case TipoRecorrencia.semanal:
        final dias = _diasDaTarefa(tarefa);

        if (dias.isNotEmpty) {
          return 'Semanal: ${_formatarDiasTexto(dias)}';
        }

        return 'Semanal';

      case TipoRecorrencia.mensal:
        return 'Mensal';

      case TipoRecorrencia.anual:
        return 'Anual';

      case TipoRecorrencia.personalizado:
        final dias = _diasDaTarefa(tarefa);

        if (dias.isEmpty) {
          return 'Personalizado';
        }

        return _formatarDiasTexto(dias);
    }
  }

  String _formatarDiasTexto(List<String> dias) {
    final mapa = {
      'segunda': 'Seg',
      'terca': 'Ter',
      'quarta': 'Qua',
      'quinta': 'Qui',
      'sexta': 'Sex',
      'sabado': 'Sáb',
      'domingo': 'Dom',
    };

    return dias.map((dia) => mapa[dia] ?? dia).join(', ');
  }

  bool _shouldShowDias(TipoRecorrencia tipoRecorrencia) {
    switch (tipoRecorrencia) {
      case TipoRecorrencia.diaria:
      case TipoRecorrencia.segAVinco:
      case TipoRecorrencia.semanal:
      case TipoRecorrencia.personalizado:
        return true;

      case TipoRecorrencia.naoRepete:
      case TipoRecorrencia.mensal:
      case TipoRecorrencia.anual:
        return false;
    }
  }

  Widget _buildDiaBolinha(
    String letra,
    String dia,
    TarefaDto tarefa,
    AppColors colors,
  ) {
    final selecionado = _diasDaTarefa(tarefa).contains(dia.toLowerCase());

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selecionado ? colors.neonGreen : colors.whiteColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.neonGreen,
          width: 2,
        ),
      ),
      child: Text(
        letra,
        style: TextStyle(
          color: selecionado ? colors.whiteColor : colors.azulAlba,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHojeCard(TarefaDto tarefa, AppColors colors) {
    final concluida = _estaConcluidaLocal(tarefa);
    final horario = _formatarHorario(tarefa);
    final recorrencia = _formatarRecorrencia(tarefa);

    return Container(
      decoration: BoxDecoration(
        color: colors.azulAlba,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _toggleStatusTarefa(tarefa),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.neonGreen,
                      width: 2,
                    ),
                  ),
                  child: concluida
                      ? Icon(
                          Icons.check,
                          color: colors.neonGreen,
                          size: 18,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tarefa.tituloTarefa,
                  style: TextStyle(
                    color: colors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: concluida
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: colors.whiteColor,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: colors.neonGreen,
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditarTarefaScreen(tarefa: tarefa),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: colors.neonGreen,
                ),
                onPressed: () => _confirmarExclusao(tarefa),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (tarefa.tag != null && tarefa.tag!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _corTag(tarefa.tag, colors),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatarTag(tarefa.tag),
                    style: TextStyle(
                      color: tarefa.tag!.toLowerCase() == 'negocio'
                          ? colors.backgroundColor
                          : colors.whiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (horario.isNotEmpty)
                _buildInfoChip(
                  icon: Icons.access_time_rounded,
                  label: horario,
                  backgroundColor: colors.whiteColor.withOpacity(0.12),
                  textColor: colors.whiteColor,
                ),
              _buildInfoChip(
                icon: Icons.repeat_rounded,
                label: recorrencia,
                backgroundColor: colors.whiteColor.withOpacity(0.12),
                textColor: colors.whiteColor,
              ),
            ],
          ),
          if (tarefa.tituloMeta != null && tarefa.tituloMeta!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Meta: ${tarefa.tituloMeta}',
              style: TextStyle(
                color: colors.whiteColor.withOpacity(0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (_shouldShowDias(tarefa.tipoRecorrencia)) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDiaBolinha('S', 'segunda', tarefa, colors),
                _buildDiaBolinha('T', 'terca', tarefa, colors),
                _buildDiaBolinha('Q', 'quarta', tarefa, colors),
                _buildDiaBolinha('Q', 'quinta', tarefa, colors),
                _buildDiaBolinha('S', 'sexta', tarefa, colors),
                _buildDiaBolinha('S', 'sabado', tarefa, colors),
                _buildDiaBolinha('D', 'domingo', tarefa, colors),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErroStream(AppColors colors) {
    return Center(
      child: Text(
        'Não foi possível atualizar suas tarefas.',
        style: TextStyle(color: colors.greyFive),
      ),
    );
  }

  Widget _buildSemConexaoOuVazio(String texto, AppColors colors) {
    return Center(
      child: Text(
        texto,
        style: TextStyle(color: colors.greyFive),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        backgroundColor: colors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colors.azulAlba,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gerenciamento de Tarefas',
          style: TextStyle(
            color: colors.azulAlba,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.azulAlba,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CriarTarefaScreen(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: colors.whiteColor,
        ),
      ),
      body: StreamBuilder<List<TarefaDto>>(
        stream: _tarefasRepository.buscarTarefasStream(
          _busca,
          mes: null,
          dia: null,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErroStream(colors);
          }

          final tarefas = snapshot.data ?? [];

          final tarefasDoDia = _filtrarTarefasDoDiaSelecionado(tarefas);
          final tarefasDoMes = _filtrarTarefasDoMesSelecionado(tarefas);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _buscaController,
                    onChanged: (value) {
                      setState(() {
                        _busca = value.trim();
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar tarefas...',
                      suffixIcon: _busca.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _buscaController.clear();

                                setState(() {
                                  _busca = '';
                                });
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: colors.azulAlba,
                        ),
                        onPressed: () {
                          setState(() {
                            _offsetDias -= 1;

                            final base = DateTime.now().add(
                              Duration(days: _offsetDias),
                            );

                            _mesDoCalendario = _meses[base.month - 1];
                          });
                        },
                      ),
                      Text(
                        "$_mesDoCalendario ${DateTime.now().add(Duration(days: _offsetDias)).year}",
                        style: TextStyle(
                          color: colors.azulAlba,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: colors.azulAlba,
                        ),
                        onPressed: () {
                          setState(() {
                            _offsetDias += 1;

                            final base = DateTime.now().add(
                              Duration(days: _offsetDias),
                            );

                            _mesDoCalendario = _meses[base.month - 1];
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _gerarCardsCalendario(colors),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Tarefas do dia",
                    style: TextStyle(
                      color: colors.azulAlba,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (tarefasDoDia.isEmpty)
                    _buildSemConexaoOuVazio(
                      'Nenhuma tarefa para este dia.',
                      colors,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tarefasDoDia.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _buildHojeCard(
                          tarefasDoDia[index],
                          colors,
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Text(
                        "Tarefas",
                        style: TextStyle(
                          color: colors.azulAlba,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      _buildFiltroMes(colors),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (tarefasDoMes.isEmpty)
                    _buildSemConexaoOuVazio(
                      "Nenhuma tarefa neste mês.",
                      colors,
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tarefasDoMes.length,
                      itemBuilder: (context, index) {
                        return _buildTimelineTask(
                          tarefasDoMes[index],
                          colors,
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
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
        return _meses
            .map(
              (mes) => PopupMenuItem(
                value: mes,
                child: Text(mes),
              ),
            )
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: colors.neonGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              _mesSelecionado,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: colors.azulAlba,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _gerarCardsCalendario(AppColors colors) {
    final cards = <Widget>[];

    final base = DateTime.now().add(
      Duration(days: _offsetDias),
    );

    final diasSemana = [
      "Dom",
      "Seg",
      "Ter",
      "Qua",
      "Qui",
      "Sex",
      "Sab",
    ];

    for (int i = 0; i < 7; i++) {
      final dataCard = base.add(Duration(days: i));
      final diaNome = diasSemana[dataCard.weekday % 7];
      final diaNum = dataCard.day.toString().padLeft(2, '0');
      final selecionado = _mesmoDia(_dataSelecionada, dataCard);

      cards.add(
        _buildCardCalendario(
          diaNome,
          diaNum,
          selecionado,
          colors,
          dataCard,
        ),
      );
    }

    return cards;
  }

  Widget _buildCardCalendario(
    String diaSemana,
    String numero,
    bool selecionado,
    AppColors colors,
    DateTime dataCompleta,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _dataSelecionada = dataCompleta;
          _mesDoCalendario = _meses[dataCompleta.month - 1];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selecionado ? colors.neonGreen : colors.whiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selecionado ? colors.neonGreen : colors.greyThree,
          ),
        ),
        child: Column(
          children: [
            Text(
              diaSemana,
              style: TextStyle(
                color: selecionado ? colors.whiteColor : colors.greyThree,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              numero,
              style: TextStyle(
                color: selecionado ? colors.whiteColor : colors.azulAlba,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTask(TarefaDto tarefa, AppColors colors) {
    final concluida = _estaConcluidaLocal(tarefa);
    final dataExibicao = tarefa.dataInicial ?? tarefa.dataCriacao;
    final horario = _formatarHorario(tarefa);
    final recorrencia = _formatarRecorrencia(tarefa);

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Text(
                dataExibicao.day.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: colors.greyThree,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Container(
                  width: 2,
                  color: colors.greyThree,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: concluida,
                    onChanged: (_) => _toggleStatusTarefa(tarefa),
                    shape: const CircleBorder(),
                    activeColor: colors.neonGreen,
                    side: BorderSide(
                      color: colors.azulAlba,
                      width: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tarefa.tituloTarefa,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colors.azulAlba,
                            fontSize: 15,
                            decoration: concluida
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Meta: ${tarefa.tituloMeta ?? 'Sem Meta'}",
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.azulAlba.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (horario.isNotEmpty)
                              _buildInfoChip(
                                icon: Icons.access_time_rounded,
                                label: horario,
                                backgroundColor:
                                    colors.azulAlba.withOpacity(0.08),
                                textColor: colors.azulAlba,
                              ),
                            _buildInfoChip(
                              icon: Icons.repeat_rounded,
                              label: recorrencia,
                              backgroundColor:
                                  colors.azulAlba.withOpacity(0.08),
                              textColor: colors.azulAlba,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: colors.azulAlba,
                    ),
                    onPressed: () => _mostrarOpcoesTarefa(tarefa),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}