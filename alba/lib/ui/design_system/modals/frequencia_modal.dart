import 'package:alba/domain/entities/recorrencia.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FrequenciaModal extends StatefulWidget {
  final TipoRecorrencia tipoRecorrenciaInicial;
  final ConfiguracaoRecorrencia? configuracaoInicial;
  final Function(TipoRecorrencia tipo, ConfiguracaoRecorrencia? config)
      onConfirm;

  const FrequenciaModal({
    required this.tipoRecorrenciaInicial,
    required this.configuracaoInicial,
    required this.onConfirm,
    super.key,
  });

  @override
  State<FrequenciaModal> createState() => _FrequenciaModalState();
}

class _FrequenciaModalState extends State<FrequenciaModal> {
  late TipoRecorrencia tipoSelecionado;
  late ConfiguracaoRecorrencia configuracaoTemp;

  final List<String> _diasSemana = [
    'DOM',
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SAB',
  ];

  final List<String> _diasSemanaCompletos = [
    'domingo',
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
  ];

  @override
  void initState() {
    super.initState();

    tipoSelecionado = widget.tipoRecorrenciaInicial;

    if (widget.configuracaoInicial != null) {
      configuracaoTemp = ConfiguracaoRecorrencia(
        intervaloEmDias: widget.configuracaoInicial!.intervaloEmDias,
        diasSemana: List<String>.from(
          widget.configuracaoInicial!.diasSemana ?? [],
        ),
      );
    } else {
      configuracaoTemp = ConfiguracaoRecorrencia(diasSemana: []);
    }
  }

  String _descricaoPorTipo(TipoRecorrencia tipo) {
    switch (tipo) {
      case TipoRecorrencia.naoRepete:
        return 'A tarefa será exibida apenas uma vez na data selecionada.';
      case TipoRecorrencia.diaria:
        return 'A tarefa será repetida todos os dias.';
      case TipoRecorrencia.segAVinco:
        return 'A tarefa será repetida de segunda a sexta-feira.';
      case TipoRecorrencia.semanal:
        return 'A tarefa será repetida semanalmente.';
      case TipoRecorrencia.mensal:
        return 'A tarefa será repetida mensalmente.';
      case TipoRecorrencia.anual:
        return 'A tarefa será repetida anualmente.';
      case TipoRecorrencia.personalizado:
        return 'Escolha os dias da semana para repetir a tarefa.';
    }
  }

  void _confirmar() {
    widget.onConfirm(
      tipoSelecionado,
      tipoSelecionado == TipoRecorrencia.personalizado
          ? configuracaoTemp
          : null,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 680,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.whiteColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.blackColor.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(colors),
              Divider(
                height: 1,
                color: colors.azulAlba.withOpacity(0.10),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFrequenciaOption(
                        tipo: TipoRecorrencia.naoRepete,
                        descricao: _descricaoPorTipo(
                          TipoRecorrencia.naoRepete,
                        ),
                        colors: colors,
                      ),
                      _buildFrequenciaOption(
                        tipo: TipoRecorrencia.diaria,
                        descricao: _descricaoPorTipo(
                          TipoRecorrencia.diaria,
                        ),
                        colors: colors,
                      ),
                      _buildFrequenciaOption(
                        tipo: TipoRecorrencia.segAVinco,
                        descricao: _descricaoPorTipo(
                          TipoRecorrencia.segAVinco,
                        ),
                        colors: colors,
                      ),
                      _buildFrequenciaOption(
                        tipo: TipoRecorrencia.semanal,
                        descricao: _descricaoPorTipo(
                          TipoRecorrencia.semanal,
                        ),
                        colors: colors,
                      ),
                      _buildFrequenciaOption(
                        tipo: TipoRecorrencia.mensal,
                        descricao: _descricaoPorTipo(
                          TipoRecorrencia.mensal,
                        ),
                        colors: colors,
                      ),
                      _buildFrequenciaOption(
                        tipo: TipoRecorrencia.anual,
                        descricao: _descricaoPorTipo(
                          TipoRecorrencia.anual,
                        ),
                        colors: colors,
                      ),
                      _buildFrequenciaOption(
                        tipo: TipoRecorrencia.personalizado,
                        descricao: _descricaoPorTipo(
                          TipoRecorrencia.personalizado,
                        ),
                        colors: colors,
                      ),
                      if (tipoSelecionado == TipoRecorrencia.personalizado)
                        _buildPersonalizadoOptions(colors),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: colors.azulAlba.withOpacity(0.10),
              ),
              _buildFooter(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Frequência',
              style: TextStyle(
                color: colors.azulAlba,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: colors.azulAlba,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.azulAlba,
            foregroundColor: colors.whiteColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _confirmar,
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequenciaOption({
    required TipoRecorrencia tipo,
    required String descricao,
    required AppColors colors,
  }) {
    final isSelected = tipoSelecionado == tipo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            tipoSelecionado = tipo;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.azulAlba.withOpacity(0.08)
                : colors.whiteColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.azulAlba : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.azulAlba.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRadioIndicator(isSelected, colors),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipo.label,
                      style: TextStyle(
                        color: colors.azulAlba,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      descricao,
                      style: TextStyle(
                        color: colors.greyFive,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioIndicator(bool isSelected, AppColors colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colors.neonGreen : colors.whiteColor,
        border: Border.all(
          color: isSelected ? colors.neonGreen : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              color: colors.azulAlba,
              size: 16,
            )
          : null,
    );
  }

  Widget _buildPersonalizadoOptions(AppColors colors) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.azulAlba.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.azulAlba.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecione os dias da semana',
            style: TextStyle(
              color: colors.azulAlba,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_diasSemana.length, (index) {
              final diaSemanaCompleto = _diasSemanaCompletos[index];

              final isSelected = (configuracaoTemp.diasSemana ?? []).contains(
                diaSemanaCompleto,
              );

              return _buildDiaChip(
                label: _diasSemana[index],
                isSelected: isSelected,
                colors: colors,
                onTap: () {
                  setState(() {
                    configuracaoTemp.diasSemana ??= [];

                    if (isSelected) {
                      configuracaoTemp.diasSemana!.remove(diaSemanaCompleto);
                    } else {
                      configuracaoTemp.diasSemana!.add(diaSemanaCompleto);
                    }
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaChip({
    required String label,
    required bool isSelected,
    required AppColors colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 48,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.neonGreen : colors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.neonGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colors.azulAlba : colors.greyFive,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}