import 'package:alba/data/repositories/auth_repository.dart';
import 'package:alba/domain/dto/progresso_dto.dart';
import 'package:alba/data/repositories/progresso_repository.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/core/constants/calendar.dart';

class ProgressViewModel extends ChangeNotifier {
  final ProgressoRepository _repository = ProgressoRepository();
  final TarefasRepository _tarefasRepository = TarefasRepository(); 
  final AuthRepository _authRepository = AuthRepository();

  bool isLoading = true;
  String currentFilter = 'Semana';
  ProgressDataModel? data;
  List<String> weeklyMood = ['⚪', '⚪', '⚪', '⚪', '⚪', '⚪', '⚪'];
  String emojiDestaque = "😐";

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
  
  if (isMensal) {

    dataInicio = DateTime(agora.year, agora.month, 1);

  } else {

    dataInicio = agora.subtract(Duration(days: agora.weekday % 7));
    dataInicio = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
  }

  if (uid != null) {
    final dadosJson = await _repository.obterProgresso(uid);
    data = ProgressDTO.fromFirestore(dadosJson ?? {});

    final monitoramentoPeriodo = await _repository.obterMonitoramentoPorData(uid, dataInicio);
    final todasAsTarefas = await _tarefasRepository.obterTarefas();

    _processarEmojis(monitoramentoPeriodo, dataInicio);
    
    _processarGargalos(monitoramentoPeriodo, dataInicio);

    final tarefasConcluidas = todasAsTarefas.where((t) => t.status == 'concluida').toList();
    _processarDistribuicaoFoco(tarefasConcluidas, monitoramentoPeriodo, dataInicio);

    _processarProdutividadePorPeriodo(todasAsTarefas, dataInicio);

    _processarEstatisticasDescanso(monitoramentoPeriodo, dataInicio);

  } else {
    data = ProgressDTO.fromFirestore({});
  }

  isLoading = false;
  notifyListeners();
}

  void _processarEmojis(List<Map<String, dynamic>> monitoramento, DateTime inicioSemana) {
    weeklyMood = List.generate(7, (_) => '⚪');
    for (var doc in monitoramento) {
      if (doc['data'] != null) {
        DateTime dataResposta = (doc['data'] as Timestamp).toDate();
        // Filtra para garantir que o emoji é desta semana
        if (dataResposta.isAfter(inicioSemana)) {
          int indiceDia = dataResposta.weekday % 7;
          weeklyMood[indiceDia] = _mapMood(doc['sentimento'] ?? "");
        }

        if (weeklyMood.any((e) => e != "⚪")) {
    var contagem = <String, int>{};
    for (var e in weeklyMood) {
      if (e != "⚪") contagem[e] = (contagem[e] ?? 0) + 1;
    }

    emojiDestaque = contagem.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

        notifyListeners();
        }
      }
    }
  }

String get feedbackBemEstar {

if (isMensal) {
    return "Neste mês, seu humor predominante foi $emojiDestaque. Manter a constância é o segredo para equilibrar as tarefas.";
  }

  final frases = {
    "😄": "Sua semana foi incrível! Esse alto astral reflete diretamente na sua produtividade. Continue assim!",
    "😊": "Boa semana! Você manteve o equilíbrio emocional mesmo com as demandas diárias. Isso é gestão de verdade.",
    "😐": "Uma semana estável. Se sentir que a rotina está ficando pesada, não esqueça de conferir seus horários de descanso.",
    "😔": "Notei que as coisas foram um pouco mais difíceis esses dias. Tente priorizar tarefas menores para não se sobrecarregar.",
    "😫": "Sinal vermelho! 🚨 Sua exaustão está alta. Que tal delegar algo ou revisar seus prazos para a próxima semana?",
    "⚪": "Ainda não tenho dados suficientes sobre seu humor esta semana."
  };
  
  return frases[emojiDestaque] ?? "Continue registrando seus dias!";
}

