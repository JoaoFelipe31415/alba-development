import 'package:alba/data/repositories/auth_repository.dart';
import 'package:alba/domain/dto/progresso_dto.dart';
import 'package:alba/data/repositories/progresso_repository.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/data/services/alba_insights_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/core/constants/calendar.dart';

class ProgressViewModel extends ChangeNotifier {
  final ProgressoRepository _repository = ProgressoRepository();
  final TarefasRepository _tarefasRepository = TarefasRepository();
  final AuthRepository _authRepository = AuthRepository();

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  bool isLoading = true;
  String currentFilter = 'Semana';
  ProgressDataModel? data;
  List<String> weeklyMood = ['⚪', '⚪', '⚪', '⚪', '⚪', '⚪', '⚪'];
  String emojiDestaque = "😊";

  bool get isMensal => currentFilter == "Mês";

  ProgressViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    final String? uid = _authRepository.currentUser?.uid;
    final agora = DateTime.now();

    DateTime dataInicio;
    DateTime dataFim = DateTime.now();

    if (isMensal) {
      dataInicio = DateTime(agora.year, agora.month, 1);
      dataFim = DateTime(agora.year, agora.month + 1, 0, 23, 59, 59);
    } else {
      dataInicio = agora.subtract(Duration(days: agora.weekday % 7));
      dataInicio = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);

