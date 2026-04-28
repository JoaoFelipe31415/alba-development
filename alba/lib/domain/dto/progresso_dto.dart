class InsightModel {
  final String title;
  final String description;
  final String iconType; 

  InsightModel({required this.title, required this.description, required this.iconType});
}

class BarDataModel {
  final String label;
  final int value;
  final int attributed;
  final String colorHex;

  BarDataModel({required this.label, required this.value, this.attributed = 0, required this.colorHex});
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
  String mostFrequentRest = "0"; 

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
      completionRate: json['completionRate'] ?? 42,

      insights: json['insights'] != null
      ? (json['insights'] as List).map((i) => InsightModel(
        title: i['title'] ?? "",
        description: i['description'] ?? "",
        iconType: i['iconType'] ?? "doc",
        )).toList()
        : [
     InsightModel(
                title: "Reorganizar Cronograma",
                description: "Vi que seu estresse aumentou. Vou ajustar seu cronograma de estudos",
                iconType: "doc",
              ),
              InsightModel(
                title: "Criar Cardápio de Brownies",
                description: "Percebi que você precisa criar um cardápio digital para postar no Instagram",
                iconType: "image",
              ),
            ],

      focusDistribution: json['focusDistribution'] != null
          ? (json['focusDistribution'] as List).map((f) => BarDataModel(
                label: f['label'] ?? "",
                value: f['value'] ?? 0,
                colorHex: f['colorHex'] ?? "0xFF1D4ED8",
              )).toList()
          : [
              BarDataModel(label: "Universidade", value: 4, colorHex: "0xFF1D4ED8"),
              BarDataModel(label: "Negócio", value: 2, colorHex: "0xFF84FA1E"),
              BarDataModel(label: "Descanso", value: 1, colorHex: "0xFFD946EF"),
            ],

      bottlenecks: json['bottlenecks'] != null
          ? (json['bottlenecks'] as List).map((b) => BarDataModel(
                label: b['label'] ?? "",
                value: b['value'] ?? 0,
                colorHex: b['colorHex'] ?? "0xFFFF7A00",
              )).toList()
          : [
              BarDataModel(label: "Faculdade", value: 3, colorHex: "0xFFFF7A00"),
              BarDataModel(label: "Cansaço", value: 1, colorHex: "0xFFFF7A00"),
            ],
    );
  }
}
