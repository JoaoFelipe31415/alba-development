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
    if (value.isEmpty || value.trim().isEmpty) {
      return 'Preencha todos os campos obrigatórios.';
    }
    if (value.trim().length < 3) {
      return 'Deve conter pelo menos 3 caracteres';
    }
    if (value.trim().length > 100) {
      return 'Deve conter no máximo 100 caracteres';
    }
    return null;
  }

  static String? validateDias(List<String>? dias) {
    if (dias == null || dias.isEmpty) {
      return 'Selecione pelo menos um dia da semana.';
    }

    final diasInvalidos = dias.where((dia) => !diasPermitidos.contains(dia));
    if (diasInvalidos.isNotEmpty) {
      return 'Selecione apenas dias válidos da semana.';
    }

    return null;
  }

  static String? validateHorario(String? value) {
    if (value == null || value.isEmpty) {
      return null; // opcional
    }

    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    if (!regex.hasMatch(value)) {
      return 'Informe um horário válido no formato HH:MM.';
    }

    return null;
  }

  static String? validateMeta({required bool vincularMeta, String? metaId}) {
    if (vincularMeta && (metaId == null || metaId.isEmpty)) {
      return 'Preencha todos os campos obrigatórios.';
    }
    return null;
  }

  static bool isHorarioValido(String? value) {
    return validateHorario(value) == null;
  }

  static String? validateHorarioInicio(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return validateHorario(value);
  }

  static String? validateHorarioFim(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return validateHorario(value);
  }

  static String? validateIntervaloHorario(String? inicio, String? fim) {
    if ((inicio == null || inicio.isEmpty) && (fim == null || fim.isEmpty)) {
      return null;
    }

    if ((inicio == null || inicio.isEmpty) || (fim == null || fim.isEmpty)) {
      return 'Informe horário inicial e final válidos.';
    }

    if (validateHorario(inicio) != null || validateHorario(fim) != null) {
      return 'Informe horários válidos no formato HH:MM.';
    }

    final horaInicio = int.parse(inicio.split(':')[0]);
    final minutoInicio = int.parse(inicio.split(':')[1]);
    final horaFim = int.parse(fim.split(':')[0]);
    final minutoFim = int.parse(fim.split(':')[1]);

    final minutosInicio = horaInicio * 60 + minutoInicio;
    final minutosFim = horaFim * 60 + minutoFim;

    if (minutosFim <= minutosInicio) {
      return 'O horário final deve ser maior que o inicial.';
    }

    return null;
  }
}