void _processarProdutividadePorPeriodo(List<TarefaDto> tarefas, DateTime dataInicio) {
  if (data == null) return;

  if (isMensal) {
 
    List<int> planejadasMes = List.filled(4, 0);
    List<int> concluidasMes = List.filled(4, 0);

    for (var tarefa in tarefas) {
      if (tarefa.dataCriacao.isAfter(dataInicio) || tarefa.dataCriacao.isAtSameMomentAs(dataInicio)) {
        int diferencaDias = tarefa.dataCriacao.difference(dataInicio).inDays;
        
        int indexSemana = diferencaDias ~/ 7;
        
        if (indexSemana > 3) indexSemana = 3;

        planejadasMes[indexSemana]++;
        if (tarefa.status == 'concluida') {
          concluidasMes[indexSemana]++;
        }
      }
    }

    int totalP = planejadasMes.reduce((a, b) => a + b);
    int totalC = concluidasMes.reduce((a, b) => a + b);
    data!.completionRate = totalP > 0 ? ((totalC / totalP) * 100).round() : 0;

    // Gera as 4 barras para o gráfico
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
      if (tarefa.dataCriacao.isAfter(dataInicio) || tarefa.dataCriacao.isAtSameMomentAs(dataInicio)) {
        int indexDia = tarefa.dataCriacao.weekday % 7;
        planejadas[indexDia]++;
        if (tarefa.status == 'concluida') {
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
  
  notifyListeners();
}

  String _mapMood(String sentiment) {
    switch (sentiment.toLowerCase().trim()) {
      case 'ótimo': return '🤩'; // Sugestão: 🤩 para Ótimo e 🙂 para Bem
      case 'bem': return '😊';
      case 'neutro': return '😐';
      case 'cansado(a)': return '😔';
      case 'estressado(a)': return '😣';
      default: return '⚪';
    }
  }

void _processarGargalos(List<Map<String, dynamic>> documentos, DateTime dataInicio) {
  Map<String, int> contador = {
    'Procrastinação': 0,
    'Cansaço': 0,
    'Prazos da Faculdade': 0,
    'Demandas do Negócio': 0,
  };

  for (var doc in documentos) {
    DateTime? dataDoc;
    if (doc['data'] is Timestamp) {
      dataDoc = (doc['data'] as Timestamp).toDate();
    } else if (doc['data'] is DateTime) {
      dataDoc = doc['data'] as DateTime;
    }

    if (dataDoc != null && (dataDoc.isAfter(dataInicio) || dataDoc.isAtSameMomentAs(dataInicio))) {
      String? gargaloBruto = doc['gargaloPrincipal']; 
      
      if (gargaloBruto != null) {
        String chave = _normalizarGargalo(gargaloBruto);
        if (contador.containsKey(chave)) {
          contador[chave] = contador[chave]! + 1;
        }
      }
    }
  }

  data?.bottlenecks = contador.entries.map((entry) {
    return BarDataModel(
      label: entry.key,
      value: entry.value,
      colorHex: _definirCorGargalo(entry.key),
      attributed: 0,
    );
  }).toList();

  data?.bottlenecks.sort((a, b) => b.value.compareTo(a.value));
  
  notifyListeners();
}

String _definirCorGargalo(String label) {
  switch (label) {
    case 'Procrastinação': return "0xFFEF4444"; // Vermelho
    case 'Cansaço': return "0xFFF59E0B"; // Laranja
    case 'Prazos da Faculdade': return "0xFF3B82F6"; // Azul
    case 'Demandas do Negócio': return "0xFF10B981"; // Verde
    default: return "0xFF6B7280"; // Cinza
  }
}

  String _normalizarGargalo(String texto) {
    final t = texto.toLowerCase();
    if (t.contains('procrastinação')) return 'Procrastinação';
    if (t.contains('cansaço')) return 'Cansaço';
    if (t.contains('faculdade')) return 'Prazos da Faculdade';
    if (t.contains('negócio')) return 'Demandas do Negócio';
    return '';
  }

  String get feedbackGargalos {
  if (data == null || data!.bottlenecks.isEmpty) return "";

  final maiorGargalo = data!.bottlenecks.reduce((a, b) => a.value > b.value ? a : b);
  
  final mensagens = {
    "Cansaço": "Notei que o cansaço é seu maior obstáculo hoje. Talvez seja hora de revisar suas horas de sono ou incluir pausas estratégicas.",
    "Procrastinação": "Identifiquei que a procrastinação apareceu bastante. Tente a técnica Pomodoro para quebrar a inércia nas tarefas.",
    "Prazos da Faculdade": "Os prazos da faculdade estão apertando! Vamos priorizar o que é urgente para aliviar essa pressão.",
    "Demandas do Negócio": "O crescimento do negócio está gerando muitos gargalos. Que tal organizar os processos para não se sobrecarregar?",
  };

  return mensagens[maiorGargalo.label] ?? "Identifiquei gargalos que podem estar travando seu progresso. Vamos ajustar o planejamento?";
}

void _processarDistribuicaoFoco(
    List<TarefaDto> tarefas, 
    List<Map<String, dynamic>> monitoramento, 
    DateTime dataInicio) { // 👈 Recebemos a data de corte aqui

  int contagemUni = 0;
  int contagemNeg = 0;
  int totalDescanso = 0;

  for (var tarefa in tarefas) {

    if (tarefa.dataCriacao.isAfter(dataInicio) || tarefa.dataCriacao.isAtSameMomentAs(dataInicio)) {
      String tag = (tarefa.tag ?? '').toLowerCase().trim();
      
      if (tag.contains('universidade') || tag.contains('faculdade')) {
        contagemUni++;
      } else if (tag.contains('negoc') || tag.contains('negóc')) {
        contagemNeg++;
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

  if (dataDoc != null && (dataDoc.isAfter(dataInicio) || dataDoc.isAtSameMomentAs(dataInicio))) {
    if (doc['tempoDescanso'] != null) {
      int minutos = _extrairMinutos(doc['tempoDescanso']);
      totalDescanso += (minutos / 60).round();
    }
  }
  }

  data?.focusDistribution = [
    BarDataModel(
      label: "Universidade", 
      value: contagemUni, 
      colorHex: "0xFF1D4ED8", // Azul
      attributed: 0,
    ),
    BarDataModel(
      label: "Negócio", 
      value: contagemNeg, 
      colorHex: "0xFF84FA1E", // Verde Lima
      attributed: 0,
    ),
    BarDataModel(
      label: "Descanso", 
      value: totalDescanso, 
      colorHex: "0xFFD946EF", // Rosa/Fúcsia
      attributed: 0,
    ),
  ];
  
  notifyListeners();
}


String get feedbackFoco {
  if (data == null || data!.focusDistribution.isEmpty) return "Carregando dados de foco...";

  final principal = data!.focusDistribution.reduce((a, b) => a.value > b.value ? a : b);
  
  final frases = {
    "Universidade": "Você focou principalmente em Universidade. Lembre-se de equilibrar todas as áreas.",
    "Negócio": "Sua veia empreendedora está pulsando, mas atenção! Cuidado para não deixar as matérias acumularem.",
    "Descanso": "Pausa merecida! Notei que você priorizou o descanso. Isso é essencial para evitar o burnout.",
  };

  return frases[principal.label] ?? "Equilíbrio é tudo! Você está distribuindo bem suas energias.";
}

void _processarEstatisticasDescanso(List<Map<String, dynamic>> monitoramento, DateTime dataInicio) {
  if (data == null) return;

  var documentosFiltrados = monitoramento.where((doc) {
    DateTime? dataDoc;
    if (doc['data'] is Timestamp) {
      dataDoc = (doc['data'] as Timestamp).toDate();
    } else if (doc['data'] is DateTime) {
      dataDoc = doc['data'] as DateTime;
    }
    return dataDoc != null && (dataDoc.isAfter(dataInicio) || dataDoc.isAtSameMomentAs(dataInicio));
  }).toList();

  if (documentosFiltrados.isEmpty) {
    data!.restStats = {'Nenhum': 0, '30 minutos': 0, 'Entre 1 e 2 horas': 0, 'Mais de 2 horas': 0};
    data!.mostFrequentRest = "Nenhum";
    notifyListeners();
    return;
  }

  int contNenhum = 0;
  int cont30min = 0; 
  int cont1a2h = 0; 
  int contMais2h = 0;

  for (var doc in documentosFiltrados) {
    int minutos = _extrairMinutos(doc['tempoDescanso']);

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
    "Mais de 2 horas": contMais2h
  };
  
  data!.mostFrequentRest = contagens.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key;

  notifyListeners();
}


String get feedbackDescanso {
  if (data == null || data!.restStats.isEmpty) return "Sem dados de descanso para este período.";

  final frequente = data!.mostFrequentRest;

  if (frequente == "Nenhum" || frequente == "30 minutos") {
    return "😎 Você está se mantendo produtiva, mas com pouco tempo de descanso real. Pequenos ajustes podem melhorar sua energia para a UFRPE e o projeto ALBA!";
  } 
  
  return "⚡ Excelente equilíbrio! Seu descanso está mantendo sua mente afiada, essencial para a sustentabilidade da ALBA a longo prazo.";
}

int _extrairMinutos(dynamic tempoRaw) {
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
  notifyListeners(); 
}
}