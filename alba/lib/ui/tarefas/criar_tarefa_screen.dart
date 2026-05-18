import 'package:firebase_auth/firebase_auth.dart';
import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/domain/entities/recorrencia.dart';
import 'package:alba/domain/validators/tarefa_validator.dart';
import 'package:alba/ui/design_system/modals/frequencia_modal.dart';
import 'package:alba/ui/design_system/widgets/horario_widget.dart';
import 'package:flutter/material.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';

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
  final TextEditingController _dataInicialController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();

  bool _salvando = false;
  bool _vincularMeta = false;

  List<String> _diasSelecionados = [];
  List<MetaDto> _metas = [];
  MetaDto? _metaSelecionada;
  String? _tagSelecionada;

  TipoRecorrencia _tipoRecorrenciaSelecionado = TipoRecorrencia.naoRepete;
  ConfiguracaoRecorrencia? _configuracaoRecorrencia;
  String? _horarioInicio;
  String? _horarioFim;
  DateTime? _dataInicial;

  final List<String> _diasSemana = const [
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
  ];
  bool _carregandoMetas = true;

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
        _carregandoMetas = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Erro ao carregar metas: $e');
      setState(() {
        _carregandoMetas = false;
      });
    }
  }

  Future<void> _selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataInicial ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataInicial = dataSelecionada;
        _dataInicialController.text =
            '${dataSelecionada.day.toString().padLeft(2, '0')}/${dataSelecionada.month.toString().padLeft(2, '0')}/${dataSelecionada.year}';
      });
    }
  }

  Future<void> _selecionarHorario() async {
    final agora = TimeOfDay.now();

    TimeOfDay initialTime = agora;

    if (_horarioController.text.isNotEmpty) {
      final partes = _horarioController.text.split(':');
      if (partes.length == 2) {
        final hora = int.tryParse(partes[0]);
        final minuto = int.tryParse(partes[1]);
        if (hora != null && minuto != null) {
          initialTime = TimeOfDay(hour: hora, minute: minuto);
        }
      }
    }

    final horarioSelecionado = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (horarioSelecionado != null) {
      final hora = horarioSelecionado.hour.toString().padLeft(2, '0');
      final minuto = horarioSelecionado.minute.toString().padLeft(2, '0');

      setState(() {
        _horarioController.text = '$hora:$minuto';
      });
    }
  }

  // void _abrirModalFrequencia() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => FrequenciaModal(
  //       tipoRecorrenciaInicial: _tipoRecorrenciaSelecionado,
  //       configuracaoInicial: _configuracaoRecorrencia,
  //       onConfirm: (tipo, config) {
  //         setState(() {
  //           _tipoRecorrenciaSelecionado = tipo;
  //           _configuracaoRecorrencia = config;

  //           switch (tipo) {
  //             case TipoRecorrencia.diaria:
  //               _diasSelecionados.clear();
  //               _diasSelecionados.addAll(_diasSemana);
  //               break;
  //             case TipoRecorrencia.segAVinco:
  //               _diasSelecionados.clear();
  //               _diasSelecionados.addAll([
  //                 'segunda',
  //                 'terca',
  //                 'quarta',
  //                 'quinta',
  //                 'sexta',
  //               ]);
  //               break;
  //             case TipoRecorrencia.personalizado:
  //               break;
  //             default:
  //               _diasSelecionados.clear();
  //               break;
  //           }
  //         });
  //       },
  //     ),
  //   );
  // }

  void _abrirModalFrequencia() {
    showDialog(
      context: context,
      builder: (context) => FrequenciaModal(
        tipoRecorrenciaInicial: _tipoRecorrenciaSelecionado,
        configuracaoInicial: _configuracaoRecorrencia,
        onConfirm: (tipo, config) {
          setState(() {
            _tipoRecorrenciaSelecionado = tipo;
            _configuracaoRecorrencia = config;

            switch (tipo) {
              case TipoRecorrencia.diaria:
                _diasSelecionados.clear();
                _diasSelecionados.addAll(_diasSemana);
                break;
              case TipoRecorrencia.segAVinco:
                _diasSelecionados.clear();
                _diasSelecionados.addAll([
                  'segunda',
                  'terca',
                  'quarta',
                  'quinta',
                  'sexta',
                ]);
                break;
              case TipoRecorrencia.semanal:
                // ✨ CORRIGIDO: Mapeia o dia da semana atual baseado na data selecionada
                if (_dataInicial != null) {
                  final diasMapeados = [
                    'domingo',
                    'segunda',
                    'terca',
                    'quarta',
                    'quinta',
                    'sexta',
                    'sabado',
                  ];
                  _diasSelecionados = [diasMapeados[_dataInicial!.weekday % 7]];
                }
                break;
              case TipoRecorrencia.personalizado:
                if (config?.diasSemana != null) {
                  _diasSelecionados = List<String>.from(config!.diasSemana!);
                }
                break;
              case TipoRecorrencia.mensal:
              default:
                _diasSelecionados.clear();
                break;
            }
          });
        },
      ),
    );
  }

  // Future<void> _criarTarefa() async {
  //   final erroTitulo = TarefaValidator.validateTitulo(_tituloController.text);
  //   if (erroTitulo != null) {
  //     _mostrarErro(erroTitulo);
  //     return;
  //   }

  //   final erroDias = TarefaValidator.validateDias(
  //     _diasSelecionados,
  //     _tipoRecorrenciaSelecionado,
  //   );
  //   if (erroDias != null) {
  //     _mostrarErro(erroDias);
  //     return;
  //   }

  //   if (_dataInicial == null) {
  //     _mostrarErro('Selecione a data inicial da tarefa.');
  //     return;
  //   }

  //   final erroHorario = TarefaValidator.validateIntervaloHorario(
  //     _horarioInicio,
  //     _horarioFim,
  //   );
  //   if (erroHorario != null) {
  //     _mostrarErro(erroHorario);
  //     return;
  //   }

  //   if (_tipoRecorrenciaSelecionado == TipoRecorrencia.personalizado) {
  //     if (_diasSelecionados.isEmpty) {
  //       _mostrarErro(
  //         'Selecione pelo menos um dia da semana para recorrência personalizada.',
  //       );
  //       return;
  //     }
  //   }

  //   if (_tipoRecorrenciaSelecionado == TipoRecorrencia.personalizado) {
  //     if (_diasSelecionados.isEmpty) {
  //       _mostrarErro(
  //         'Selecione pelo menos um dia da semana para recorrência personalizada.',
  //       );
  //       return;
  //     }
  //   }

  //   if (_vincularMeta) {
  //     if (_vincularMeta && _tagSelecionada == null) {
  //       _mostrarErro('Selecione a categoria da meta.');
  //       return;
  //     }

  //     final metaErro = TarefaValidator.validateMeta(
  //       vincularMeta: _vincularMeta,
  //       metaId: _metaSelecionada?.id,
  //     );

  //     if (metaErro != null) {
  //       _mostrarErro(metaErro);
  //       return;
  //     }

  //     try {
  //       setState(() {
  //         _salvando = true;
  //       });

  //       List<String> diasParaSalvar = List<String>.from(_diasSelecionados);
  //       if (_tipoRecorrenciaSelecionado == TipoRecorrencia.mensal &&
  //           _dataInicial != null) {
  //         final mapeamentoDias = [
  //           'domingo',
  //           'segunda',
  //           'terca',
  //           'quarta',
  //           'quinta',
  //           'sexta',
  //           'sabado',
  //         ];
  //         diasParaSalvar = [mapeamentoDias[_dataInicial!.weekday % 7]];
  //       }

  //       final usuarioLogado = FirebaseAuth.instance.currentUser;
  //       final idUsuarioReal = usuarioLogado?.uid ?? '';

  //       final tarefa = TarefaDto(
  //         tituloTarefa: _tituloController.text.trim(),
  //         diasRealizacao: diasParaSalvar,
  //         horario: _horarioController.text.trim().isEmpty
  //             ? null
  //             : _horarioController.text.trim(),
  //         horarioInicio: _horarioInicio,
  //         horarioFim: _horarioFim,
  //         dataInicial: _dataInicial,
  //         metaId: _vincularMeta ? _metaSelecionada?.id : null,
  //         tituloMeta: _vincularMeta ? _metaSelecionada?.tituloMeta : null,
  //         tag: _vincularMeta ? _tagSelecionada : null,
  //         status: 'pendente',
  //         userId: idUsuarioReal,
  //         dataCriacao: DateTime.now(),
  //         tipoRecorrencia: _tipoRecorrenciaSelecionado,
  //         configuracaoRecorrencia: _configuracaoRecorrencia,
  //       );

  //       await _tarefasRepository.criarTarefa(tarefa);

  //       if (!mounted) return;
  //       Navigator.pop(context);
  //     } catch (e) {
  //       _mostrarErro(e.toString().replaceFirst('Exception: ', ''));
  //     } finally {
  //       if (mounted) {
  //         setState(() {
  //           _salvando = false;
  //         });
  //       }
  //     }
  //   }
  // }

  Future<void> _criarTarefa() async {
    // 1. Validações de formato básicas
    final erroTitulo = TarefaValidator.validateTitulo(_tituloController.text);
    if (erroTitulo != null) {
      _mostrarErro(erroTitulo);
      return;
    }

    final erroDias = TarefaValidator.validateDias(
      _diasSelecionados,
      _tipoRecorrenciaSelecionado,
    );
    if (erroDias != null) {
      _mostrarErro(erroDias);
      return;
    }

    if (_dataInicial == null) {
      _mostrarErro('Selecione a data inicial da tarefa.');
      return;
    }

    final erroHorario = TarefaValidator.validateIntervaloHorario(
      _horarioInicio,
      _horarioFim,
    );
    if (erroHorario != null) {
      _mostrarErro(erroHorario);
      return;
    }

    if (_tipoRecorrenciaSelecionado == TipoRecorrencia.personalizado) {
      if (_diasSelecionados.isEmpty) {
        _mostrarErro(
          'Selecione pelo menos um dia da semana para recorrência personalizada.',
        );
        return;
      }
    }

    // ✨ TRAVA OBRIGATÓRIA: O usuário DEVE ativar o Switch de metas
    if (!_vincularMeta) {
      _mostrarErro(
        'Toda tarefa precisa estar vinculada a uma meta. Ative o campo abaixo.',
      );
      return;
    }

    // ✨ TRAVA OBRIGATÓRIA: Deve escolher se é Negócio ou Faculdade
    if (_tagSelecionada == null) {
      _mostrarErro('Selecione a categoria da meta (Negócio ou Faculdade).');
      return;
    }

    // ✨ TRAVA OBRIGATÓRIA: Deve selecionar uma meta do Dropdown
    if (_metaSelecionada == null) {
      _mostrarErro('Por favor, selecione uma meta válida no campo.');
      return;
    }

    // Validação extra do validador do projeto se houver
    final metaErro = TarefaValidator.validateMeta(
      vincularMeta: _vincularMeta,
      metaId: _metaSelecionada?.id,
    );
    if (metaErro != null) {
      _mostrarErro(metaErro);
      return;
    }

    // 2. Fluxo de salvamento no Firebase
    try {
      setState(() {
        _salvando = true;
      });

      List<String> diasParaSalvar = List<String>.from(_diasSelecionados);
      if (_tipoRecorrenciaSelecionado == TipoRecorrencia.mensal &&
          _dataInicial != null) {
        final mapeamentoDias = [
          'domingo',
          'segunda',
          'terca',
          'quarta',
          'quinta',
          'sexta',
          'sabado',
        ];
        diasParaSalvar = [mapeamentoDias[_dataInicial!.weekday % 7]];
      }

      final usuarioLogado = FirebaseAuth.instance.currentUser;
      final idUsuarioReal = usuarioLogado?.uid ?? '';

      final tarefa = TarefaDto(
        tituloTarefa: _tituloController.text.trim(),
        diasRealizacao: diasParaSalvar,
        horario: _horarioController.text.trim().isEmpty
            ? null
            : _horarioController.text.trim(),
        horarioInicio: _horarioInicio,
        horarioFim: _horarioFim,
        dataInicial: _dataInicial,

        // Dados validados e obrigatórios salvos com segurança
        metaId: _metaSelecionada!.id,
        tituloMeta: _metaSelecionada!.tituloMeta,
        tag: _tagSelecionada!,

        status: 'pendente',
        userId: idUsuarioReal,
        dataCriacao: DateTime.now(),
        tipoRecorrencia: _tipoRecorrenciaSelecionado,
        configuracaoRecorrencia: _configuracaoRecorrencia,
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
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        backgroundColor: colors.whiteColor,
        elevation: 0,
        title: Text(
          'Criar Tarefa',
          style: TextStyle(
            color: colors.azulAlba,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: colors.azulAlba),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: colors.azulAlba.withOpacity(0.2), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('O que você vai realizar?', colors),
              _buildCustomTextField(
                controller: _tituloController,
                hint: 'Título da tarefa...',
                icon: Icons.edit_note_rounded,
                colors: colors,
                validator: (value) =>
                    TarefaValidator.validateTitulo(value ?? ''),
              ),
              const SizedBox(height: 28),
              _buildSectionLabel('Data inicial', colors),
              _buildDataSelector(colors),
              const SizedBox(height: 28),
              _buildSectionLabel('Frequência', colors),
              _buildFrequenciaSelector(colors),
              const SizedBox(height: 28),
              if (_tipoRecorrenciaSelecionado ==
                  TipoRecorrencia.personalizado) ...<Widget>[
                _buildSectionLabel('Dias de realização', colors),
                const SizedBox(height: 12),
                _buildDiasSelector(colors),
                const SizedBox(height: 28),
              ],
              _buildSectionLabel('Horário (opcional)', colors),
              _buildHorarioSelector(colors),
              const SizedBox(height: 28),
              _buildHorarioRange(colors),
              const SizedBox(height: 32),
              _buildMetaSection(colors),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _criarTarefa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.azulAlba,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Criar Tarefa',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSelector(AppColors colors) {
    final data = _dataInicialController.text.trim();

    return GestureDetector(
      onTap: _selecionarData,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: colors.azulAlba.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.isEmpty ? 'Selecionar data' : data,
                style: TextStyle(
                  fontSize: 16,
                  color: data.isEmpty ? Colors.grey.shade500 : Colors.black87,
                  fontWeight: data.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            if (data.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _dataInicialController.clear();
                    _dataInicial = null;
                  });
                },
                child: const Icon(Icons.close, size: 20),
              )
            else
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequenciaSelector(AppColors colors) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: _abrirModalFrequencia,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.repeat_rounded,
                color: colors.azulAlba.withOpacity(0.6),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _tipoRecorrenciaSelecionado.label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorarioRange(AppColors colors) {
    return HorarioWidget(
      horarioInicio: _horarioInicio,
      horarioFim: _horarioFim,
      onChanged: (inicio, fim) {
        setState(() {
          _horarioInicio = inicio;
          _horarioFim = fim;
        });
      },
    );
  }

  Widget _buildHorarioSelector(AppColors colors) {
    final horario = _horarioController.text.trim();

    return GestureDetector(
      onTap: _selecionarHorario,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: colors.azulAlba.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                horario.isEmpty ? 'Selecionar horário' : horario,
                style: TextStyle(
                  fontSize: 16,
                  color: horario.isEmpty
                      ? Colors.grey.shade500
                      : Colors.black87,
                  fontWeight: horario.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            if (horario.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _horarioController.clear();
                  });
                },
                child: const Icon(Icons.close, size: 20),
              )
            else
              Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, AppColors colors) {
    return Text(
      label,
      style: TextStyle(
        color: colors.azulAlba,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required AppColors colors,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: colors.azulAlba.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDiasSelector(AppColors colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _diasSemana.map((dia) {
        final selecionado = _diasSelecionados.contains(dia);
        return ChoiceChip(
          label: Text(dia.substring(0, 3).toUpperCase()),
          selected: selecionado,
          onSelected: (value) {
            setState(() {
              value
                  ? _diasSelecionados.add(dia)
                  : _diasSelecionados.remove(dia);
            });
          },
          selectedColor: colors.neonGreen,
          backgroundColor: Colors.grey.shade100,
          labelStyle: TextStyle(
            color: selecionado ? colors.azulAlba : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(
            color: selecionado ? colors.neonGreen : Colors.grey.shade300,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetaSection(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.azulAlba.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionLabel('Vincular à meta', colors),
              Switch(
                value: _vincularMeta,
                activeColor: colors.neonGreen,
                onChanged: (v) => setState(() {
                  _vincularMeta = v;
                  if (!v) {
                    _tagSelecionada = null;
                    _metaSelecionada = null;
                  }
                }),
              ),
            ],
          ),
          if (_vincularMeta) ...[
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTagButton('Negócio', 'negocio', colors),
                const SizedBox(width: 10),
                _buildTagButton('Faculdade', 'faculdade', colors),
              ],
            ),
            if (_carregandoMetas) ...[
              const SizedBox(height: 16),
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_tagSelecionada != null) ...[
              const SizedBox(height: 15),
              if (_metasFiltradas.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Nenhuma meta encontrada para esta categoria.',
                    style: TextStyle(color: colors.greyThree),
                  ),
                )
              else
                DropdownButtonFormField<MetaDto>(
                  value: _metaSelecionada,
                  hint: const Text('Selecione a meta'),
                  items: _metasFiltradas
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.tituloMeta),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _metaSelecionada = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTagButton(String label, String tag, AppColors colors) {
    final isSelected = _tagSelecionada == tag;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tagSelecionada = tag;
          _metaSelecionada = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colors.azulAlba : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colors.azulAlba : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
