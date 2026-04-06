import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
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
  final TarefasRepository _tarefasRepository = TarefasRepository();
  final TextEditingController _buscaController = TextEditingController();

  String _busca = '';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _confirmarExclusao(TarefaDto tarefa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

  Color _corTag(String? tag) {
    if (tag == null || tag.isEmpty) return Colors.grey;
    return tag.toLowerCase() == 'negocio'
        ? const Color(0xFF10B981)
        : const Color(0xFFE11D48);
  }

  Widget _buildDia(String letra, String dia, TarefaDto tarefa) {
    final selecionado = tarefa.diasRealizacao.contains(dia);

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selecionado ? const Color(0xFF84F41E) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF84F41E), width: 2),
      ),
      child: Text(
        letra,
        style: TextStyle(
          color: selecionado ? Colors.white : const Color(0xFF1E40AF),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciamento de Tarefas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CriarTarefaScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar tarefas...',
                prefixIcon: const Icon(Icons.search),
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
              onChanged: (value) {
                setState(() {
                  _busca = value.trim();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<TarefaDto>>(
                stream: _tarefasRepository.buscarTarefasStream(_busca),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final tarefas = snapshot.data ?? [];

                  if (tarefas.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma tarefa encontrada'),
                    );
                  }

                  return ListView.separated(
                    itemCount: tarefas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final tarefa = tarefas[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E40AF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF84F41E),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tarefa.tituloTarefa,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF84F41E),
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditarTarefaScreen(tarefa: tarefa),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color(0xFF84F41E),
                                  ),
                                  onPressed: () => _confirmarExclusao(tarefa),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (tarefa.tag != null && tarefa.tag!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _corTag(tarefa.tag),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatarTag(tarefa.tag),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDia('S', 'segunda', tarefa),
                                _buildDia('T', 'terca', tarefa),
                                _buildDia('Q', 'quarta', tarefa),
                                _buildDia('Q', 'quinta', tarefa),
                                _buildDia('S', 'sexta', tarefa),
                                _buildDia('S', 'sabado', tarefa),
                                _buildDia('D', 'domingo', tarefa),
                              ],
                            ),
                            if (tarefa.horario != null &&
                                tarefa.horario!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Horário: ${tarefa.horario}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            if (tarefa.tituloMeta != null &&
                                tarefa.tituloMeta!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Meta: ${tarefa.tituloMeta}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
