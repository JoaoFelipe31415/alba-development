import 'package:alba/domain/dto/progresso_dto.dart';
import 'package:alba/ui/design_system/widgets/alba_feedback_box.dart';
import 'package:flutter/material.dart';
import 'progresso_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  final Color bgColor = const Color(0xFFF4F5F7);
  final Color primaryBlue = const Color(0xFF1D4ED8);
  final Color lightBlueCard = const Color(0xFFEFF6FF);
  final Color lightGreenCard = const Color(0xFFF0FDF4);
  final Color lightOrangeCard = const Color(0xFFFFF7ED);
  final Color lightPinkCard = const Color(0xFFFDF2F8);
  final Color textColor = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Consumer<ProgressViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = viewModel.data;
            if (data == null) return const Center(child: Text("Sem dados"));

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTimeFilter(viewModel),
                  const SizedBox(height: 32),
                  _buildInsightsSection(viewModel.data!),
                  const SizedBox(height: 32),
                  _buildEmotionalWellbeing(viewModel),
                  const SizedBox(height: 32),
                  _buildFocusDistribution(viewModel.data!, viewModel),
                  const SizedBox(height: 32),
                  _buildProductivitySection(viewModel.data!, viewModel),
                  const SizedBox(height: 32),
                  _buildBottlenecksSection(viewModel.data!, viewModel),
                  const SizedBox(height: 32),
                  _buildRestSection(viewModel.data!, viewModel),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Seu Progresso",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Continue firme! 💪",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.lightBlueAccent,
          child: Icon(Icons.radar, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  Widget _buildTimeFilter(ProgressViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Removi o "Dia" e a "Semana"
          _filterButton("Semana", viewModel),
          const SizedBox(width: 8),
          _filterButton("Mês", viewModel),
        ],
      ),
    );
  }

  Widget _filterButton(String label, ProgressViewModel viewModel) {
    bool isSelected = viewModel.currentFilter == label;
    return GestureDetector(
      onTap: () => viewModel.changeFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSection(ProgressDataModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: primaryBlue),
            const SizedBox(width: 8),
            Text(
              "Insights da ALBA 🤖",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...data.insights
            .map(
              (insight) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: insight.iconType == 'doc'
                            ? lightGreenCard
                            : lightPinkCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        insight.iconType == 'doc'
                            ? Icons.description
                            : Icons.image,
                        color: insight.iconType == 'doc'
                            ? Colors.green
                            : Colors.pink,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insight.description,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildEmotionalWellbeing(ProgressViewModel viewModel) {
    final nomesEmojis = {
      "😄": "Ótimo",
      "😊": "Bem",
      "😐": "Normal",
      "😔": "Para baixo",
      "😫": "Exausto",
    };

    String statusTexto = nomesEmojis[viewModel.emojiDestaque] ?? "Normal";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Bem-Estar Emocional",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: lightOrangeCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${viewModel.emojiDestaque} $statusTexto",
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              const dias = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"];
              String mood = viewModel.weeklyMood.length > index
                  ? viewModel.weeklyMood[index]
                  : "⚪";

              return Column(
                children: [
                  Text(mood, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    dias[index],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        AlbaFeedbackBox(
          bgColor: lightBlueCard,
          text: "💡 ${viewModel.feedbackBemEstar}",
        ),
      ],
    );
  }

  Widget _buildFocusDistribution(
    ProgressDataModel data,
    ProgressViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Distribuição do Foco",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: data.focusDistribution.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.book, size: 16), // Mock de ícone
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item.label.contains("Descanso")
                              ? "${item.value}h" // Se for descanso, mostra ex: 6h
                              : item.value == 1
                              ? "${item.value} dia" // Se for 1, mostra: 1 dia
                              : "${item.value} dias", // Se for 0 ou mais de 1, mostra: 2 dias
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildCustomProgressBar(
                      item.value / 7,
                      Color(int.parse(item.colorHex)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        AlbaFeedbackBox(
          bgColor: lightGreenCard,
          text: "📊 ${viewModel.feedbackFoco}",
        ),
      ],
    );
  }

  Widget _buildProductivitySection(
    ProgressDataModel data,
    ProgressViewModel viewModel,
  ) {
    // 👈 Adicione a viewModel aqui
    const Color colorAtribuidas = Color(0xFFD1D5DB);
    const Color colorConcluidas = Color(0xFF4F46E5);

    // ✅ Título Dinâmico
    String tituloSessao = viewModel.isMensal
        ? "Produtividade Mensal"
        : "Produtividade Semanal";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tituloSessao, // 👈 Agora muda conforme o filtro
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      maxY: _calcularMaxY(data.weeklyProductivity),
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        enabled: false,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) =>
                              Colors.transparent, // Fundo transparente
                          tooltipBorderRadius: BorderRadius.zero,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 4,
                          // ✅ Remove qualquer sombra que possa criar o "quadrado"
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (rod.toY <= 0.1) return null;
                            return BarTooltipItem(
                              rod.toY.round().toString(),
                              TextStyle(
                                color: rod.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ), // 👈 Fechou barTouchData
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index < 0 ||
                                  index >= data.weeklyProductivity.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  data.weeklyProductivity[index].label,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: data.weeklyProductivity.asMap().entries.map((
                        entry,
                      ) {
                        final index = entry.key;
                        final item = entry.value;

                        return BarChartGroupData(
                          x: index,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: item.attributed.toDouble() == 0
                                  ? 0.1
                                  : item.attributed.toDouble(),
                              color: colorAtribuidas,
                              width: viewModel.isMensal ? 22 : 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            BarChartRodData(
                              toY: item.value.toDouble() == 0
                                  ? 0.1
                                  : item.value.toDouble(),
                              color: colorConcluidas,
                              width: viewModel.isMensal ? 22 : 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                          showingTooltipIndicators: [
                            0,
                            1,
                          ], // Mostra os números em cima
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(colorAtribuidas, "Atribuídas"),
                  const SizedBox(width: 24),
                  _buildLegendItem(colorConcluidas, "Concluídas"),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Taxa de Conclusão",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          "${data.completionRate}%",
                          style: TextStyle(
                            color: colorConcluidas,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (data.completionRate / 100).clamp(0.0, 1.0),
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          colorConcluidas,
                        ),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  double _calcularMaxY(List<BarDataModel> dados) {
    double maiorValor = 0;

    for (var d in dados) {
      // Verificamos qual o maior valor entre as barras cinzas e roxas
      if (d.attributed > maiorValor) maiorValor = d.attributed.toDouble();
      if (d.value > maiorValor) maiorValor = d.value.toDouble();
    }

    if (maiorValor == 0) return 5.0;

    return maiorValor + 1.2;
  }

  Widget _buildBottlenecksSection(
    ProgressDataModel data,
    ProgressViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Principais Gargalos",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: data.bottlenecks.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 16,
                      color: Colors.orange,
                    ), // Mock ícone
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.label),
                              Text(
                                "${item.value}x",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildCustomProgressBar(
                            item.value / 3,
                            const Color(0xFFFF7A00),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        AlbaFeedbackBox(
          bgColor: lightOrangeCard, // Laranja para indicar atenção/alerta
          text: "⚠️ ${viewModel.feedbackGargalos}",
        ),
      ],
    );
  }

  Widget _buildRestSection(
    ProgressDataModel data,
    ProgressViewModel viewModel,
  ) {
    const colorNenhum = Color(0xFF94A3B8);
    const color30min = Color(0xFF6366F1);
    const color1a2h = Color(0xFF22C55E);
    const colorMais2h = Color(0xFFEAB308);

    final stats = data.restStats;
    final frequente = data.mostFrequentRest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Descanso Real na Semana",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ), // Reduzi de 18 para 16
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Parte do Gráfico Donut
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 160, // Reduzi de 160 para 140
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 50, // Reduzi de 50 para 40
                              startDegreeOffset: -90,
                              sections: [
                                PieChartSectionData(
                                  color: colorNenhum,
                                  value: stats['Nenhum'] ?? 0,
                                  showTitle: false,
                                  radius: 25,
                                ),
                                PieChartSectionData(
                                  color: colorMais2h,
                                  value: stats['Mais de 2 horas'] ?? 0,
                                  showTitle: false,
                                  radius: 25,
                                ),
                                PieChartSectionData(
                                  color: color1a2h,
                                  value: stats['Entre 1 e 2 horas'] ?? 0,
                                  showTitle: false,
                                  radius: 25,
                                ),
                                PieChartSectionData(
                                  color: color30min,
                                  value: stats['30 minutos'] ?? 0,
                                  showTitle: false,
                                  radius: 25,
                                ),
                              ],
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Icons.access_time_outlined,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Parte do Texto de Destaque
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const Text(
                          "Mais Frequente",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          frequente,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: color30min,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Legendas com fonte menor (Ajuste o _buildRestLegendItem para usar fontSize 12 ou 13)
              _buildRestLegendItem(
                colorNenhum,
                "Nenhum",
                "${stats['Nenhum']?.round()}%",
              ),
              _buildRestLegendItem(
                color30min,
                "30 min",
                "${stats['30 minutos']?.round()}%",
              ),
              _buildRestLegendItem(
                color1a2h,
                "1-2 horas",
                "${stats['Entre 1 e 2 horas']?.round()}%",
              ),
              _buildRestLegendItem(
                colorMais2h,
                "+2 horas",
                "${stats['Mais de 2 horas']?.round()}%",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestLegendItem(Color color, String label, String percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ),
          Text(
            percent,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomProgressBar(double percentage, Color color) {
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        FractionallySizedBox(
          widthFactor: percentage.clamp(
            0.0,
            1.0,
          ), // Garante que não passe de 100%
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
