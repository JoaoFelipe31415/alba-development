import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HorarioWidget extends StatelessWidget {
  final String? horarioInicio;
  final String? horarioFim;
  final void Function(String? inicio, String? fim) onChanged;

  const HorarioWidget({
    super.key,
    required this.horarioInicio,
    required this.horarioFim,
    required this.onChanged,
  });

  String? _normalizar(String? value) {
    final texto = value?.trim();

    if (texto == null || texto.isEmpty) {
      return null;
    }

    return texto;
  }

  TimeOfDay _converterParaTimeOfDay(String? value) {
    final texto = _normalizar(value);

    if (texto == null) {
      return TimeOfDay.now();
    }

    final partes = texto.split(':');

    if (partes.length != 2) {
      return TimeOfDay.now();
    }

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null || minuto == null) {
      return TimeOfDay.now();
    }

    if (hora < 0 || hora > 23 || minuto < 0 || minuto > 59) {
      return TimeOfDay.now();
    }

    return TimeOfDay(hour: hora, minute: minuto);
  }

  String _formatarHorario(TimeOfDay horario) {
    final hora = horario.hour.toString().padLeft(2, '0');
    final minuto = horario.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  Theme _buildTimePickerTheme({
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
          onSurface: colors.blackColor,
          secondary: colors.neonGreen,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: colors.whiteColor,
          hourMinuteColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return colors.azulAlba.withOpacity(0.10);
            }

            return colors.inputColor;
          }),
          hourMinuteTextColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return colors.azulAlba;
            }

            return colors.blackColor;
          }),
          dialBackgroundColor: colors.azulAlba.withOpacity(0.04),
          dialHandColor: colors.azulAlba,
          dialTextColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return colors.whiteColor;
            }

            return colors.blackColor;
          }),
          dayPeriodColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return colors.azulAlba;
            }

            return colors.inputColor;
          }),
          dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return colors.whiteColor;
            }

            return colors.azulAlba;
          }),
          entryModeIconColor: colors.azulAlba,
          helpTextStyle: TextStyle(
            color: colors.azulAlba,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
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

  Future<void> _selecionarHorario({
    required BuildContext context,
    required bool ehInicio,
  }) async {
    final appColors = Theme.of(context).extension<AppColors>();
    final colors = appColors ?? const AppColors();

    final valorAtual = ehInicio ? horarioInicio : horarioFim;

    final horarioSelecionado = await showTimePicker(
      context: context,
      initialTime: _converterParaTimeOfDay(valorAtual),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: _buildTimePickerTheme(
            context: context,
            colors: colors,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );

    if (horarioSelecionado == null) {
      return;
    }

    final horarioFormatado = _formatarHorario(horarioSelecionado);

    if (ehInicio) {
      onChanged(
        horarioFormatado,
        _normalizar(horarioFim),
      );
    } else {
      onChanged(
        _normalizar(horarioInicio),
        horarioFormatado,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>();
    final corPrincipal = appColors?.azulAlba ?? Theme.of(context).primaryColor;

    return Row(
      children: [
        Expanded(
          child: _CampoHorario(
            valor: _normalizar(horarioInicio),
            placeholder: 'Início',
            corPrincipal: corPrincipal,
            onTap: () => _selecionarHorario(
              context: context,
              ehInicio: true,
            ),
            onClear: () => onChanged(
              null,
              _normalizar(horarioFim),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'até',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: _CampoHorario(
            valor: _normalizar(horarioFim),
            placeholder: 'Fim',
            corPrincipal: corPrincipal,
            onTap: () => _selecionarHorario(
              context: context,
              ehInicio: false,
            ),
            onClear: () => onChanged(
              _normalizar(horarioInicio),
              null,
            ),
          ),
        ),
      ],
    );
  }
}

class _CampoHorario extends StatelessWidget {
  final String? valor;
  final String placeholder;
  final Color corPrincipal;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _CampoHorario({
    required this.valor,
    required this.placeholder,
    required this.corPrincipal,
    required this.onTap,
    required this.onClear,
  });

  bool get temValor {
    return valor != null && valor!.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: corPrincipal.withOpacity(0.6),
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                temValor ? valor! : placeholder,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: temValor ? Colors.black87 : Colors.grey.shade500,
                  fontSize: 15,
                  fontWeight: temValor ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (temValor)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}