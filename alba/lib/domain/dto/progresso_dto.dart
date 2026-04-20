
class InsightModel {
  final String title;
  final String description;
  final String iconType; 

  InsightModel({required this.title, required this.description, required this.iconType});
}

class BarDataModel {
  final String label;
  final int value;
  final String colorHex;

  BarDataModel({required this.label, required this.value, required this.colorHex});
}

class ProgressDataModel {
  final List<InsightModel> insights;
  final List<BarDataModel> focusDistribution;
  final List<BarDataModel> bottlenecks;
  final int completionRate;

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
      insights: [
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
      focusDistribution: [
        BarDataModel(label: "Universidade", value: 4, colorHex: "0xFF1D4ED8"),
        BarDataModel(label: "Negócio", value: 2, colorHex: "0xFF84FA1E"),
        BarDataModel(label: "Descanso", value: 1, colorHex: "0xFFD946EF"),
      ],
      bottlenecks: [
        BarDataModel(label: "Faculdade", value: 3, colorHex: "0xFFFF7A00"),
        BarDataModel(label: "Outro", value: 1, colorHex: "0xFFFF7A00"),
        BarDataModel(label: "Procrastinação", value: 1, colorHex: "0xFFFF7A00"),
        BarDataModel(label: "Trabalho", value: 1, colorHex: "0xFFFF7A00"),
        BarDataModel(label: "Cansaço", value: 1, colorHex: "0xFFFF7A00"),
      ],
      completionRate: 42,
    );
  }
}