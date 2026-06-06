class MetaValidator {
  static String? validateTitulo(String value) {
    final titulo = value.trim();

    if (titulo.isEmpty) {
      return 'Título é obrigatório';
    }

    if (titulo.length < 3) {
      return 'Deve conter pelo menos 3 caracteres';
    }

    if (titulo.length > 100) {
      return 'Deve conter no máximo 100 caracteres';
    }

    return null;
  }

  static String? validateDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.trim().length > 500) {
      return 'Deve conter no máximo 500 caracteres';
    }

    return null;
  }

  static String? validatePrazo(DateTime? value) {
    if (value == null) {
      return 'Prazo é obrigatório';
    }

    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    final prazoSemHora = DateTime(value.year, value.month, value.day);

    if (!prazoSemHora.isAfter(hojeSemHora)) {
      return 'Deve ser uma data futura';
    }

    return null;
  }

  static String? validatePrazoTexto(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Prazo é obrigatório';
    }

    final texto = value.trim();

    if (texto.length != 10 || texto[2] != '/' || texto[5] != '/') {
      return 'Formato inválido. Use DD/MM/AAAA';
    }

    final data = parseDate(texto);

    if (data == null) {
      return _mensagemDataInvalida(texto);
    }

    return validatePrazo(data);
  }

  static String? validateTag(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tag é obrigatória';
    }

    if (value != 'negocio' && value != 'faculdade') {
      return 'Tag inválida';
    }

    return null;
  }

  static bool isValidDate(String? dateString) {
    return parseDate(dateString ?? '') != null;
  }

  static DateTime? parseDate(String dateString) {
    try {
      final texto = dateString.trim();

      if (texto.length != 10 || texto[2] != '/' || texto[5] != '/') {
        return null;
      }

      final parts = texto.split('/');
      if (parts.length != 3) {
        return null;
      }

      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day == null || month == null || year == null) {
        return null;
      }

      if (year < 1900 || year > 2100) {
        return null;
      }

      if (month < 1 || month > 12) {
        return null;
      }

      if (day < 1 || day > _daysInMonth(year, month)) {
        return null;
      }

      final date = DateTime(year, month, day);

      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }

      return date;
    } catch (_) {
      return null;
    }
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    }

    const monthsWithThirtyDays = [4, 6, 9, 11];

    if (monthsWithThirtyDays.contains(month)) {
      return 30;
    }

    return 31;
  }

  static bool _isLeapYear(int year) {
    if (year % 400 == 0) {
      return true;
    }

    if (year % 100 == 0) {
      return false;
    }

    return year % 4 == 0;
  }

  static String _mensagemDataInvalida(String texto) {
    try {
      final parts = texto.split('/');

      if (parts.length != 3) {
        return 'Data inválida';
      }

      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day == null || month == null || year == null) {
        return 'Data inválida';
      }

      if (month < 1 || month > 12) {
        return 'Mês inválido';
      }

      if (day < 1) {
        return 'Dia inválido';
      }

      final maxDays = _daysInMonth(year, month);

      if (day > maxDays) {
        final nomeMes = _nomeDoMes(month);
        return '$nomeMes não possui $day dias';
      }

      return 'Data inválida';
    } catch (_) {
      return 'Data inválida';
    }
  }

  static String _nomeDoMes(int month) {
    const meses = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    if (month < 1 || month > 12) {
      return 'O mês informado';
    }

    return meses[month];
  }
}