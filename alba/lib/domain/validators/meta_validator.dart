class MetaValidator {
  static String? validateTitulo(String value) {
    if (value.isEmpty) {
      return 'Título é obrigatório';
    }
    if (value.trim().isEmpty) {
      return 'Não pode conter apenas espaços';
    }
    if (value.trim().length < 3) {
      return 'Deve conter pelo menos 3 caracteres';
    }
    if (value.trim().length > 100) {
      return 'Deve conter no máximo 100 caracteres';
    }
    return null;
  }

  static String? validateDescricao(String? value) {
    if (value != null && value.length > 500) {
      return 'Deve conter no máximo 500 caracteres';
    }
    return null;
  }

  static String? validatePrazo(DateTime? value) {
    if (value == null) {
      return 'Prazo é obrigatório';
    }
    if (!value.isAfter(DateTime.now())) {
      return 'Deve ser uma data futura';
    }
    return null;
  }

  static String? validateTag(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tag é obrigatória';
    }
    if (value != 'negocio' && value != 'faculdade') {
      return 'Tag inválida';
    }
    return null;
  }

  static bool isValidDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;
    try {
      // Esperado formato DD/MM/YYYY
      List<String> parts = dateString.split('/');
      if (parts.length != 3) return false;

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      DateTime date = DateTime(year, month, day);
      return date.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  static DateTime? parseDate(String dateString) {
    try {
      List<String> parts = dateString.split('/');
      if (parts.length != 3) return null;

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
