import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/ui/tarefas/criar_tarefa_screen.dart';
import 'package:alba/ui/tarefas/editar_tarefa_screen.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
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

  String _mesSelecionado = 'Abril';
  String _mesDoCalendario = 'Abril';
  int _offsetDias = 0;

  final TarefasRepository _tarefasRepository = TarefasRepository();
  final TextEditingController _buscaController = TextEditingController();

  String _busca = '';
  DateTime _dataSelecionada = DateTime.now();

  // CHECK SOMENTE NO FRONT
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

    if (confirmar == true && tarefa.id != null) {
      try {
        await _tarefasRepository.excluirTarefa(tarefa.id!);
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa excluída com sucesso.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _mostrarOpcoesTarefa(TarefaDto tarefa) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final appColors = Theme.of(context).extension<AppColors>()!;

        return SafeArea(
          child: Wrap(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 5),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit, color: appColors.azulAlba),
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
                leading: Icon(Icons.delete, color: appColors.primaryColor),
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

  bool _estaConcluidaLocal(TarefaDto tarefa) {
    if (tarefa.id == null) return tarefa.status.toLowerCase() == 'concluida';

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

    // 1. Definimos o novo status baseado no estado atual
    final estaConcluida = _estaConcluidaLocal(tarefa);
    final novoStatus = estaConcluida ? 'pendente' : 'concluida';

    // 2. Atualizamos o visual imediatamente (feedback rápido para o usuário)
    _toggleStatusLocal(tarefa);

    try {
      // 3. Enviamos para o Firebase
      await _tarefasRepository.atualizarStatus(tarefa.id!, novoStatus);

      // Opcional: mostrar um feedback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarefa marcada como $novoStatus!'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Se der erro no banco, voltamos o visual para o estado anterior
      _toggleStatusLocal(tarefa);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar no banco de dados.')),
      );
    }
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

  List<TarefaDto> _filtrarTarefasDoDiaSelecionado(List<TarefaDto> tarefas) {
    final diaSemanaSelecionado = _nomeDiaInterno(_dataSelecionada);

    return tarefas.where((tarefa) {
      final naoConcluida = !_estaConcluidaLocal(tarefa);
      if (!naoConcluida) return false;

      final tipo = tarefa.tipoRecorrencia.toLowerCase() ?? 'não repete';

      // 1. Se for uma tarefa comum (Não Repete)
      if (tipo == 'não repete') {
        // Se não tiver data inicial por algum motivo, usa a de criação, evitando o crash
        final dataParaComparar = tarefa.dataInicial ?? tarefa.dataCriacao;
        return _mesmoDia(dataParaComparar, _dataSelecionada);
      }

      // 2. Se for uma tarefa Mensal
      if (tipo == 'mensal') {
        // Se a tarefa mensal antiga não tiver data inicial, ignora para não quebrar a tela
        if (tarefa.dataInicial == null) return false;
        return _mesmoDia(tarefa.dataInicial!, _dataSelecionada);
      }

      // 3. Para as tarefas Diárias e Semanais antigas (que não usam data exata)
      final bateDiaSemana = tarefa.diasRealizacao
          .map((d) => d.toLowerCase())
          .contains(diaSemanaSelecionado);

      return bateDiaSemana;
    }).toList();
  }

  bool _mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatarTag(String? tag) {
    if (tag == null || tag.isEmpty) return '';
    final normalized = tag.toLowerCase();
    if (normalized == 'negocio') return 'Negócio';
    if (normalized == 'faculdade') return 'Faculdade';
    return tag[0].toUpperCase() + tag.substring(1);
  }

  Color _corTag(String? tag, AppColors colors) {
    if (tag == null || tag.isEmpty) return colors.greyThree;
    return tag.toLowerCase() == 'negocio'
        ? colors.neonGreen
        : colors.primaryColor;
  }

  Widget _buildDiaBolinha(
    String letra,
    String dia,
    TarefaDto tarefa,
    AppColors colors,
  ) {
    final selecionado = tarefa.diasRealizacao
        .map((d) => d.toLowerCase())
        .contains(dia.toLowerCase());

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selecionado ? colors.neonGreen : colors.whiteColor,
        shape: BoxShape.circle,
        border: Border.all(color: colors.neonGreen, width: 2),
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
                    border: Border.all(color: colors.neonGreen, width: 2),
                  ),
                  child: concluida
                      ? Icon(Icons.check, color: colors.neonGreen, size: 18)
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
                icon: Icon(Icons.edit, color: colors.neonGreen),
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
                icon: Icon(Icons.delete, color: colors.neonGreen),
                onPressed: () => _confirmarExclusao(tarefa),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (tarefa.tag != null && tarefa.tag!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          icon: Icon(Icons.arrow_back_ios, color: colors.azulAlba, size: 20),
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
            MaterialPageRoute(builder: (_) => const CriarTarefaScreen()),
          );
        },
        child: Icon(Icons.add, color: colors.whiteColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _buscaController,
                onChanged: (value) => setState(() => _busca = value.trim()),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar tarefas...',
                  suffixIcon: _busca.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _buscaController.clear();
                            setState(() => _busca = '');
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
                child: Row(children: _gerarCardsCalendario(colors)),
              ),
              const SizedBox(height: 32),
              Text(
                "Hoje",
                style: TextStyle(
                  color: colors.azulAlba,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<TarefaDto>>(
                stream: _tarefasRepository.buscarTarefasStream(
                  _busca,
                  mes: null,
                  dia: null,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tarefas = snapshot.data ?? [];
                  final tarefasDoDia = _filtrarTarefasDoDiaSelecionado(tarefas);

                  if (tarefasDoDia.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhuma tarefa para este dia.',
                        style: TextStyle(color: colors.greyFive),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tarefasDoDia.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _buildHojeCard(tarefasDoDia[index], colors);
                    },
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
              StreamBuilder<List<TarefaDto>>(
                stream: _tarefasRepository.buscarTarefasStream(
                  _busca,
                  mes: _mesSelecionado,
                  dia: null,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final tarefas = snapshot.data!;
                  if (tarefas.isEmpty) {
                    return Center(
                      child: Text(
                        "Nenhuma tarefa neste mês.",
                        style: TextStyle(color: colors.greyFive),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) =>
                        _buildTimelineTask(tarefas[index], colors),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroMes(AppColors colors) {
    return PopupMenuButton<String>(
      onSelected: (String novoMes) => setState(() => _mesSelecionado = novoMes),
      itemBuilder: (context) => _meses
          .map((mes) => PopupMenuItem(value: mes, child: Text(mes)))
          .toList(),
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

  List<Widget> _gerarCardsCalendario(AppColors colors) {
    List<Widget> cards = [];
    DateTime base = DateTime.now().add(Duration(days: _offsetDias));
    List<String> diasSemana = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"];

    for (int i = 0; i < 7; i++) {
      DateTime dataCard = base.add(Duration(days: i));
      String diaNome = diasSemana[dataCard.weekday % 7];
      String diaNum = dataCard.day.toString().padLeft(2, '0');
      bool selecionado = _mesmoDia(_dataSelecionada, dataCard);

      cards.add(
        _buildCardCalendario(diaNome, diaNum, selecionado, colors, dataCard),
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
      onTap: () => setState(() {
        _dataSelecionada = dataCompleta;
        _mesDoCalendario = _meses[dataCompleta.month - 1];
      }),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Text(
                tarefa.dataCriacao.day.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: colors.greyThree,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(child: Container(width: 2, color: colors.greyThree)),
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
                    side: BorderSide(color: colors.azulAlba, width: 2),
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
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: colors.azulAlba),
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
