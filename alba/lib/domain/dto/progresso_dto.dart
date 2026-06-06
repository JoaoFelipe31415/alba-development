class InsightModel {
  final String title;
  final String description;
  final String iconType;

  InsightModel({
    required this.title,
    required this.description,
    required this.iconType,
  });
}

class BarDataModel {
  final String label;
  final int value;
  final int attributed;
  final String colorHex;

  BarDataModel({
    required this.label,
    required this.value,
    this.attributed = 0,
    required this.colorHex,
  });
}

class ProgressDataModel {
  final List<InsightModel> insights;
  List<BarDataModel> focusDistribution;
  List<BarDataModel> bottlenecks;
  int completionRate;
  List<BarDataModel> weeklyProductivity = [];

  Map<String, double> restStats = {
    'Nenhum': 0,
    '30 minutos': 0,
    'Entre 1 e 2 horas': 0,
    'Mais de 2 horas': 0,
  };

  String mostFrequentRest = 'Nenhum';

  ProgressDataModel({
    required this.insights,
    required this.focusDistribution,
    required this.bottlenecks,
    required this.completionRate,
  });
}

class ProgressDTO {
  static ProgressDataModel fromFirestore(Map<String, dynamic> json) {
    return ProgressDataModel(
      completionRate: json['completionRate'] ?? 0,

      // Agora os insights não vêm mais mockados daqui.
      // Eles serão gerados dinamicamente no ProgressViewModel
      // pelo AlbaInsightsService.
      insights: json['insights'] != null
          ? (json['insights'] as List)
                .map(
                  (i) => InsightModel(
                    title: i['title'] ?? '',
                    description: i['description'] ?? '',
                    iconType: i['iconType'] ?? 'doc',
                  ),
                )
                .toList()
          : [],

      focusDistribution: json['focusDistribution'] != null
          ? (json['focusDistribution'] as List)
                .map(
                  (f) => BarDataModel(
                    label: f['label'] ?? '',
                    value: f['value'] ?? 0,
                    colorHex: f['colorHex'] ?? '0xFF1D4ED8',
                  ),
                )
                .toList()
          : [
              BarDataModel(
                label: 'Universidade',
                value: 0,
                colorHex: '0xFF1D4ED8',
              ),
              BarDataModel(label: 'Negócio', value: 0, colorHex: '0xFF84FA1E'),
              BarDataModel(label: 'Descanso', value: 0, colorHex: '0xFFD946EF'),
            ],

      bottlenecks: json['bottlenecks'] != null
          ? (json['bottlenecks'] as List)
                .map(
                  (b) => BarDataModel(
                    label: b['label'] ?? '',
                    value: b['value'] ?? 0,
                    colorHex: b['colorHex'] ?? '0xFFFF7A00',
                  ),
                )
                .toList()
          : [
              BarDataModel(
                label: 'Procrastinação',
                value: 0,
                colorHex: '0xFFEF4444',
              ),
              BarDataModel(label: 'Cansaço', value: 0, colorHex: '0xFFF59E0B'),
              BarDataModel(
                label: 'Prazos da Faculdade',
                value: 0,
                colorHex: '0xFF3B82F6',
              ),
              BarDataModel(
                label: 'Demandas do Negócio',
                value: 0,
                colorHex: '0xFF10B981',
              ),
            ],
    );
  }
}
