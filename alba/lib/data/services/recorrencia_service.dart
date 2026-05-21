import 'package:alba/domain/entities/recorrencia.dart';

class RecorrenciaService {
  static List<DateTime> gerarProximasOcorrencias({
    required DateTime dataInicial,
    required TipoRecorrencia tipo,
    required ConfiguracaoRecorrencia? configuracao,
    int quantidade = 12,
    int mesesProximos = 12,
  }) {
    if (quantidade <= 0) {
      return [];
    }

    final dataBase = _apenasData(dataInicial);

    final dataLimite = DateTime(
      dataBase.year,
      dataBase.month + mesesProximos,
      dataBase.day,
      23,
      59,
      59,
    );

    if (tipo == TipoRecorrencia.naoRepete) {
      return [dataBase];
    }

    switch (tipo) {
      case TipoRecorrencia.naoRepete:
        return [dataBase];

      case TipoRecorrencia.diaria:
        return _gerarDiarias(
          dataInicial: dataBase,
          dataLimite: dataLimite,
          quantidade: quantidade,
        );

      case TipoRecorrencia.segAVinco:
        return _gerarSegundaASexta(
          dataInicial: dataBase,
          dataLimite: dataLimite,
          quantidade: quantidade,
        );

      case TipoRecorrencia.semanal:
        return _gerarSemanais(
          dataInicial: dataBase,
          dataLimite: dataLimite,
          quantidade: quantidade,
        );

      case TipoRecorrencia.mensal:
        return _gerarMensais(
          dataInicial: dataBase,
          dataLimite: dataLimite,
          quantidade: quantidade,
        );

      case TipoRecorrencia.anual:
        return _gerarAnuais(
          dataInicial: dataBase,
          dataLimite: dataLimite,
          quantidade: quantidade,
        );

      case TipoRecorrencia.personalizado:
        return _gerarOcorrenciasPersonalizadas(
          dataInicial: dataBase,
          configuracao: configuracao,
          quantidade: quantidade,
          dataLimite: dataLimite,
        );
    }
  }

  static List<DateTime> _gerarDiarias({
    required DateTime dataInicial,
    required DateTime dataLimite,
    required int quantidade,
  }) {
    final ocorrencias = <DateTime>[];
    var dataAtual = dataInicial;

    while (ocorrencias.length < quantidade && !dataAtual.isAfter(dataLimite)) {
      ocorrencias.add(dataAtual);
      dataAtual = dataAtual.add(const Duration(days: 1));
    }

    return ocorrencias;
  }

  static List<DateTime> _gerarSegundaASexta({
    required DateTime dataInicial,
    required DateTime dataLimite,
    required int quantidade,
  }) {
    final ocorrencias = <DateTime>[];
    var dataAtual = dataInicial;

    while (ocorrencias.length < quantidade && !dataAtual.isAfter(dataLimite)) {
      final ehDiaUtil = dataAtual.weekday >= DateTime.monday &&
          dataAtual.weekday <= DateTime.friday;

      if (ehDiaUtil) {
        ocorrencias.add(dataAtual);
      }

      dataAtual = dataAtual.add(const Duration(days: 1));
    }

    return ocorrencias;
  }

  static List<DateTime> _gerarSemanais({
    required DateTime dataInicial,
    required DateTime dataLimite,
    required int quantidade,
  }) {
    final ocorrencias = <DateTime>[];
    var dataAtual = dataInicial;

    while (ocorrencias.length < quantidade && !dataAtual.isAfter(dataLimite)) {
      ocorrencias.add(dataAtual);
      dataAtual = dataAtual.add(const Duration(days: 7));
    }

    return ocorrencias;
  }

  static List<DateTime> _gerarMensais({
    required DateTime dataInicial,
    required DateTime dataLimite,
    required int quantidade,
  }) {
    final ocorrencias = <DateTime>[];
    var dataAtual = dataInicial;
    final diaPreferido = dataInicial.day;

    while (ocorrencias.length < quantidade && !dataAtual.isAfter(dataLimite)) {
      ocorrencias.add(dataAtual);
      dataAtual = _adicionarMesMantendoDia(dataAtual, diaPreferido);
    }

    return ocorrencias;
  }

