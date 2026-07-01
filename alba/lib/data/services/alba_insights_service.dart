import 'dart:math';

import 'package:alba/domain/dto/progresso_dto.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';

class AlbaInsightsService {
  static List<InsightModel> gerarInsights({
    required ProgressDataModel data,
    required List<TarefaDto> tarefas,
    required bool isMensal,
    required List<String> weeklyMood,
    required String emojiDestaque,
  }) {
    final insights = <InsightModel>[];

    final totalTarefas = tarefas.length;

    final tarefasConcluidas = tarefas.where((tarefa) {
      return tarefa.status.toLowerCase().trim() == 'concluida';
    }).length;

    final tarefasPendentes = tarefas.where((tarefa) {
      return tarefa.status.toLowerCase().trim() != 'concluida';
    }).length;

    final tarefasSemMeta = tarefas.where((tarefa) {
      final metaId = tarefa.metaId?.trim();
      return metaId == null || metaId.isEmpty;
    }).length;

    final taxaConclusao = data.completionRate;

    final gargalosComValor = data.bottlenecks
        .where((gargalo) => gargalo.value > 0)
        .toList();

    final focoComValor = data.focusDistribution
        .where((foco) => foco.value > 0)
        .toList();

    final gargaloPrincipal = gargalosComValor.isEmpty
        ? null
        : gargalosComValor.reduce(
            (a, b) => a.value >= b.value ? a : b,
          );

    final focoPrincipal = focoComValor.isEmpty
        ? null
        : focoComValor.reduce(
            (a, b) => a.value >= b.value ? a : b,
          );

    final descansoMaisFrequente = data.mostFrequentRest;
    final periodo = isMensal ? 'neste mês' : 'nesta semana';

    if (totalTarefas == 0) {
      insights.add(
        InsightModel(
          title: 'Começar com uma ação simples',
          description:
              'Ainda não encontrei tarefas registradas $periodo. Crie uma tarefa pequena vinculada a uma meta para começar a medir seu progresso.',
          iconType: 'doc',
        ),
      );
    }

    if (taxaConclusao < 35 && totalTarefas > 0) {
      insights.add(
        InsightModel(
          title: 'Reorganizar prioridades',
          description:
              'Sua taxa de conclusão está em $taxaConclusao%. Escolha poucas tarefas essenciais e evite sobrecarregar seu dia.',
          iconType: 'doc',
        ),
      );
    }

    if (taxaConclusao >= 35 && taxaConclusao < 70 && totalTarefas > 0) {
      insights.add(
        InsightModel(
          title: 'Ajustar o ritmo',
          description:
              'Você está com $taxaConclusao% de conclusão $periodo. Um bom próximo passo é finalizar as tarefas menores primeiro.',
          iconType: 'doc',
        ),
      );
    }

    if (taxaConclusao >= 70 && totalTarefas > 0) {
      insights.add(
        InsightModel(
          title: 'Manter o ritmo',
          description:
              'Você concluiu $tarefasConcluidas de $totalTarefas tarefas $periodo. Seu ritmo está bom; mantenha o foco nas próximas entregas.',
          iconType: 'doc',
        ),
      );
    }

    if (tarefasPendentes >= 5) {
      insights.add(
        InsightModel(
          title: 'Reduzir acúmulo de tarefas',
          description:
              'Identifiquei $tarefasPendentes tarefas pendentes. Escolha as 3 mais importantes e deixe o restante para depois.',
          iconType: 'doc',
        ),
      );
    }

    if (tarefasSemMeta > 0) {
      insights.add(
        InsightModel(
          title: 'Conectar tarefas às metas',
          description:
              'Você tem $tarefasSemMeta tarefa(s) sem meta vinculada. Associar tarefas a metas ajuda a enxergar melhor seu avanço.',
          iconType: 'doc',
        ),
      );
    }

    if (gargaloPrincipal != null) {
      switch (gargaloPrincipal.label) {
        case 'Cansaço':
          insights.add(
            InsightModel(
              title: 'Ajustar energia da rotina',
              description:
                  'O cansaço apareceu como gargalo importante. Distribua tarefas pesadas em blocos menores com pausas reais.',
              iconType: 'image',
            ),
          );
          break;

        case 'Procrastinação':
          insights.add(
            InsightModel(
              title: 'Quebrar a procrastinação',
              description:
                  'A procrastinação apareceu com frequência. Comece por uma tarefa de 10 minutos para destravar o movimento.',
              iconType: 'doc',
            ),
          );
          break;

        case 'Prazos da Faculdade':
          insights.add(
            InsightModel(
              title: 'Priorizar prazos da faculdade',
              description:
                  'Os prazos acadêmicos estão pesando. Organize primeiro as tarefas com data mais próxima.',
              iconType: 'doc',
            ),
          );
          break;

        case 'Demandas do Negócio':
          insights.add(
            InsightModel(
              title: 'Organizar demandas do negócio',
              description:
                  'Seu negócio está exigindo atenção. Agrupe tarefas parecidas para ganhar tempo e reduzir troca de contexto.',
              iconType: 'image',
            ),
          );
          break;
      }
    }

    if (descansoMaisFrequente == 'Nenhum' ||
        descansoMaisFrequente == '30 minutos') {
      insights.add(
        InsightModel(
          title: 'Cuidar do descanso',
          description:
              'Seu descanso parece baixo $periodo. Uma pausa planejada pode melhorar sua constância e evitar queda de energia.',
          iconType: 'image',
        ),
      );
    }

    if (emojiDestaque == '😔' ||
        emojiDestaque == '😣' ||
        emojiDestaque == '😫') {
      insights.add(
        InsightModel(
          title: 'Aliviar a carga emocional',
          description:
              'Seu bem-estar sinalizou um período mais pesado. Priorize tarefas menores e evite acumular decisões difíceis.',
          iconType: 'image',
        ),
      );
    }

    if (focoPrincipal != null) {
      if (focoPrincipal.label == 'Universidade') {
        insights.add(
          InsightModel(
            title: 'Equilibrar universidade e rotina',
            description:
                'Seu foco está mais concentrado em Universidade. Verifique se outras áreas importantes não estão ficando para trás.',
            iconType: 'doc',
          ),
        );
      }

      if (focoPrincipal.label == 'Negócio') {
        insights.add(
          InsightModel(
            title: 'Proteger tempo de estudo',
            description:
                'O negócio está ocupando boa parte do seu foco. Reserve blocos fixos para manter a faculdade em dia.',
            iconType: 'image',
          ),
        );
      }

      if (focoPrincipal.label == 'Descanso') {
        insights.add(
          InsightModel(
            title: 'Descanso bem aproveitado',
            description:
                'Você priorizou descanso $periodo. Isso pode ser positivo, desde que as tarefas essenciais estejam sob controle.',
            iconType: 'doc',
          ),
        );
      }
    }

    if (insights.isEmpty) {
      insights.add(
        InsightModel(
          title: 'Continuar acompanhando',
          description:
              'Ainda estou reunindo dados suficientes para gerar uma recomendação mais precisa. Continue registrando tarefas e progresso.',
          iconType: 'doc',
        ),
      );
    }

    insights.shuffle(Random());

    return insights.take(2).toList();
  }
}