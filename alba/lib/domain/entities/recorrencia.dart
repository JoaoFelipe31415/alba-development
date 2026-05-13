// Enum para tipos de recorrência
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

  String get value {
    return name;
  }

  static TipoRecorrencia fromString(String value) {
    return TipoRecorrencia.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoRecorrencia.naoRepete,
    );
  }
}

class ConfiguracaoRecorrencia {
  List<String>? diasSemana;

  int? intervaloEmDias;

  ConfiguracaoRecorrencia({this.diasSemana, this.intervaloEmDias});

  Map<String, dynamic> toMap() {
    return {'diasSemana': diasSemana, 'intervaloEmDias': intervaloEmDias};
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
