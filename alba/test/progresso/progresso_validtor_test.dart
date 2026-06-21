import 'package:flutter_test/flutter_test.dart';
import 'package:alba/ui/progresso/progresso_viewmodel.dart';
import 'package:alba/data/services/alba_insights_service.dart';
import 'package:alba/domain/dto/progresso_dto.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';

void main() {
  group('ProgressViewModel - Helper Methods', () {
    test('mapMood deve mapear sentimentos para emojis corretamente', () {
      expect(ProgressViewModel.mapMood('ótimo'), '😃');
      expect(ProgressViewModel.mapMood('otim'), '😃');
      expect(ProgressViewModel.mapMood('bem'), '😊');
      expect(ProgressViewModel.mapMood('neutro'), '😐');
      expect(ProgressViewModel.mapMood('cansado'), '😔');
      expect(ProgressViewModel.mapMood('estressado'), '😣');
      expect(ProgressViewModel.mapMood('exausto'), '😫');
      expect(ProgressViewModel.mapMood('desconhecido'), '⚪');
    });

    test('normalizarGargalo deve normalizar textos para categorias de gargalo', () {
      expect(ProgressViewModel.normalizarGargalo('procrastinação'), 'Procrastinação');
      expect(ProgressViewModel.normalizarGargalo('procrastinacao'), 'Procrastinação');
      expect(ProgressViewModel.normalizarGargalo('cansaço'), 'Cansaço');
      expect(ProgressViewModel.normalizarGargalo('cansado'), 'Cansaço');
      expect(ProgressViewModel.normalizarGargalo('faculdade'), 'Prazos da Faculdade');
      expect(ProgressViewModel.normalizarGargalo('universidade'), 'Prazos da Faculdade');
      expect(ProgressViewModel.normalizarGargalo('negócio'), 'Demandas do Negócio');
      expect(ProgressViewModel.normalizarGargalo('negoc'), 'Demandas do Negócio');
      expect(ProgressViewModel.normalizarGargalo('outros fatores'), 'Outros');
      expect(ProgressViewModel.normalizarGargalo(''), '');
    });

    test('definirCorGargalo deve retornar a cor correta para cada gargalo', () {
      expect(ProgressViewModel.definirCorGargalo('Procrastinação'), '0xFFEF4444');
      expect(ProgressViewModel.definirCorGargalo('Cansaço'), '0xFFF59E0B');
      expect(ProgressViewModel.definirCorGargalo('Prazos da Faculdade'), '0xFF3B82F6');
      expect(ProgressViewModel.definirCorGargalo('Demandas do Negócio'), '0xFF10B981');
      expect(ProgressViewModel.definirCorGargalo('Outros'), '0xFF6B7280');
      expect(ProgressViewModel.definirCorGargalo('Desconhecido'), '0xFF6B7280');
    });

    test('extrairMinutos deve converter texto de tempo bruto para minutos', () {
      expect(ProgressViewModel.extrairMinutos('30'), 30);
      expect(ProgressViewModel.extrairMinutos('30 min'), 30);
      expect(ProgressViewModel.extrairMinutos('2h'), 120);
      expect(ProgressViewModel.extrairMinutos('1 hora'), 60);
      expect(ProgressViewModel.extrairMinutos('none'), 0);
    });
  });

  group('AlbaInsightsService - gerarInsights', () {
    late ProgressDataModel data;

    setUp(() {
      data = ProgressDataModel(
        insights: [],
        focusDistribution: [
          BarDataModel(label: 'Universidade', value: 0, colorHex: '0xFF1D4ED8'),
          BarDataModel(label: 'Negócio', value: 0, colorHex: '0xFF84FA1E'),
          BarDataModel(label: 'Descanso', value: 0, colorHex: '0xFFD946EF'),
        ],
        bottlenecks: [
          BarDataModel(label: 'Procrastinação', value: 0, colorHex: '0xFFEF4444'),
          BarDataModel(label: 'Cansaço', value: 0, colorHex: '0xFFF59E0B'),
          BarDataModel(label: 'Prazos da Faculdade', value: 0, colorHex: '0xFF3B82F6'),
          BarDataModel(label: 'Demandas do Negócio', value: 0, colorHex: '0xFF10B981'),
        ],
        completionRate: 0,
      );
      // Evita o insight padrão "Cuidar do descanso" nos testes
      data.mostFrequentRest = 'Entre 1 e 2 horas';
    });

    test('deve sugerir começar com uma ação simples se não houver tarefas', () {
      final insights = AlbaInsightsService.gerarInsights(
        data: data,
        tarefas: [],
        isMensal: false,
        weeklyMood: ['⚪', '⚪', '⚪', '⚪', '⚪', '⚪', '⚪'],
        emojiDestaque: '⚪',
      );

      expect(insights, isNotEmpty);
      expect(insights.any((i) => i.title == 'Começar com uma ação simples'), isTrue);
    });

    test('deve sugerir reorganizar prioridades se a taxa de conclusão for baixa (< 35%)', () {
      data.completionRate = 20;
      final tarefa = TarefaDto(
        tituloTarefa: 'Fazer bolo',
        diasRealizacao: [],
        status: 'pendente',
        userId: '1',
        dataCriacao: DateTime.now(),
        metaId: 'meta-123', // Evita o insight "Conectar tarefas às metas"
      );

      final insights = AlbaInsightsService.gerarInsights(
        data: data,
        tarefas: [tarefa],
        isMensal: false,
        weeklyMood: ['⚪', '⚪', '⚪', '⚪', '⚪', '⚪', '⚪'],
        emojiDestaque: '⚪',
      );

      expect(insights.any((i) => i.title == 'Reorganizar prioridades'), isTrue);
    });

    test('deve sugerir ajustar o ritmo se a taxa de conclusão for média (entre 35% e 70%)', () {
      data.completionRate = 50;
      final tarefa = TarefaDto(
        tituloTarefa: 'Fazer bolo',
        diasRealizacao: [],
        status: 'pendente',
        userId: '1',
        dataCriacao: DateTime.now(),
        metaId: 'meta-123', // Evita o insight "Conectar tarefas às metas"
      );

      final insights = AlbaInsightsService.gerarInsights(
        data: data,
        tarefas: [tarefa],
        isMensal: false,
        weeklyMood: ['⚪', '⚪', '⚪', '⚪', '⚪', '⚪', '⚪'],
        emojiDestaque: '⚪',
      );

      expect(insights.any((i) => i.title == 'Ajustar o ritmo'), isTrue);
    });

    test('deve sugerir manter o ritmo se a taxa de conclusão for alta (>= 70%)', () {
      data.completionRate = 80;
      final tarefa = TarefaDto(
        tituloTarefa: 'Fazer bolo',
        diasRealizacao: [],
        status: 'concluida',
        userId: '1',
        dataCriacao: DateTime.now(),
        metaId: 'meta-123', // Evita o insight "Conectar tarefas às metas"
      );

      final insights = AlbaInsightsService.gerarInsights(
        data: data,
        tarefas: [tarefa],
        isMensal: false,
        weeklyMood: ['⚪', '⚪', '⚪', '⚪', '⚪', '⚪', '⚪'],
        emojiDestaque: '⚪',
      );

      expect(insights.any((i) => i.title == 'Manter o ritmo'), isTrue);
    });

    test('deve sugerir conectar tarefas a metas se houver tarefas sem meta vinculada', () {
      data.completionRate = 80;
      final tarefaSemMeta = TarefaDto(
        tituloTarefa: 'Fazer bolo',
        diasRealizacao: [],
        status: 'concluida',
        userId: '1',
        dataCriacao: DateTime.now(),
        metaId: null, // sem meta -> Gera "Conectar tarefas às metas"
      );

      final insights = AlbaInsightsService.gerarInsights(
        data: data,
        tarefas: [tarefaSemMeta],
        isMensal: false,
        weeklyMood: ['⚪', '⚪', '⚪', '⚪', '⚪', '⚪', '⚪'],
        emojiDestaque: '⚪',
      );

      expect(insights.any((i) => i.title == 'Conectar tarefas às metas'), isTrue);
    });
  });
}
