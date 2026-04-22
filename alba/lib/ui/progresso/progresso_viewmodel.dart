import 'package:alba/data/repositories/auth_repository.dart';
import 'package:alba/domain/dto/progresso_dto.dart';
import 'package:alba/data/repositories/progresso_repository.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alba/data/repositories/tarefas_repository.dart';

class ProgressViewModel extends ChangeNotifier {
  final ProgressoRepository _repository = ProgressoRepository();
  final TarefasRepository _tarefasRepository = TarefasRepository(); 
  final AuthRepository _authRepository = AuthRepository();

  bool isLoading = true;
  String currentFilter = 'Semana';
  ProgressDataModel? data;
  List<String> weeklyMood = ['⚪', '⚪', '⚪', '⚪', '⚪', '⚪', '⚪'];

  ProgressViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    final String? uid = _authRepository.currentUser?.uid;

    if (uid != null) {
      // 1. Dados gerais
      final dadosJson = await _repository.obterProgresso(uid);
      data = ProgressDTO.fromFirestore(dadosJson ?? {});

      // 2. Monitoramento (Emojis e Gargalos)
      final monitoranentoSemanal = await _repository.obterSentimentosDaSemana(uid);
      
      weeklyMood = List.generate(7, (_) => '⚪');
      for (var doc in monitoranentoSemanal) {
        if (doc['data'] != null) {
          DateTime dataResposta = (doc['data'] as Timestamp).toDate();
          int indiceDia = dataResposta.weekday % 7;
          weeklyMood[indiceDia] = _mapMood(doc['sentimento'] ?? "");
        }
      }
      _processarGargalos(monitoranentoSemanal);

      // 3. Distribuição de Foco (Baseado em Tarefas Concluídas)
      // Mova a função de busca para o Repository e chame-a aqui:
      final tarefasConcluidas = await _tarefasRepository.obterTarefasConcluidas(uid);
      _processarDistribuicaoFoco(tarefasConcluidas, monitoranentoSemanal);

    } else {
      data = ProgressDTO.fromFirestore({});
    }

    isLoading = false;
    notifyListeners();
  }

  String _mapMood(String sentiment) {
    // Trim e Lowercase para evitar erros de digitação do bot ou usuário
    switch (sentiment.toLowerCase().trim()) {
      case 'ótimo': return '🤩'; // Sugestão: 🤩 para Ótimo e 🙂 para Bem
      case 'bem': return '😊';
      case 'neutro': return '😐';
      case 'cansado(a)': return '😔';
      case 'estressado(a)': return '😣';
      default: return '⚪';
    }
  }

  void changeFilter(String newFilter) {
    if (currentFilter != newFilter) {
      currentFilter = newFilter;
      loadData();
    }
  }

  // 1. Função que conta as ocorrências e atualiza o DTO
  void _processarGargalos(List<Map<String, dynamic>> documentos) {
    Map<String, int> contador = {
      'Procrastinação': 0,
      'Cansaço': 0,
      'Prazos da Faculdade': 0,
      'Demandas do Negócio': 0,
    };

    for (var doc in documentos) {
      // Pega o campo que o bot salva no Firestore
      String? gargaloBruto = doc['gargaloPrincipal']; 
      
      if (gargaloBruto != null) {
        String chave = _normalizarGargalo(gargaloBruto);
        if (contador.containsKey(chave)) {
          contador[chave] = contador[chave]! + 1;
        }
      }
    }

    // Aqui nós injetamos os dados reais no objeto 'data' que a tela consome
    data?.bottlenecks = contador.entries
        .where((e) => e.value > 0) // Só mostra o que aconteceu de verdade
        .map((e) => BarDataModel(
              label: e.key,
              value: e.value,
              colorHex: "0xFFFF7A00", // 
            ))
        .toList();
  }

  // 2. Função para garantir que o texto do bot bata com as chaves do mapa
  String _normalizarGargalo(String texto) {
    final t = texto.toLowerCase();
    if (t.contains('procrastinação')) return 'Procrastinação';
    if (t.contains('cansaço')) return 'Cansaço';
    if (t.contains('faculdade')) return 'Prazos da Faculdade';
    if (t.contains('negócio')) return 'Demandas do Negócio';
    return '';
  }

 void _processarDistribuicaoFoco(List<TarefaDto> tarefas, List<Map<String, dynamic>> monitoramento) {
    int contagemUni = 0;
    int contagemNeg = 0;
    int totalDescanso = 0;

    for (var tarefa in tarefas) {
      // 1. AJUSTE: Mudamos de 'categoria' para 'tag'
      String tag = (tarefa.tag ?? '').toLowerCase().trim();

      if (tag.contains('universidade') || tag.contains('faculdade')) {
        contagemUni++;
      } else if (tag.contains('negoc') || tag.contains('negóc')) {
        contagemNeg++;
      }
    }

for (var doc in monitoramento) {
    String tempoRaw = (doc['tempoDescanso'] ?? '0').toString().toLowerCase();
    
    // Extrai o valor numérico
    int valor = int.tryParse(tempoRaw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    // Se a string contém "minuto", convertemos para uma fração de hora (opcional)
    // Ou apenas somamos se for hora. 
    if (tempoRaw.contains('minuto')) {
       // Ex: 30 minutos vira 0 horas (no gráfico de inteiros) ou você pode arredondar
       // Se o seu gráfico for de INT, minutos pequenos podem sumir.
       // Uma opção é: totalDescanso += (valor >= 30 ? 1 : 0); // 30min+ vira 1h
    } else {
       totalDescanso += valor;
    }
  }

    data?.focusDistribution = [
      BarDataModel(
        label: "Universidade", 
        value: contagemUni, 
        colorHex: "0xFF1D4ED8"
      ),
      BarDataModel(
        label: "Negócio", 
        value: contagemNeg, 
        colorHex: "0xFF84FA1E"
      ),
      // Mantemos o descanso como 1 para o pilar visual do ALBA
      BarDataModel(
        label: "Descanso", 
        value: totalDescanso, 
        colorHex: "0xFFD946EF"
      ),
    ];
  }
}