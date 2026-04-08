import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/ui/tarefas/criar_tarefa_screen.dart';
import 'package:alba/ui/tarefas/editar_tarefa_screen.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/design_system/widgets/tarefa_card.dart';
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
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  String _mesSelecionado = 'Abril';
  
  String _mesDoCalendario = 'Abril'; 
  int _diaSelecionado = DateTime.now().day;   
  int _offsetDias = 0; 
  
  final TarefasRepository _tarefasRepository = TarefasRepository();
  final TextEditingController _buscaController = TextEditingController();

  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // --- FUNÇÕES DE AÇÃO ---

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
              child: Text('Excluir',
                style: TextStyle(color: colors.whiteColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true && tarefa.id != null) {
      try {
        await _tarefasRepository.excluirTarefa(tarefa.id!);
        setState(() {});
        if (!mounted) return;
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
    // Adicione isso para garantir que o fundo do modal acompanhe o design
    backgroundColor: Colors.white, 
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
              title: const Text('Editar', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditarTarefaScreen(tarefa: tarefa)));
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: appColors.primaryColor),
              title: const Text('Excluir', style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _confirmarExclusao(tarefa);
              },
            ),
            // Adiciona um respiro extra no final para não grudar na borda
            const SizedBox(height: 10), 
          ],
        ),
      );
    },
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
          style: TextStyle(color: colors.azulAlba, fontWeight: FontWeight.bold, fontSize: 20),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 18, color: colors.azulAlba),
                    onPressed: () => setState(() => _offsetDias -= 1),
                  ),
                  Text(
                    "$_mesDoCalendario 2026",
                    style: TextStyle(color: colors.azulAlba, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 18, color: colors.azulAlba),
                    onPressed: () => setState(() => _offsetDias += 1),
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
                style: TextStyle(color: colors.azulAlba, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<TarefaDto>>(
                stream: _tarefasRepository.buscarTarefasStream(_busca, mes: null, dia: _diaSelecionado),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tarefas = snapshot.data ?? [];
                  if (tarefas.isEmpty) {
                    return Center(child: Text('Nenhuma tarefa para este dia.', style: TextStyle(color: colors.greyFive)));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tarefas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return TarefaCard(
                        tarefa: tarefas[index],
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditarTarefaScreen(tarefa: tarefas[index])),
                          );
                        },
                        onDelete: () => _confirmarExclusao(tarefas[index]),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Text("Tarefas", style: TextStyle(color: colors.azulAlba, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  _buildFiltroMes(colors),
                ],
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<TarefaDto>>(
                stream: _tarefasRepository.buscarTarefasStream(_busca, mes: _mesSelecionado, dia: null),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final tarefas = snapshot.data!;
                  if (tarefas.isEmpty) {
                    return Center(child: Text("Nenhuma tarefa neste mês.", style: TextStyle(color: colors.greyFive)));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) => _buildTimelineTask(tarefas[index], colors),
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

  // --- WIDGETS AUXILIARES ---

  Widget _buildFiltroMes(AppColors colors) {
    return PopupMenuButton<String>(
      onSelected: (String novoMes) => setState(() => _mesSelecionado = novoMes),
      itemBuilder: (context) => _meses.map((mes) => PopupMenuItem(value: mes, child: Text(mes))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: colors.neonGreen, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Text(_mesSelecionado, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Icon(Icons.keyboard_arrow_down, size: 18, color: colors.azulAlba),
          ],
        ),
      ),
    );
  }

  List<Widget> _gerarCardsCalendario(AppColors colors) {
    List<Widget> cards = [];
    DateTime hoje = DateTime.now().add(Duration(days: _offsetDias));
    List<String> diasSemana = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"];

    for (int i = 0; i < 7; i++) {
      DateTime dataCard = hoje.add(Duration(days: i));
      String diaNome = diasSemana[dataCard.weekday % 7];
      String diaNum = dataCard.day.toString().padLeft(2, '0');
      bool selecionado = _diaSelecionado == dataCard.day;
      cards.add(_buildCardCalendario(diaNome, diaNum, selecionado, colors));
    }
    return cards;
  }

  Widget _buildCardCalendario(String diaSemana, String numero, bool selecionado, AppColors colors) {
    return GestureDetector(
      onTap: () => setState(() => _diaSelecionado = int.parse(numero)),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? colors.neonGreen : colors.whiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selecionado ? colors.neonGreen : colors.greyThree),
        ),
        child: Column(
          children: [
            Text(diaSemana, style: TextStyle(color: selecionado ? colors.whiteColor : colors.greyThree, fontSize: 14)),
            const SizedBox(height: 4),
            Text(numero, style: TextStyle(color: selecionado ? colors.whiteColor : colors.azulAlba, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTask(TarefaDto tarefa, AppColors colors) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Text(tarefa.dataCriacao.day.toString().padLeft(2, '0'),
                  style: TextStyle(color: colors.greyThree, fontWeight: FontWeight.bold, fontSize: 16)),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (v) {},
                    shape: const CircleBorder(),
                    activeColor: colors.neonGreen,
                    side: BorderSide(color: colors.azulAlba, width: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tarefa.tituloTarefa, style: TextStyle(fontWeight: FontWeight.bold, color: colors.azulAlba, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text("Meta: ${tarefa.tituloMeta ?? 'Sem Meta'}",
                            style: TextStyle(fontSize: 12, color: colors.azulAlba.withOpacity(0.7))),
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