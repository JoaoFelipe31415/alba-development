import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/domain/validators/tarefa_validator.dart';
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
  final TextEditingController _horarioController = TextEditingController();

  bool _salvando = false;
  bool _vincularMeta = false;

  final List<String> _diasSelecionados = [];
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
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        backgroundColor: colors.whiteColor,
        elevation: 0,
      title: Text('Criar Tarefa',
        style: TextStyle(color: colors.azulAlba, fontWeight: FontWeight.bold, fontSize: 22)),
      leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios, color: colors.azulAlba),
      ),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: colors.azulAlba.withOpacity(0.2), height: 1),
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
                colors: colors
              ),
              const SizedBox(height: 28),
            _buildSectionLabel('Dias de realização', colors),
              const SizedBox(height: 12),
              _buildDiasSelector(colors),

              const SizedBox(height: 28),

              _buildSectionLabel('Horário (opcional)', colors),
              _buildCustomTextField(
                controller: _horarioController,
                hint: 'HH:MM',
                icon: Icons.access_time_rounded,
                keyboardType: TextInputType.text,
                colors: colors
              ),

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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _salvando 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Criar Tarefa', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, AppColors colors) {
    return Text(label, 
      style: TextStyle(color: colors.azulAlba, fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _buildCustomTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon,
    required AppColors colors,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: colors.azulAlba.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }

  Widget _buildDiasSelector( AppColors colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _diasSemana.map((dia) {
        final selecionado = _diasSelecionados.contains(dia);
        return ChoiceChip(
          label: Text(dia.substring(0, 3)), // Abreviação: Seg, Ter...
          selected: selecionado,
          onSelected: (value) {
            setState(() {
              value ? _diasSelecionados.add(dia) : _diasSelecionados.remove(dia);
            });
          },
          selectedColor: colors.neonGreen,
          backgroundColor: Colors.grey.shade100,
          labelStyle: TextStyle(
            color: selecionado ? colors.azulAlba : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: selecionado ? colors.neonGreen : Colors.grey.shade300),
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
                onChanged: (v) => setState(() => _vincularMeta = v),
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
            if (_tagSelecionada != null) ...[
              const SizedBox(height: 15),
              DropdownButtonFormField<MetaDto>(
                value: _metaSelecionada,
                hint: const Text('Selecione a meta'),
                items: _metasFiltradas.map((m) => DropdownMenuItem(value: m, child: Text(m.tituloMeta))).toList(),
                onChanged: (v) => setState(() => _metaSelecionada = v),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildTagButton(String label, String tag, AppColors colors) {
    bool isSelected = _tagSelecionada == tag;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _tagSelecionada = tag; _metaSelecionada = null; }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colors.azulAlba : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? colors.azulAlba : Colors.grey.shade300),
          ),
          child: Center(
            child: Text(label, 
              style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
  