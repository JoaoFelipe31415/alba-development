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
  final Color albaLightBlue = const Color(0xFF7FE2E1);

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
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: ClipOval(
            child: Image.asset(
              'assets/images/imagem_alba_progresso.png',
              fit: BoxFit.cover,
            ),
          ),
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
    if (data.insights.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitleWithIcon(
            title: "Insights da ALBA 🤖",
            icon: Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildModernInsightIcon('default'),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Continue usando o app para que a ALBA gere insights personalizados sobre sua rotina.',
                    style: TextStyle(
                      color: textColor.withOpacity(0.78),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitleWithIcon(
          title: "Insights da ALBA 🤖",
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 16),
        ...data.insights.map((insight) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildModernInsightIcon(insight.iconType),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: TextStyle(
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        insight.description,
                        style: TextStyle(
                          color: textColor.withOpacity(0.62),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: primaryBlue.withOpacity(0.72),
                    size: 20,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSectionTitleWithIcon({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: lightBlueCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryBlue, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInsightIcon(String iconType) {
    IconData icon;
    Color iconColor;
    Color backgroundColor;

    switch (iconType) {
      case 'warning':
      case 'alert':
      case 'image':
        icon = Icons.tips_and_updates_rounded;
        iconColor = const Color(0xFFF59E0B);
        backgroundColor = const Color(0xFFFFF7ED);
        break;

      case 'focus':
        icon = Icons.center_focus_strong_rounded;
        iconColor = const Color(0xFF1D4ED8);
        backgroundColor = const Color(0xFFEFF6FF);
        break;

      case 'rest':
        icon = Icons.self_improvement_rounded;
        iconColor = const Color(0xFF10B981);
        backgroundColor = const Color(0xFFECFDF5);
        break;

      case 'doc':
      default:
        icon = Icons.lightbulb_rounded;
        iconColor = primaryBlue;
        backgroundColor = const Color(0xFFEFF6FF);
        break;
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 27),
    );
  }

  Widget _buildEmotionalWellbeing(ProgressViewModel viewModel) {
    final nomesEmojis = {
      "😃": "Ótimo",
      "😄": "Ótimo",
      "😊": "Bem",
      "😐": "Normal",
      "😔": "Para baixo",
      "😣": "Estresse",
      "😫": "Exausto",
      "⚪": "Sem dados",
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
            children: List.generate(viewModel.weeklyMood.length, (index) {
              const diasSemana = [
                "Dom",
                "Seg",
                "Ter",
                "Qua",
                "Qui",
                "Sex",
                "Sáb",
              ];

              String mood = viewModel.weeklyMood[index];

              String legenda = viewModel.isMensal
                  ? "Sem ${index + 1}"
                  : diasSemana[index];

              return Column(
                children: [
                  Text(mood, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    legenda,
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
                            const Icon(Icons.book, size: 16),
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
                              ? "${item.value}h"
                              : item.value == 1
                              ? "${item.value} dia"
                              : "${item.value} dias",
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
    const Color colorAtribuidas = Color(0xFFD1D5DB);
    const Color colorConcluidas = Color(0xFF4F46E5);

    String tituloSessao = viewModel.isMensal
        ? "Produtividade Mensal"
        : "Produtividade Semanal";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tituloSessao,
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
                          getTooltipColor: (_) => Colors.transparent,
                          tooltipBorderRadius: BorderRadius.zero,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 4,
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
                      ),
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
                          showingTooltipIndicators: [0, 1],
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
    // ✨ O CÁLCULO FICA AQUI (Fora dos widgets, antes de construir a tela)
    int maxGargalo = data.bottlenecks.isNotEmpty
        ? data.bottlenecks.map((e) => e.value).reduce((a, b) => a > b ? a : b)
        : 0;

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
                    const Icon(Icons.warning, size: 16, color: Colors.orange),
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
                            maxGargalo > 0 ? (item.value / maxGargalo) : 0.0,
                            Color(int.parse(item.colorHex)),
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
          bgColor: lightOrangeCard,
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
        ),
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
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 160,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 50,
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
          widthFactor: percentage.clamp(0.0, 1.0),
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