      dataFim = dataInicio.add(
        const Duration(
          days: 6,
          hours: 23,
          minutes: 59,
          seconds: 59,
          milliseconds: 999,
        ),
      );
    }

    if (uid != null) {
      String idParaConsulta = uid;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .where('uid', isEqualTo: uid)
            .get();

        if (userDoc.docs.isNotEmpty) {
          final userData = userDoc.docs.first.data();
          if (userData['phone'] != null) {
            idParaConsulta = userData['phone'].toString();
          }
        }
      } catch (e) {
        print("Erro ao converter UID para Telefone: $e");
      }

      final dadosJson = await _repository.obterProgresso(idParaConsulta);
      data = ProgressDTO.fromFirestore(dadosJson ?? {});

      final monitoramentoPeriodo = await _repository.obterMonitoramentoPorData(
        idParaConsulta,
        dataInicio,
        dataFim,
      );

      final todasAsTarefas = await _tarefasRepository.obterTarefas();

      _processarEmojis(monitoramentoPeriodo, dataInicio);
      _processarGargalos(monitoramentoPeriodo, dataInicio, dataFim);

      final tarefasConcluidas = todasAsTarefas
          .where((tarefa) => tarefa.status.toLowerCase().trim() == 'concluida')
          .toList();

      _processarDistribuicaoFoco(
        tarefasConcluidas,
        monitoramentoPeriodo,
        dataInicio,
        dataFim,
      );

      _processarProdutividadePorPeriodo(todasAsTarefas, dataInicio, dataFim);
      _processarEstatisticasDescanso(monitoramentoPeriodo, dataInicio, dataFim);
      _gerarInsightsDaAlba(todasAsTarefas);
    } else {
      data = ProgressDTO.fromFirestore({});
      _gerarInsightsDaAlba([]);
    }

    if (_isDisposed) return;

    isLoading = false;
    notifyListeners();
  }

  void _gerarInsightsDaAlba(List<TarefaDto> tarefas) {
    if (data == null) return;

    final novosInsights = AlbaInsightsService.gerarInsights(
      data: data!,
      tarefas: tarefas,
      isMensal: isMensal,
      weeklyMood: weeklyMood,
      emojiDestaque: emojiDestaque,
    );

    data!.insights
      ..clear()
      ..addAll(novosInsights);
  }

  void _processarEmojis(
    List<Map<String, dynamic>> monitoramento,
    DateTime dataInicio,
  ) {
    int tamanhoLista = isMensal ? 4 : 7;
    weeklyMood = List.generate(tamanhoLista, (_) => '⚪');
    emojiDestaque = '⚪';

    List<List<String>> humoresPorSemanaDoMes = List.generate(4, (_) => []);

    for (var doc in monitoramento) {
      if (doc['data'] != null) {
        DateTime dataResposta;

        if (doc['data'] is Timestamp) {
          dataResposta = (doc['data'] as Timestamp).toDate();
        } else if (doc['data'] is DateTime) {
          dataResposta = doc['data'] as DateTime;
        } else {
          continue;
        }

        if (dataResposta.isAfter(dataInicio) ||
            dataResposta.isAtSameMomentAs(dataInicio)) {
          String emojiEncontrado = mapMood(doc['sentimento'] ?? "");
          if (emojiEncontrado == '⚪') continue;

          if (isMensal) {
            int diferencaDias = dataResposta.difference(dataInicio).inDays;
            int indexSemana = diferencaDias ~/ 7;

            if (indexSemana > 3) indexSemana = 3;
            if (indexSemana < 0) indexSemana = 0;

            humoresPorSemanaDoMes[indexSemana].add(emojiEncontrado);
          } else {
            int indiceDia = dataResposta.weekday % 7;
            weeklyMood[indiceDia] = emojiEncontrado;
          }
        }
      }
    }
    if (isMensal) {
      for (int i = 0; i < 4; i++) {
        final listaDaSemana = humoresPorSemanaDoMes[i];
        if (listaDaSemana.isNotEmpty) {
          final contagemSemanal = <String, int>{};
          for (final emoji in listaDaSemana) {
            contagemSemanal[emoji] = (contagemSemanal[emoji] ?? 0) + 1;
          }
          weeklyMood[i] = contagemSemanal.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
        }
      }
    }
    if (weeklyMood.any((emoji) => emoji != "⚪")) {
      final contagemGeral = <String, int>{};

      if (isMensal) {
        for (var lista in humoresPorSemanaDoMes) {
          for (var emoji in lista) {
            contagemGeral[emoji] = (contagemGeral[emoji] ?? 0) + 1;
          }
        }
      } else {
        for (final emoji in weeklyMood) {
          if (emoji != "⚪") {
            contagemGeral[emoji] = (contagemGeral[emoji] ?? 0) + 1;
          }
        }
      }

      if (contagemGeral.isNotEmpty) {
        emojiDestaque = contagemGeral.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;
      }
    }
  }

  String get feedbackBemEstar {
    if (isMensal) {
      return "Neste mês, seu humor predominante foi $emojiDestaque. Manter a constância é o segredo para equilibrar as tarefas.";
    }

    final frases = {
      "😃":
          "Sua semana foi incrível! Esse alto astral reflete diretamente na sua produtividade. Continue assim!",
      "😄":
          "Sua semana foi incrível! Esse alto astral reflete diretamente na sua produtividade. Continue assim!",
      "😊":
          "Boa semana! Você manteve o equilíbrio emocional mesmo com as demandas diárias. Isso é gestão de verdade.",
      "😐":
          "Uma semana estável. Se sentir que a rotina está ficando pesada, não esqueça de conferir seus horários de descanso.",
      "😔":
          "Notei que as coisas foram um pouco mais difíceis esses dias. Tente priorizar tarefas menores para não se sobrecarregar.",
      "😣":
          "Sinal de atenção. Seu estresse apareceu no período; reduza a carga e priorize o essencial.",
      "😫":
          "Sinal vermelho! 🚨 Sua exaustão está alta. Que tal delegar algo ou revisar seus prazos para a próxima semana?",
      "⚪": "Ainda não tenho dados suficientes sobre seu humor esta semana.",
    };

    return frases[emojiDestaque] ?? "Continue registrando seus dias!";
  }

  void _processarProdutividadePorPeriodo(
    List<TarefaDto> tarefas,
    DateTime dataInicio,
    DateTime dataFim,
  ) {
    if (data == null) return;

    if (isMensal) {
      List<int> planejadasMes = List.filled(4, 0);
      List<int> concluidasMes = List.filled(4, 0);

      for (var tarefa in tarefas) {
        final dentroDoPeriodo =
            (tarefa.dataCriacao.isAfter(dataInicio) ||
                tarefa.dataCriacao.isAtSameMomentAs(dataInicio)) &&
            (tarefa.dataCriacao.isBefore(dataFim) ||
                tarefa.dataCriacao.isAtSameMomentAs(dataFim));

        if (dentroDoPeriodo) {
          int diferencaDias = tarefa.dataCriacao.difference(dataInicio).inDays;
          int indexSemana = diferencaDias ~/ 7;

          if (indexSemana > 3) indexSemana = 3;
          if (indexSemana < 0) indexSemana = 0;

          planejadasMes[indexSemana]++;

          if (tarefa.status.toLowerCase().trim() == 'concluida') {
            concluidasMes[indexSemana]++;
          }
        }
      }

      int totalP = planejadasMes.reduce((a, b) => a + b);
      int totalC = concluidasMes.reduce((a, b) => a + b);

      data!.completionRate = totalP > 0 ? ((totalC / totalP) * 100).round() : 0;

      data!.weeklyProductivity = List.generate(4, (i) {
        return BarDataModel(
          label: "Sem ${i + 1}",
          value: concluidasMes[i],
          attributed: planejadasMes[i],
          colorHex: "0xFF6366F1",
        );
      });
    } else {
      List<int> planejadas = List.filled(7, 0);
      List<int> concluidas = List.filled(7, 0);

      for (var tarefa in tarefas) {
        bool dentroDoPeriodo =
            (tarefa.dataCriacao.isAfter(dataInicio) ||
                tarefa.dataCriacao.isAtSameMomentAs(dataInicio)) &&
            (tarefa.dataCriacao.isBefore(dataFim) ||
                tarefa.dataCriacao.isAtSameMomentAs(dataFim));

        if (dentroDoPeriodo) {
          int indexDia = tarefa.dataCriacao.weekday % 7;

          planejadas[indexDia]++;

          if (tarefa.status.toLowerCase().trim() == 'concluida') {
            concluidas[indexDia]++;
          }
        }
      }

      int totalP = planejadas.reduce((a, b) => a + b);
      int totalC = concluidas.reduce((a, b) => a + b);

      data!.completionRate = totalP > 0 ? ((totalC / totalP) * 100).round() : 0;

      data!.weeklyProductivity = List.generate(7, (i) {
        return BarDataModel(
          label: CalendarConstants.diasSemanaAbreviados[i],
          value: concluidas[i],
          attributed: planejadas[i],
          colorHex: "0xFF6366F1",
        );
      });
    }
  }

  @visibleForTesting
  static String mapMood(String sentiment) {
    final s = sentiment.toLowerCase().trim();

    if (s.contains('ótim') || s.contains('otim')) return '😃';
    if (s.contains('bem')) return '😊';
    if (s.contains('neutr')) return '😐';
    if (s.contains('cansad')) return '😔';
    if (s.contains('estressad')) return '😣';
    if (s.contains('exaust')) return '😫';

    return '⚪';
  }

  void _processarGargalos(
    List<Map<String, dynamic>> documentos,
    DateTime dataInicio,
    DateTime dataFim,
  ) {
    Map<String, int> contador = {
      'Procrastinação': 0,
      'Cansaço': 0,
      'Prazos da Faculdade': 0,
      'Demandas do Negócio': 0,
      'Outros': 0,
    };

    for (var doc in documentos) {
      DateTime? dataDoc;

      if (doc['data'] is Timestamp) {
        dataDoc = (doc['data'] as Timestamp).toDate();
      } else if (doc['data'] is DateTime) {
        dataDoc = doc['data'] as DateTime;
      }

      if (dataDoc != null) {
        bool depoisDoInicio =
            dataDoc.isAfter(dataInicio) || dataDoc.isAtSameMomentAs(dataInicio);
        bool antesDoFim =
            dataDoc.isBefore(dataFim) || dataDoc.isAtSameMomentAs(dataFim);

        if (depoisDoInicio && antesDoFim) {
          String? gargaloBruto = doc['gargaloPrincipal'];

          if (gargaloBruto != null && gargaloBruto.trim().isNotEmpty) {
            String chave = normalizarGargalo(gargaloBruto);

            if (contador.containsKey(chave)) {
              contador[chave] = contador[chave]! + 1;
            }
          }
        }
      }
    }

    data?.bottlenecks = contador.entries.map((entry) {
      return BarDataModel(
        label: entry.key,
        value: entry.value,
        colorHex: definirCorGargalo(entry.key),
        attributed: 0,
      );
    }).toList();

    data?.bottlenecks.sort((a, b) => b.value.compareTo(a.value));
  }

  @visibleForTesting
  static String definirCorGargalo(String label) {
    switch (label) {
      case 'Procrastinação':
        return "0xFFEF4444";
      case 'Cansaço':
        return "0xFFF59E0B";
      case 'Prazos da Faculdade':
        return "0xFF3B82F6";
      case 'Demandas do Negócio':
        return "0xFF10B981";
      case 'Outros':
        return "0xFF6B7280";
      default:
        return "0xFF6B7280";
    }
  }

  @visibleForTesting
  static String normalizarGargalo(String texto) {
    final t = texto.toLowerCase().trim();

    if (t.isEmpty) return '';
    if (t.contains('procrastinação') || t.contains('procrastinacao')) {
      return 'Procrastinação';
    }
    if (t.contains('cansaço') ||
        t.contains('cansaco') ||
        t.contains('cansad')) {
      return 'Cansaço';
    }
    if (t.contains('faculdade') || t.contains('universidade')) {
      return 'Prazos da Faculdade';
    }
    if (t.contains('negóc') || t.contains('negoc')) {
      return 'Demandas do Negócio';
    }
    return 'Outros';
  }

  String get feedbackGargalos {
    if (data == null || data!.bottlenecks.isEmpty) return "";

    final gargalosComValor = data!.bottlenecks
        .where((gargalo) => gargalo.value > 0)
        .toList();

    if (gargalosComValor.isEmpty) {
      return "Nenhum gargalo forte apareceu neste período. Continue acompanhando sua rotina para manter o controle.";
    }

    final maiorGargalo = gargalosComValor.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    final mensagens = {
      "Cansaço":
          "Notei que o cansaço é seu maior obstáculo hoje. Talvez seja hora de revisar suas horas de sono ou incluir pausas estratégicas.",
      "Procrastinação":
          "Identifiquei que a procrastinação apareceu bastante. Tente a técnica Pomodoro para quebrar a inércia nas tarefas.",
      "Prazos da Faculdade":
          "Los prazos da faculdade estão apertando! Vamos priorizar o que é urgente para aliviar essa pressão.",
      "Demandas do Negócio":
          "O crescimento do negócio está gerando muitos gargalos. Que tal organizar os processos para não se sobrecarregar?",
      "Outros":
          "Fatores externos ou imprevistos personalizados ganharam destaque nesta semana. Vale a pena refletir sobre o que tirou seu foco.",
    };

    return mensagens[maiorGargalo.label] ??
        "Identifiquei gargalos que podem estar travando seu progresso. Vamos ajustar o planejamento?";
  }

  void _processarDistribuicaoFoco(
    List<TarefaDto> tarefas,
    List<Map<String, dynamic>> monitoramento,
    DateTime dataInicio,
    DateTime dataFim,
  ) {
    Set<String> diasUni = {};
    Set<String> diasNeg = {};
    Set<String> diasDescanso = {};

    for (var tarefa in tarefas) {
      if (tarefa.dataInicial == null) continue;

      DateTime dataInicial;
      if (tarefa.dataInicial is Timestamp) {
        dataInicial = (tarefa.dataInicial as Timestamp).toDate();
      } else if (tarefa.dataInicial is DateTime) {
        dataInicial = tarefa.dataInicial as DateTime;
      } else {
        dataInicial =
            DateTime.tryParse(tarefa.dataInicial.toString()) ?? DateTime.now();
      }

      bool dentroDoPeriodo =
          (dataInicial.isAfter(dataInicio) ||
              dataInicial.isAtSameMomentAs(dataInicio)) &&
          (dataInicial.isBefore(dataFim) ||
              dataInicial.isAtSameMomentAs(dataFim));

      if (dentroDoPeriodo) {
        String tag = (tarefa.tag ?? '').toLowerCase().trim();
        String diaChave =
            "${dataInicial.year}-${dataInicial.month}-${dataInicial.day}";

        if (tag.contains('universidade') || tag.contains('faculdade')) {
          diasUni.add(diaChave);
        } else if (tag.contains('negoc') ||
            tag.contains('negóc') ||
            tag.contains('negocio')) {
          diasNeg.add(diaChave);
        }
      }
    }

    for (var doc in monitoramento) {
      DateTime? dataDoc;

      if (doc['data'] is Timestamp) {
        dataDoc = (doc['data'] as Timestamp).toDate();
      } else if (doc['data'] is DateTime) {
        dataDoc = doc['data'] as DateTime;
      }

      if (dataDoc != null) {
        bool dentroDoPeriodoMonit =
            (dataDoc.isAfter(dataInicio) ||
                dataDoc.isAtSameMomentAs(dataInicio)) &&
            (dataDoc.isBefore(dataFim) || dataDoc.isAtSameMomentAs(dataFim));

        if (dentroDoPeriodoMonit && doc['tempoDescanso'] != null) {
          int minutos = extrairMinutos(doc['tempoDescanso'].toString());
          if (minutos > 0) {
            String diaChave = "${dataDoc.year}-${dataDoc.month}-${dataDoc.day}";
            diasDescanso.add(diaChave);
          }
        }
      }
    }

    data?.focusDistribution = [
      BarDataModel(
        label: "Universidade",
        value: diasUni.length,
        colorHex: "0xFF1D4ED8",
        attributed: 0,
      ),
      BarDataModel(
        label: "Negócio",
        value: diasNeg.length,
        colorHex: "0xFF84FA1E",
        attributed: 0,
      ),
      BarDataModel(
        label: "Descanso",
        value: diasDescanso.length,
        colorHex: "0xFFD946EF",
        attributed: 0,
      ),
    ];
  }

  String get feedbackFoco {
    if (data == null || data!.focusDistribution.isEmpty) {
      return "Carregando dados de foco...";
    }

    final focosComValor = data!.focusDistribution
        .where((foco) => foco.value > 0)
        .toList();

    if (focosComValor.isEmpty) {
      return "Ainda não identifiquei uma área dominante de foco neste período.";
    }

    final principal = focosComValor.reduce((a, b) => a.value > b.value ? a : b);

    final frases = {
      "Universidade":
          "Você focou principalmente em Universidade. Lembre-se de equilibrar todas as áreas.",
      "Negócio":
          "Sua veia empreendedora está pulsando, mas atenção! Cuidado para não deixar as matérias acumularem.",
      "Descanso":
          "Pausa merecida! Notei que você priorizou o descanso. Isso é essencial para evitar o burnout.",
    };

    return frases[principal.label] ??
        "Equilíbrio é tudo! Você está distribuindo bem suas energias.";
  }

  void _processarEstatisticasDescanso(
    List<Map<String, dynamic>> monitoramento,
    DateTime dataInicio,
    DateTime dataFim,
  ) {
    if (data == null) return;

    var documentosFiltrados = monitoramento.where((doc) {
      DateTime? dataDoc;

      if (doc['data'] is Timestamp) {
        dataDoc = (doc['data'] as Timestamp).toDate();
      } else if (doc['data'] is DateTime) {
        dataDoc = doc['data'] as DateTime;
      }

      if (dataDoc == null) return false;

      bool depoisDoInicio =
          dataDoc.isAfter(dataInicio) || dataDoc.isAtSameMomentAs(dataInicio);
      bool antesDoFim =
          dataDoc.isBefore(dataFim) || dataDoc.isAtSameMomentAs(dataFim);

      return depoisDoInicio && antesDoFim;
    }).toList();

    if (documentosFiltrados.isEmpty) {
      data!.restStats = {
        'Nenhum': 0,
        '30 minutos': 0,
        'Entre 1 e 2 horas': 0,
        'Mais de 2 horas': 0,
      };

      data!.mostFrequentRest = "Nenhum";
      return;
    }

    int contNenhum = 0;
    int cont30min = 0;
    int cont1a2h = 0;
    int contMais2h = 0;

    for (var doc in documentosFiltrados) {
      int minutos = extrairMinutos(doc['tempoDescanso']);

      if (minutos <= 0) {
        contNenhum++;
      } else if (minutos <= 45) {
        cont30min++;
      } else if (minutos <= 120) {
        cont1a2h++;
      } else {
        contMais2h++;
      }
    }

    double total = documentosFiltrados.length.toDouble();

    data!.restStats = {
      'Nenhum': (contNenhum / total) * 100,
      '30 minutos': (cont30min / total) * 100,
      'Entre 1 e 2 horas': (cont1a2h / total) * 100,
      'Mais de 2 horas': (contMais2h / total) * 100,
    };

    var contagens = {
      "Nenhum": contNenhum,
      "30 minutos": cont30min,
      "Entre 1 e 2 horas": cont1a2h,
      "Mais de 2 horas": contMais2h,
    };

    data!.mostFrequentRest = contagens.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  String get feedbackDescanso {
    if (data == null || data!.restStats.isEmpty) {
      return "Sem dados de descanso para este período.";
    }

    final frequente = data!.mostFrequentRest;

    if (frequente == "Nenhum" || frequente == "30 minutos") {
      return "😎 Você está se mantendo produtiva, mas com pouco tempo de descanso real. Pequenos adjustments podem melhorar sua energia para a UFRPE e o projeto ALBA!";
    }

    return "⚡ Excelente equilíbrio! Seu descanso está mantendo sua mente afiada, essencial para a sustentabilidade ao longo prazo.";
  }

  @visibleForTesting
  static int extrairMinutos(dynamic tempoRaw) {
    String texto = tempoRaw.toString().toLowerCase().trim();
    int valor = int.tryParse(texto.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    if (texto.contains('h') || texto.contains('hora')) {
      return valor * 60;
    }

    return valor;
  }

  void changeFilter(String newFilter) {
    if (currentFilter == newFilter) return;

    currentFilter = newFilter;
    data?.weeklyProductivity = [];

    loadData();
  }
}
