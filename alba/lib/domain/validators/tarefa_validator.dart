import 'package:alba/domain/entities/recorrencia.dart';

class TarefaValidator {
  static const List<String> diasPermitidos = [
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
  ];

  static String? validateTitulo(String value) {
    final titulo = value.trim();

    if (titulo.isEmpty) {
      return 'Preencha todos os campos obrigatórios.';
    }

    if (titulo.length < 3) {
      return 'Deve conter pelo menos 3 caracteres.';
    }

    if (titulo.length > 100) {
      return 'Deve conter no máximo 100 caracteres.';
    }

    return null;
  }

  static String? validateDias(
    List<String>? dias,
    TipoRecorrencia tipoRecorrencia,
  ) {
    if (tipoRecorrencia != TipoRecorrencia.personalizado) {
      return null;
    }

    if (dias == null || dias.isEmpty) {
      return 'Selecione pelo menos um dia da semana para a recorrência.';
    }

    final diasNormalizados = dias
        .map((dia) => dia.trim().toLowerCase())
        .where((dia) => dia.isNotEmpty)
        .toList();

    if (diasNormalizados.isEmpty) {
      return 'Selecione pelo menos um dia da semana para a recorrência.';
    }

    final diasInvalidos = diasNormalizados.where(
      (dia) => !diasPermitidos.contains(dia),
    );

    if (diasInvalidos.isNotEmpty) {
      return 'Selecione apenas dias válidos da semana.';
    }

    return null;
  }

  static String? validateHorario(String? value) {
    final horario = value?.trim();

    if (horario == null || horario.isEmpty) {
      return null;
    }

    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

    if (!regex.hasMatch(horario)) {
      return 'Informe um horário válido no formato HH:MM.';
    }

    return null;
  }

  static bool isHorarioValido(String? value) {
    return validateHorario(value) == null;
  }

  static String? validateHorarioInicio(String? value) {
    return validateHorario(value);
  }

  static String? validateHorarioFim(String? value) {
    return validateHorario(value);
  }

  static String? validateIntervaloHorario(String? inicio, String? fim) {
    final horarioInicio = inicio?.trim();
    final horarioFim = fim?.trim();

    final inicioVazio = horarioInicio == null || horarioInicio.isEmpty;
    final fimVazio = horarioFim == null || horarioFim.isEmpty;

    // Horário é opcional. Se os dois estiverem vazios, está tudo bem.
    if (inicioVazio && fimVazio) {
      return null;
    }

    // Mas se preencher um, precisa preencher os dois.
    if (inicioVazio || fimVazio) {
      return 'Informe horário inicial e final válidos.';
    }

    final erroInicio = validateHorario(horarioInicio);
    final erroFim = validateHorario(horarioFim);

    if (erroInicio != null || erroFim != null) {
      return 'Informe horários válidos no formato HH:MM.';
    }

    final minutosInicio = _converterHorarioParaMinutos(horarioInicio);
    final minutosFim = _converterHorarioParaMinutos(horarioFim);

    if (minutosInicio == null || minutosFim == null) {
      return 'Informe horários válidos no formato HH:MM.';
    }

    if (minutosFim <= minutosInicio) {
      return 'O horário final deve ser maior que o inicial.';
    }

    return null;
  }

  static String? validateMeta({
    required bool vincularMeta,
    String? metaId,
  }) {
    final id = metaId?.trim();

    if (vincularMeta && (id == null || id.isEmpty)) {
      return 'Preencha todos os campos obrigatórios.';
    }

    return null;
  }

  static int? _converterHorarioParaMinutos(String horario) {
    final partes = horario.split(':');

    if (partes.length != 2) {
      return null;
    }

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null || minuto == null) {
      return null;
    }

    return hora * 60 + minuto;
  }
}