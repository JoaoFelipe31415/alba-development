import 'package:alba/domain/entities/recorrencia.dart';
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E1E1E),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FREQUÊNCIA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800]),
            // Conteúdo
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFrequenciaOption(
                        TipoRecorrencia.naoRepete,
                        'A tarefa será exibida apenas uma vez na data selecionada.',
                      ),
                      _buildFrequenciaOption(
                        TipoRecorrencia.diaria,
                        'A tarefa será repetida todos os dias.',
                      ),
                      _buildFrequenciaOption(
                        TipoRecorrencia.segAVinco,
                        'A tarefa será repetida de segunda a sexta-feira.',
                      ),
                      _buildFrequenciaOption(
                        TipoRecorrencia.semanal,
                        'A tarefa será repetida semanalmente na mesma data.',
                      ),
                      _buildFrequenciaOption(
                        TipoRecorrencia.mensal,
                        'A tarefa será repetida mensalmente na mesma data.',
                      ),
                      _buildFrequenciaOption(
                        TipoRecorrencia.anual,
                        'A tarefa será repetida anualmente na mesma data.',
                      ),
                      _buildFrequenciaOption(
                        TipoRecorrencia.personalizado,
                        'Configure parâmetros avançados de repetição.',
                      ),
                      if (tipoSelecionado == TipoRecorrencia.personalizado)
                        _buildPersonalizadoOptions(),
                    ],
                  ),
                ),
              ),
            ),
            Divider(color: Colors.grey[800]),
            // Botão OK
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBD00FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    widget.onConfirm(
                      tipoSelecionado,
                      tipoSelecionado == TipoRecorrencia.personalizado
                          ? configuracaoTemp
                          : null,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequenciaOption(TipoRecorrencia tipo, String descricao) {
    final isSelected = tipoSelecionado == tipo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            tipoSelecionado = tipo;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFBD00FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFFBD00FF) : Colors.grey[700]!,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tipo.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descricao,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalizadoOptions() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecione os dias da semana:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
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

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      configuracaoTemp.diasSemana!.remove(diaSemanaCompleto);
                    } else {
                      configuracaoTemp.diasSemana ??= [];
                      configuracaoTemp.diasSemana!.add(diaSemanaCompleto);
                    }
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFBD00FF)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _diasSemana[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
