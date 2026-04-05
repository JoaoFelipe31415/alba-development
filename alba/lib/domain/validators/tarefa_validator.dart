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

  static String? validateMeta({
    required bool vincularMeta,
    String? metaId,
  }) {
    if (vincularMeta && (metaId == null || metaId.isEmpty)) {
      return 'Preencha todos os campos obrigatórios.';
    }
    return null;
  }

  static bool isHorarioValido(String? value) {
    return validateHorario(value) == null;
  }
}