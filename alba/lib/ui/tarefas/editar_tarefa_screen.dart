import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/domain/entities/recorrencia.dart';
import 'package:alba/domain/validators/tarefa_validator.dart';
import 'package:alba/ui/design_system/modals/frequencia_modal.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/design_system/widgets/horario_widget.dart';
import 'package:flutter/material.dart';

const Color albaLightBlue = Color(0xFF7FE2E1);

class EditarTarefaScreen extends StatefulWidget {
  final TarefaDto tarefa;

  const EditarTarefaScreen({
    super.key,
    required this.tarefa,
  });

  @override
  State<EditarTarefaScreen> createState() => _EditarTarefaScreenState();
}

class _EditarTarefaScreenState extends State<EditarTarefaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TarefasRepository _tarefasRepository = TarefasRepository();
  final MetasRepository _metasRepository = MetasRepository();

  late TextEditingController _tituloController;
  late TextEditingController _dataInicialController;

  bool _salvando = false;
  bool _vincularMeta = false;
  bool _carregandoMetas = true;

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

  List<MetaDto> get _metasFiltradas {
    if (_tagSelecionada == null) return [];

    return _metas
        .where((meta) => meta.tag.toLowerCase() == _tagSelecionada)
        .toList();
  }

  @override
  void initState() {
    super.initState();

    _tituloController = TextEditingController(
      text: widget.tarefa.tituloTarefa,
    );

    _dataInicialController = TextEditingController(
      text: widget.tarefa.dataInicial != null
          ? '${widget.tarefa.dataInicial!.day.toString().padLeft(2, '0')}/${widget.tarefa.dataInicial!.month.toString().padLeft(2, '0')}/${widget.tarefa.dataInicial!.year}'
          : '',
    );

    _tipoRecorrenciaSelecionado = widget.tarefa.tipoRecorrencia;
    _configuracaoRecorrencia = widget.tarefa.configuracaoRecorrencia;

    final diasConfig = widget.tarefa.configuracaoRecorrencia?.diasSemana;

    if (_tipoRecorrenciaSelecionado == TipoRecorrencia.personalizado &&
        diasConfig != null &&
        diasConfig.isNotEmpty) {
      _diasSelecionados =
          diasConfig.map((dia) => dia.toLowerCase().trim()).toList();
    } else {
      _diasSelecionados = widget.tarefa.diasRealizacao
          .map((dia) => dia.toLowerCase().trim())
          .toList();
    }

    _vincularMeta =
        widget.tarefa.metaId != null && widget.tarefa.metaId!.trim().isNotEmpty;

    _tagSelecionada = widget.tarefa.tag?.toLowerCase().trim();

    _horarioInicio = widget.tarefa.horarioInicio ?? widget.tarefa.horario;
    _horarioFim = widget.tarefa.horarioFim;

    _dataInicial = widget.tarefa.dataInicial;

    _carregarMetas();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _dataInicialController.dispose();
    super.dispose();
  }

  String? _normalizarHorario(String? value) {
    final texto = value?.trim();

    if (texto == null || texto.isEmpty) {
      return null;
    }

    return texto;
  }

  String _diaDaSemana(DateTime data) {
    const dias = [
      'segunda',
      'terca',
      'quarta',
      'quinta',
      'sexta',
      'sabado',
      'domingo',
    ];

    return dias[data.weekday - 1];
  }

  List<String> _diasRealizacaoParaSalvar({
    TipoRecorrencia? tipo,
    ConfiguracaoRecorrencia? config,
  }) {
    final tipoFinal = tipo ?? _tipoRecorrenciaSelecionado;

    switch (tipoFinal) {
      case TipoRecorrencia.naoRepete:
        return [];

      case TipoRecorrencia.diaria:
        return List<String>.from(_diasSemana);

      case TipoRecorrencia.segAVinco:
        return [
          'segunda',
          'terca',
          'quarta',
          'quinta',
          'sexta',
        ];

      case TipoRecorrencia.semanal:
        if (_dataInicial == null) return [];
        return [_diaDaSemana(_dataInicial!)];

      case TipoRecorrencia.personalizado:
        return List<String>.from(config?.diasSemana ?? _diasSelecionados);

      case TipoRecorrencia.mensal:
      case TipoRecorrencia.anual:
        return [];
    }
  }

  ConfiguracaoRecorrencia? _configuracaoParaSalvar(
    List<String> diasParaSalvar,
  ) {
    if (_tipoRecorrenciaSelecionado != TipoRecorrencia.personalizado) {
      return null;
    }

    return ConfiguracaoRecorrencia(
      diasSemana: List<String>.from(diasParaSalvar),
      intervaloEmDias: _configuracaoRecorrencia?.intervaloEmDias,
    );
  }

  Future<void> _carregarMetas() async {
    try {
      final metas = await _metasRepository.obterMetas();

      MetaDto? metaInicial;

      final metaId = widget.tarefa.metaId;

      if (metaId != null && metaId.trim().isNotEmpty) {
        try {
          metaInicial = metas.firstWhere((meta) => meta.id == metaId);
        } catch (_) {
          metaInicial = null;
        }
      }

      if (!mounted) return;

      setState(() {
        _metas = metas;
        _metaSelecionada = metaInicial;

        if (_tagSelecionada == null && metaInicial != null) {
          _tagSelecionada = metaInicial.tag.toLowerCase().trim();
        }

        _carregandoMetas = false;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint('Erro ao carregar metas: $e');

      setState(() {
        _metas = [];
        _carregandoMetas = false;
      });
    }
  }

  Theme _buildDatePickerTheme({
    required BuildContext context,
    required Widget child,
    required AppColors colors,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: colors.azulAlba,
          onPrimary: colors.whiteColor,
          surface: colors.whiteColor,
          onSurface: colors.azulAlba,
          secondary: colors.neonGreen,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: colors.whiteColor,
          headerBackgroundColor: colors.whiteColor,
          headerForegroundColor: colors.azulAlba,
          surfaceTintColor: colors.whiteColor,
          dayForegroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return colors.whiteColor;
            }

            if (states.contains(MaterialState.disabled)) {
              return colors.greyThree;
            }

            return colors.blackColor;
          }),
          dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return colors.azulAlba;
            }

            return null;
          }),
          todayForegroundColor: MaterialStateProperty.all(colors.azulAlba),
          todayBackgroundColor: MaterialStateProperty.all(
            colors.neonGreen.withOpacity(0.25),
          ),
          todayBorder: BorderSide(
            color: colors.neonGreen,
            width: 2,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: colors.azulAlba,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      child: child,
    );
  }

  Future<void> _selecionarData() async {
    final colors = Theme.of(context).extension<AppColors>()!;

    final hoje = DateTime.now();

    final primeiraData = DateTime(hoje.year - 5);
    final ultimaData = DateTime(hoje.year + 5);

    DateTime dataInicialPicker = _dataInicial ?? hoje;

    if (dataInicialPicker.isBefore(primeiraData)) {
      dataInicialPicker = primeiraData;
    }

    if (dataInicialPicker.isAfter(ultimaData)) {
      dataInicialPicker = ultimaData;
    }

    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataInicialPicker,
      firstDate: primeiraData,
      lastDate: ultimaData,
      builder: (context, child) {
        return _buildDatePickerTheme(
          context: context,
          colors: colors,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (dataSelecionada == null) return;

    setState(() {
      _dataInicial = dataSelecionada;
      _dataInicialController.text =
          '${dataSelecionada.day.toString().padLeft(2, '0')}/${dataSelecionada.month.toString().padLeft(2, '0')}/${dataSelecionada.year}';

      if (_tipoRecorrenciaSelecionado == TipoRecorrencia.semanal) {
        _diasSelecionados = [_diaDaSemana(dataSelecionada)];
      }
    });
  }

  void _abrirModalFrequencia() {
    showDialog(
      context: context,
      builder: (context) => FrequenciaModal(
        tipoRecorrenciaInicial: _tipoRecorrenciaSelecionado,
        configuracaoInicial: _configuracaoRecorrencia,
        onConfirm: (tipo, config) {
          setState(() {
            _tipoRecorrenciaSelecionado = tipo;

            _configuracaoRecorrencia =
                tipo == TipoRecorrencia.personalizado ? config : null;

            _diasSelecionados = _diasRealizacaoParaSalvar(
              tipo: tipo,
              config: config,
            );
          });
        },
      ),
    );
  }

  Future<void> _editarTarefa() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_dataInicial == null) {
      _mostrarErro('Selecione a data inicial da tarefa.');
      return;
    }

    final inicio = _normalizarHorario(_horarioInicio);
    final fim = _normalizarHorario(_horarioFim);

    final erroHorario = TarefaValidator.validateIntervaloHorario(inicio, fim);

    if (erroHorario != null) {
      _mostrarErro(erroHorario);
      return;
    }

    final diasParaSalvar = _diasRealizacaoParaSalvar();

    final erroDias = TarefaValidator.validateDias(
      diasParaSalvar,
      _tipoRecorrenciaSelecionado,
    );

    if (erroDias != null) {
      _mostrarErro(erroDias);
      return;
    }

    if (_tipoRecorrenciaSelecionado == TipoRecorrencia.personalizado &&
        diasParaSalvar.isEmpty) {
      _mostrarErro(
        'Selecione pelo menos um dia da semana para recorrência personalizada.',
      );
      return;
    }

    if (!_vincularMeta) {
      _mostrarErro(
        'Toda tarefa precisa estar vinculada a uma meta. Ative o campo abaixo.',
      );
      return;
    }

    if (_tagSelecionada == null) {
      _mostrarErro('Selecione a categoria da meta.');
      return;
    }

    if (_metaSelecionada == null) {
      _mostrarErro('Por favor, selecione uma meta válida no campo.');
      return;
    }

    final metaErro = TarefaValidator.validateMeta(
      vincularMeta: _vincularMeta,
      metaId: _metaSelecionada?.id,
    );

    if (metaErro != null) {
      _mostrarErro(metaErro);
      return;
    }

    try {
      setState(() {
        _salvando = true;
      });

      final tarefaAtualizada = TarefaDto(
        id: widget.tarefa.id,
        tituloTarefa: _tituloController.text.trim(),
        diasRealizacao: diasParaSalvar,
        horario: inicio,
        horarioInicio: inicio,
        horarioFim: fim,
        dataInicial: _dataInicial,
        metaId: _metaSelecionada!.id,
        tituloMeta: _metaSelecionada!.tituloMeta,
        tag: _tagSelecionada,
        status: widget.tarefa.status,
        userId: widget.tarefa.userId,
        dataCriacao: widget.tarefa.dataCriacao,
        dataConclusao: widget.tarefa.dataConclusao,
        tipoRecorrencia: _tipoRecorrenciaSelecionado,
        configuracaoRecorrencia: _configuracaoParaSalvar(diasParaSalvar),
      );

      await _tarefasRepository.atualizarTarefa(tarefaAtualizada);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      _mostrarErro('Erro ao atualizar: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensagem)),
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
        title: Text(
          'Editar Tarefa',
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
          child: Container(
            color: colors.azulAlba.withOpacity(0.2),
            height: 1,
          ),
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
                validator: (value) =>
                    TarefaValidator.validateTitulo(value ?? ''),
                colors: colors,
              ),
              const SizedBox(height: 28),
              _buildSectionLabel('Data inicial', colors),
              _buildDataSelector(colors),
              const SizedBox(height: 28),
              _buildSectionLabel('Frequência', colors),
              _buildFrequenciaSelector(colors),
              const SizedBox(height: 28),
              if (_tipoRecorrenciaSelecionado ==
                  TipoRecorrencia.personalizado) ...[
                _buildSectionLabel('Dias de realização', colors),
                const SizedBox(height: 12),
                _buildDiasSelector(colors),
                const SizedBox(height: 28),
              ],
              _buildSectionLabel('Horário', colors),
              const SizedBox(height: 12),
              _buildHorarioRange(),
              const SizedBox(height: 32),
              _buildMetaSection(colors),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _editarTarefa,
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
                          'Salvar Alterações',
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
                  fontWeight:
                      data.isEmpty ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            if (data.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _dataInicialController.clear();
                    _dataInicial = null;

                    if (_tipoRecorrenciaSelecionado ==
                        TipoRecorrencia.semanal) {
                      _diasSelecionados = [];
                    }
                  });
                },
                child: const Icon(Icons.close, size: 20),
              )
            else
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorarioRange() {
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colors.greyFive,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            icon,
            color: colors.azulAlba.withOpacity(0.65),
            size: 24,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.3,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(
              color: albaLightBlue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colors.errorColor,
              width: 1.3,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colors.errorColor,
              width: 2,
            ),
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
              if (value) {
                if (!_diasSelecionados.contains(dia)) {
                  _diasSelecionados.add(dia);
                }
              } else {
                _diasSelecionados.remove(dia);
              }

              _configuracaoRecorrencia = ConfiguracaoRecorrencia(
                diasSemana: List<String>.from(_diasSelecionados),
                intervaloEmDias: _configuracaoRecorrencia?.intervaloEmDias,
              );
            });
          },
          selectedColor: colors.neonGreen,
          backgroundColor: Colors.grey.shade100,
          labelStyle: TextStyle(
            color: selecionado ? colors.azulAlba : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
        border: Border.all(
          color: colors.azulAlba.withOpacity(0.1),
        ),
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
                onChanged: (value) {
                  setState(() {
                    _vincularMeta = value;

                    if (!value) {
                      _tagSelecionada = null;
                      _metaSelecionada = null;
                    }
                  });
                },
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
                  padding: const EdgeInsets.only(top: 8),
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
                        (meta) => DropdownMenuItem<MetaDto>(
                          value: meta,
                          child: Text(meta.tituloMeta),
                        ),
                      )
                      .toList(),
                  onChanged: (meta) {
                    setState(() {
                      _metaSelecionada = meta;
                    });
                  },
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
        onTap: () {
          setState(() {
            _tagSelecionada = tag;
            _metaSelecionada = null;
          });
        },
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