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
  int _diaSelecionado = 2;    
  final TarefasRepository _tarefasRepository = TarefasRepository();
  final TextEditingController _buscaController = TextEditingController();

  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }
  Widget _buildSecaoTitulo(String titulo, {Widget? extra}) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: colors.primaryColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (extra != null) ...[const SizedBox(width: 10), extra],
        ],
      ),
    );
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
              style: ElevatedButton.styleFrom(backgroundColor:colors.primaryColor),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && tarefa.id != null) {
      try {
        await _tarefasRepository.excluirTarefa(tarefa.id!);

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

  String _formatarTag(String? tag) {
    if (tag == null || tag.isEmpty) return '';
    return tag.toLowerCase() == 'negocio' ? 'Negócio' : 'Faculdade';
  }

  Color _corTag(String? tag, BuildContext context) {
  final appColors = Theme.of(context).extension<AppColors>()!;

  if (tag == null || tag.isEmpty) return appColors.greyThree; // Usando seu cinza
  
  return tag.toLowerCase() == 'negocio'
      ? const Color(0xFF10B981)
      : const Color(0xFFE11D48);
}

  Widget _buildDia(String letra, String dia, TarefaDto tarefa) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final selecionado = tarefa.diasRealizacao.contains(dia);

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selecionado ? appColors.successColor : appColors.whiteColor,
        shape: BoxShape.circle,
        border: Border.all(color: appColors.successColor, width: 2),
      ),
      child: Text(
        letra,
        style: TextStyle(
          color: selecionado ? appColors.whiteColor : const Color(0xFF1E40AF),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
     appBar: AppBar(
        backgroundColor: colors.whiteColor,
        elevation: 0,
        leading: Icon(Icons.arrow_back_ios, color: colors.azulAlba, size: 20),
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
            mainAxisSize: MainAxisSize.min,
            children: [
             TextField(
                controller: _buscaController,
                onChanged: (value) => setState(() => _busca = value.trim()), // Corrigido: movido para dentro do TextField
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  // hintText: 'Buscar tarefas...',
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
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 18, color: colors.azulAlba,
                    ),
                    Text(
                      "$_mesSelecionado 2025",
                      style: TextStyle(color: colors.azulAlba, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 18, color: colors.azulAlba)
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCardCalendario("Ter", "30", _diaSelecionado == 31),
                    _buildCardCalendario("Qua", "01", _diaSelecionado == 1),
                    _buildCardCalendario("Qui", "02", _diaSelecionado == 2),
                    _buildCardCalendario("Sex", "03", _diaSelecionado == 3),
                    _buildCardCalendario("Sab", "04", _diaSelecionado == 4),
                    _buildCardCalendario("Dom", "05", _diaSelecionado == 5),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Hoje",
                  style: TextStyle(color: colors.azulAlba, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
                StreamBuilder<List<TarefaDto>>(
                stream: _tarefasRepository.buscarTarefasStream(_busca, mes: null, dia: _diaSelecionado),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tarefas = snapshot.data ?? [];
                  if (tarefas.isEmpty) {
                    return Center(child: Text('Nenhuma tarefa encontrada',
                    style: TextStyle(
        color: colors.greyFive, // 👈 Usa o cinza do seu design system
        fontSize: 14,
        fontWeight: FontWeight.w500,)
        )
                    );
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
              const SizedBox(height: 24),
                 Row(
                children: [
                  Text(
                    "Tarefas",
                    style: TextStyle(color: colors.azulAlba, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  PopupMenuButton<String>(
                    onSelected: (String novoMes) {
                      setState(() => _mesSelecionado = novoMes);
                    },
                    itemBuilder: (BuildContext context) {
                      return _meses.map((String mes) {
                        return PopupMenuItem<String>(value: mes, child: Text(mes));
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.neonGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(_mesSelecionado, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Icon(Icons.keyboard_arrow_down, size: 18, color: colors.azulAlba),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<TarefaDto>>(
                stream: _tarefasRepository.buscarTarefasStream(_busca, mes: _mesSelecionado, dia: null),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

                  if (!snapshot.hasData) return const SizedBox();

                  final tarefas = snapshot.data!;

                  if (tarefas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            "Nenhuma tarefa encontrada para este mês.",
            style: TextStyle(color: colors.greyFive),
          ),
        ),
      );
    }
  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) => _buildTimelineTask(tarefas[index]),
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

Widget _buildCardCalendario(String diaSemana, String numero, bool selecionado) {
   final colors = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: () {
        setState(() {
          _diaSelecionado = int.parse(numero);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? colors.neonGreen : colors.whiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: selecionado ? colors.neonGreen: colors.greyThree, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              diaSemana,
              style: TextStyle(
                  color: selecionado ? colors.whiteColor : colors.greyThree, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              numero,
              style: TextStyle(
                  color: selecionado ? colors.whiteColor : colors.azulAlba,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  } // <--- FECHA A FUNÇÃO DO CALENDÁRIO

  Widget _buildTimelineTask(TarefaDto tarefa) {
 final colors = Theme.of(context).extension<AppColors>()!;
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
                    fontSize: 16),
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
                      color: colors.blackColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: false,
                      onChanged: (v) {},
                      shape: const CircleBorder(),
                      activeColor: colors.neonGreen,
                      side: BorderSide(color: colors.azulAlba, width: 2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tarefa.tituloTarefa,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.azulAlba,
                                fontSize: 15)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.subdirectory_arrow_right,
                                size: 14, color: _corTag(tarefa.tag, context)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Meta: ${tarefa.tituloMeta ?? 'Sem Meta'}",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _corTag(tarefa.tag, context),
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:  Icon(Icons.more_vert, color: colors.textPrimaryColor),
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

 void _mostrarOpcoesTarefa(TarefaDto tarefa) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) {
      // 1. A variável fica aqui, dentro das chaves do builder
      final appColors = Theme.of(context).extension<AppColors>()!;

      return Wrap(
        children: [
          ListTile(
            // 2. Removido o 'const' e atualizado para 'appColors.azulAlba'
            leading: Icon(Icons.edit, color: appColors.azulAlba),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditarTarefaScreen(tarefa: tarefa)));
            },
          ),
          ListTile(
            // 3. Removido o 'const' e atualizado para 'appColors.primaryColor'
            leading: Icon(Icons.delete, color: appColors.primaryColor),
            title: const Text('Excluir'),
            onTap: () {
              Navigator.pop(context);
              _confirmarExclusao(tarefa);
            },
          ),
        ],
      );
    }, // O builder fecha aqui
  );
}
    }