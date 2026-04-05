import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/domain/validators/tarefa_validator.dart';
import 'package:flutter/material.dart';

class CriarTarefaScreen extends StatefulWidget {
  const CriarTarefaScreen({super.key});

  @override
  State<CriarTarefaScreen> createState() => _CriarTarefaScreenState();
}

class _CriarTarefaScreenState extends State<CriarTarefaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TarefasRepository _tarefasRepository = TarefasRepository();
  final MetasRepository _metasRepository = MetasRepository();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();

  bool _salvando = false;
  bool _vincularMeta = false;

  List<String> _diasSelecionados = [];
  List<MetaDto> _metas = [];
  MetaDto? _metaSelecionada;
  String? _tagSelecionada;

  final List<String> _diasSemana = const [
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
  ];

  List<MetaDto> get _metasFiltradas {
    if (_tagSelecionada == null) return [];
    return _metas
        .where((meta) => meta.tag.toLowerCase() == _tagSelecionada)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _carregarMetas();
  }

  Future<void> _carregarMetas() async {
    try {
      final metas = await _metasRepository.obterMetas();
      if (!mounted) return;
      setState(() {
        _metas = metas;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  Future<void> _criarTarefa() async {
    final tituloErro = TarefaValidator.validateTitulo(_tituloController.text);
    final diasErro = TarefaValidator.validateDias(_diasSelecionados);
    final horarioErro = TarefaValidator.validateHorario(
      _horarioController.text,
    );
    final metaErro = TarefaValidator.validateMeta(
      vincularMeta: _vincularMeta,
      metaId: _metaSelecionada?.id,
    );

    if (tituloErro != null) {
      _mostrarErro(tituloErro);
      return;
    }

    if (diasErro != null) {
      _mostrarErro(diasErro);
      return;
    }

    if (horarioErro != null) {
      _mostrarErro(horarioErro);
      return;
    }

    if (_vincularMeta && _tagSelecionada == null) {
      _mostrarErro('Selecione a categoria da meta.');
      return;
    }

    if (metaErro != null) {
      _mostrarErro(metaErro);
      return;
    }

    try {
      setState(() {
        _salvando = true;
      });

      final tarefa = TarefaDto(
        tituloTarefa: _tituloController.text.trim(),
        diasRealizacao: _diasSelecionados,
        horario: _horarioController.text.trim().isEmpty
            ? null
            : _horarioController.text.trim(),
        metaId: _vincularMeta ? _metaSelecionada?.id : null,
        tituloMeta: _vincularMeta ? _metaSelecionada?.tituloMeta : null,
        tag: _vincularMeta ? _tagSelecionada : null,
        status: 'pendente',
        userId: '',
        dataCriacao: DateTime.now(),
      );

      await _tarefasRepository.criarTarefa(tarefa);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _mostrarErro(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Tarefa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Eu vou...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Dias de realização',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _diasSemana.map((dia) {
                  final selecionado = _diasSelecionados.contains(dia);

                  return FilterChip(
                    label: Text(dia),
                    selected: selecionado,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _diasSelecionados.add(dia);
                        } else {
                          _diasSelecionados.remove(dia);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _horarioController,
                decoration: const InputDecoration(
                  labelText: 'Horário (opcional)',
                  hintText: 'HH:MM',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vincular à meta'),
                value: _vincularMeta,
                onChanged: (value) {
                  setState(() {
                    _vincularMeta = value;
                    if (!value) {
                      _metaSelecionada = null;
                      _tagSelecionada = null;
                    }
                  });
                },
              ),

              if (_vincularMeta) ...[
                const SizedBox(height: 8),

                const Text(
                  'Categoria da meta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Negócio'),
                      selected: _tagSelecionada == 'negocio',
                      onSelected: (_) {
                        setState(() {
                          _tagSelecionada = 'negocio';
                          _metaSelecionada = null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Faculdade'),
                      selected: _tagSelecionada == 'faculdade',
                      onSelected: (_) {
                        setState(() {
                          _tagSelecionada = 'faculdade';
                          _metaSelecionada = null;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_tagSelecionada != null)
                  DropdownButtonFormField<MetaDto>(
                    value: _metaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Selecione uma meta',
                      border: OutlineInputBorder(),
                    ),
                    items: _metasFiltradas.map((meta) {
                      return DropdownMenuItem<MetaDto>(
                        value: meta,
                        child: Text(meta.tituloMeta),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _metaSelecionada = value;
                      });
                    },
                  ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _criarTarefa,
                  child: _salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Criar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
