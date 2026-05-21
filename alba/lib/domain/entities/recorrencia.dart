enum TipoRecorrencia {
  naoRepete,
  diaria,
  segAVinco,
  semanal,
  mensal,
  anual,
  personalizado;

  String get label {
    switch (this) {
      case TipoRecorrencia.naoRepete:
        return 'Não repete';
      case TipoRecorrencia.diaria:
        return 'Diária';
      case TipoRecorrencia.segAVinco:
        return 'Seg à Sex';
      case TipoRecorrencia.semanal:
        return 'Semanal';
      case TipoRecorrencia.mensal:
        return 'Mensal';
      case TipoRecorrencia.anual:
        return 'Anual';
      case TipoRecorrencia.personalizado:
        return 'Personalizado';
    }
  }

  /// Valor estável para salvar no Firestore.
  /// Não use label com acento/espaço no banco.
  String get value {
    switch (this) {
      case TipoRecorrencia.naoRepete:
        return 'naoRepete';
      case TipoRecorrencia.diaria:
        return 'diaria';
      case TipoRecorrencia.segAVinco:
        return 'segAVinco';
      case TipoRecorrencia.semanal:
        return 'semanal';
      case TipoRecorrencia.mensal:
        return 'mensal';
      case TipoRecorrencia.anual:
        return 'anual';
      case TipoRecorrencia.personalizado:
        return 'personalizado';
    }
  }

  /// Lê tanto valores novos quanto valores antigos do Firestore.
  static TipoRecorrencia fromString(String? value) {
    final texto = _normalizar(value);

    switch (texto) {
      case 'naorepete':
      case 'naorepetir':
        return TipoRecorrencia.naoRepete;

      case 'diaria':
      case 'diario':
        return TipoRecorrencia.diaria;

      case 'segavinco':
      case 'segasex':
      case 'segundaasexta':
      case 'segundaasextafeira':
        return TipoRecorrencia.segAVinco;

      case 'semanal':
        return TipoRecorrencia.semanal;

      case 'mensal':
        return TipoRecorrencia.mensal;

      case 'anual':
        return TipoRecorrencia.anual;

      case 'personalizado':
      case 'personalizada':
        return TipoRecorrencia.personalizado;

      default:
        return TipoRecorrencia.naoRepete;
    }
  }

  static String _normalizar(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

class ConfiguracaoRecorrencia {
  List<String>? diasSemana;
  int? intervaloEmDias;

  ConfiguracaoRecorrencia({
    this.diasSemana,
    this.intervaloEmDias,
  });

  Map<String, dynamic> toMap() {
    return {
      'diasSemana': diasSemana,
      'intervaloEmDias': intervaloEmDias,
    };
  }

  factory ConfiguracaoRecorrencia.fromMap(Map<String, dynamic>? data) {
    if (data == null) return ConfiguracaoRecorrencia();

    return ConfiguracaoRecorrencia(
      diasSemana: List<String>.from(data['diasSemana'] ?? []),
      intervaloEmDias: data['intervaloEmDias'],
    );
  }

  bool get isEmpty {
    return (diasSemana == null || diasSemana!.isEmpty) &&
        intervaloEmDias == null;
  }
}