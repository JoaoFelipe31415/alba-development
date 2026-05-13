import 'package:alba/domain/entities/recorrencia.dart';

class RecorrenciaService {
  static List<DateTime> gerarProximasOcorrencias({
    required DateTime dataInicial,
    required TipoRecorrencia tipo,
    required ConfiguracaoRecorrencia? configuracao,
    int quantidade = 12,
    int mesesProximos = 12,
  }) {
    final List<DateTime> ocorrencias = [];
    final dataLimite = DateTime.now().add(Duration(days: mesesProximos * 30));

    if (tipo == TipoRecorrencia.naoRepete) {
      return [dataInicial];
    }

    DateTime dataAtual = dataInicial;

    while (ocorrencias.length < quantidade && dataAtual.isBefore(dataLimite)) {
      switch (tipo) {
        case TipoRecorrencia.diaria:
          dataAtual = dataAtual.add(const Duration(days: 1));
          ocorrencias.add(dataAtual);
          break;

        case TipoRecorrencia.segAVinco:
          dataAtual = dataAtual.add(const Duration(days: 1));
          while (dataAtual.weekday > 5) {
            dataAtual = dataAtual.add(const Duration(days: 1));
          }
          ocorrencias.add(dataAtual);
          break;

        case TipoRecorrencia.semanal:
          dataAtual = dataAtual.add(const Duration(days: 7));
          ocorrencias.add(dataAtual);
          break;

        case TipoRecorrencia.mensal:
          final proximoMes = DateTime(
            dataAtual.year,
            dataAtual.month + 1,
            dataAtual.day,
          );
          if (proximoMes.month != dataAtual.month + 1) {
            dataAtual = DateTime(proximoMes.year, proximoMes.month, 0);
          } else {
            dataAtual = proximoMes;
          }
          ocorrencias.add(dataAtual);
          break;

        case TipoRecorrencia.anual:
          dataAtual = DateTime(
            dataAtual.year + 1,
            dataAtual.month,
            dataAtual.day,
          );
          ocorrencias.add(dataAtual);
          break;

        case TipoRecorrencia.personalizado:
          ocorrencias.addAll(
            _gerarOcorrenciasPersonalizadas(
              dataInicial: dataAtual,
              configuracao: configuracao!,
              quantidade: quantidade - ocorrencias.length,
              dataLimite: dataLimite,
            ),
          );
          return ocorrencias;

        default:
          break;
      }
    }

    return ocorrencias;
  }

  static List<DateTime> _gerarOcorrenciasPersonalizadas({
    required DateTime dataInicial,
    required ConfiguracaoRecorrencia configuracao,
    required int quantidade,
    required DateTime dataLimite,
  }) {
    final List<DateTime> ocorrencias = [];

    if (configuracao.diasSemana == null || configuracao.diasSemana!.isEmpty) {
      return ocorrencias;
    }

    final diasSemanaMap = {
      'domingo': DateTime.sunday,
      'segunda': DateTime.monday,
      'terca': DateTime.tuesday,
      'quarta': DateTime.wednesday,
      'quinta': DateTime.thursday,
      'sexta': DateTime.friday,
      'sabado': DateTime.saturday,
    };

    final diasSelecionados = configuracao.diasSemana!
        .map((dia) => diasSemanaMap[dia]!)
        .toSet();

    DateTime dataAtual = dataInicial;

    while (ocorrencias.length < quantidade && dataAtual.isBefore(dataLimite)) {
      dataAtual = dataAtual.add(const Duration(days: 1));
      if (diasSelecionados.contains(dataAtual.weekday)) {
        ocorrencias.add(dataAtual);
      }
    }

    return ocorrencias;
  }

  static bool isHorarioValido(String horario) {
    final partes = horario.split(':');
    if (partes.length != 2) return false;

    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);

    if (hora == null || minuto == null) return false;
    if (hora < 0 || hora > 23) return false;
    if (minuto < 0 || minuto > 59) return false;

    return true;
  }

  static bool isIntervaloHorarioValido(String? inicio, String? fim) {
    if (inicio == null || fim == null) return true; // Ambos opcionais
    if (inicio.isEmpty || fim.isEmpty) return true;

    if (!isHorarioValido(inicio) || !isHorarioValido(fim)) {
      return false;
    }

    final horaInicio = int.parse(inicio.split(':')[0]);
    final minutoInicio = int.parse(inicio.split(':')[1]);

    final horaFim = int.parse(fim.split(':')[0]);
    final minutoFim = int.parse(fim.split(':')[1]);

    final minutosInicio = horaInicio * 60 + minutoInicio;
    final minutosFim = horaFim * 60 + minutoFim;

    return minutosFim > minutosInicio;
  }

  // Converter horário em minutos desde meia-noite
  static int horarioEmMinutos(String horario) {
    final partes = horario.split(':');
    final hora = int.parse(partes[0]);
    final minuto = int.parse(partes[1]);
    return hora * 60 + minuto;
  }
}