  static List<DateTime> _gerarAnuais({
    required DateTime dataInicial,
    required DateTime dataLimite,
    required int quantidade,
  }) {
    final ocorrencias = <DateTime>[];
    var dataAtual = dataInicial;
    final diaPreferido = dataInicial.day;
    final mesPreferido = dataInicial.month;

    while (ocorrencias.length < quantidade && !dataAtual.isAfter(dataLimite)) {
      ocorrencias.add(dataAtual);
      dataAtual = _adicionarAnoMantendoDia(
        dataAtual,
        mesPreferido,
        diaPreferido,
      );
    }

    return ocorrencias;
  }

  static List<DateTime> _gerarOcorrenciasPersonalizadas({
    required DateTime dataInicial,
    required ConfiguracaoRecorrencia? configuracao,
    required int quantidade,
    required DateTime dataLimite,
  }) {
    final ocorrencias = <DateTime>[];

    final diasSemana = configuracao?.diasSemana;

    if (diasSemana == null || diasSemana.isEmpty) {
      return ocorrencias;
    }

    final diasSelecionados = diasSemana
        .map(_normalizarDia)
        .map(_weekdayFromString)
        .whereType<int>()
        .toSet();

    if (diasSelecionados.isEmpty) {
      return ocorrencias;
    }

    var dataAtual = dataInicial;

    while (ocorrencias.length < quantidade && !dataAtual.isAfter(dataLimite)) {
      if (diasSelecionados.contains(dataAtual.weekday)) {
        ocorrencias.add(dataAtual);
      }

      dataAtual = dataAtual.add(const Duration(days: 1));
    }

    return ocorrencias;
  }

  static DateTime _apenasData(DateTime data) {
    return DateTime(
      data.year,
      data.month,
      data.day,
    );
  }

  static DateTime _adicionarMesMantendoDia(
    DateTime data,
    int diaPreferido,
  ) {
    final proximoMes = DateTime(data.year, data.month + 1);
    final ultimoDiaDoMes = DateTime(
      proximoMes.year,
      proximoMes.month + 1,
      0,
    ).day;

    final dia = diaPreferido <= ultimoDiaDoMes
        ? diaPreferido
        : ultimoDiaDoMes;

    return DateTime(
      proximoMes.year,
      proximoMes.month,
      dia,
    );
  }

  static DateTime _adicionarAnoMantendoDia(
    DateTime data,
    int mesPreferido,
    int diaPreferido,
  ) {
    final proximoAno = data.year + 1;

    final ultimoDiaDoMes = DateTime(
      proximoAno,
      mesPreferido + 1,
      0,
    ).day;

    final dia = diaPreferido <= ultimoDiaDoMes
        ? diaPreferido
        : ultimoDiaDoMes;

    return DateTime(
      proximoAno,
      mesPreferido,
      dia,
    );
  }

  static String _normalizarDia(String dia) {
    return dia
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
        .replaceAll('ç', 'c');
  }

  static int? _weekdayFromString(String dia) {
    switch (dia) {
      case 'segunda':
        return DateTime.monday;
      case 'terca':
        return DateTime.tuesday;
      case 'quarta':
        return DateTime.wednesday;
      case 'quinta':
        return DateTime.thursday;
      case 'sexta':
        return DateTime.friday;
      case 'sabado':
        return DateTime.saturday;
      case 'domingo':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  static bool isHorarioValido(String? horario) {
    final texto = horario?.trim();

    if (texto == null || texto.isEmpty) {
      return false;
    }

    final partes = texto.split(':');

    if (partes.length != 2) {
      return false;
    }

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null || minuto == null) {
      return false;
    }

    if (hora < 0 || hora > 23) {
      return false;
    }

    if (minuto < 0 || minuto > 59) {
      return false;
    }

    return true;
  }

  static bool isIntervaloHorarioValido(String? inicio, String? fim) {
    final horarioInicio = inicio?.trim();
    final horarioFim = fim?.trim();

    final inicioVazio = horarioInicio == null || horarioInicio.isEmpty;
    final fimVazio = horarioFim == null || horarioFim.isEmpty;

    // Sem horário é permitido.
    if (inicioVazio && fimVazio) {
      return true;
    }

    // Se preencher um, precisa preencher os dois.
    if (inicioVazio || fimVazio) {
      return false;
    }

    if (!isHorarioValido(horarioInicio) || !isHorarioValido(horarioFim)) {
      return false;
    }

    return horarioEmMinutos(horarioFim) > horarioEmMinutos(horarioInicio);
  }

  static int horarioEmMinutos(String horario) {
    final partes = horario.trim().split(':');

    final hora = int.parse(partes[0]);
    final minuto = int.parse(partes[1]);

    return hora * 60 + minuto;
  }
}