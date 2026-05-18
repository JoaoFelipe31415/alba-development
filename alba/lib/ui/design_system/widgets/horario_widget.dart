import 'package:flutter/material.dart';

class HorarioWidget extends StatefulWidget {
  final String? horarioInicio;
  final String? horarioFim;
  final Function(String? inicio, String? fim) onChanged;

  const HorarioWidget({
    required this.horarioInicio,
    required this.horarioFim,
    required this.onChanged,
    super.key,
  });

  @override
  State<HorarioWidget> createState() => _HorarioWidgetState();
}

class _HorarioWidgetState extends State<HorarioWidget> {
  late TextEditingController inicioController;
  late TextEditingController fimController;

  @override
  void initState() {
    super.initState();
    inicioController = TextEditingController(text: widget.horarioInicio ?? '');
    fimController = TextEditingController(text: widget.horarioFim ?? '');
  }

  @override
  void didUpdateWidget(covariant HorarioWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.horarioInicio != oldWidget.horarioInicio) {
      inicioController.text = widget.horarioInicio ?? '';
    }
    if (widget.horarioFim != oldWidget.horarioFim) {
      fimController.text = widget.horarioFim ?? '';
    }
  }

  @override
  void dispose() {
    inicioController.dispose();
    fimController.dispose();
    super.dispose();
  }

  Future<void> _selecionarHorario(
    TextEditingController controller,
    bool isInicio,
  ) async {
    final agora = TimeOfDay.now();

    TimeOfDay initialTime = agora;

    if (controller.text.isNotEmpty) {
      final partes = controller.text.split(':');
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
      final horarioFormatado = '$hora:$minuto';

      setState(() {
        controller.text = horarioFormatado;
      });

      widget.onChanged(
        inicioController.text.isEmpty ? null : inicioController.text,
        fimController.text.isEmpty ? null : fimController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horário da tarefa (opcional)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selecionarHorario(inicioController, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inicioController.text.isEmpty
                              ? 'Início'
                              : inicioController.text,
                          style: TextStyle(
                            color: inicioController.text.isEmpty
                                ? Colors.grey[600]
                                : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'até',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selecionarHorario(fimController, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fimController.text.isEmpty
                              ? 'Fim'
                              : fimController.text,
                          style: TextStyle(
                            color: fimController.text.isEmpty
                                ? Colors.grey[600]
                                : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
