// progress_screen.dart
import 'package:alba/domain/dto/progresso_dto.dart';
import 'package:flutter/material.dart';
import 'progresso_viewmodel.dart';
import 'package:provider/provider.dart';

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

            if (viewModel.data == null) {
              return const Center(child: Text("Erro ao carregar dados."));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTimeFilter(viewModel),
                  const SizedBox(height: 32),
                  _buildInsightsSection(viewModel.data!),
                  const SizedBox(height: 32),
                  _buildEmotionalWellbeing(),
                  const SizedBox(height: 32),
                  _buildFocusDistribution(viewModel.data!),
                  const SizedBox(height: 32),
                  _buildProductivitySection(viewModel.data!),
                  const SizedBox(height: 32),
                  _buildBottlenecksSection(viewModel.data!),
                  const SizedBox(height: 32),
                  _buildRestSection(),
                  const SizedBox(height: 80), 
                ],
              ),
            );
          },
        ),
      ),
      
    );
  }

  // --- COMPONENTES DA TELA ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Seu Progresso", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
            const SizedBox(height: 4),
            const Text("Continue firme! 💪", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.chevron_left, color: Colors.grey),
          _filterButton("Dia", viewModel),
          _filterButton("Semana", viewModel),
          _filterButton("Mês", viewModel),
          const Icon(Icons.chevron_right, color: Colors.grey),
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
            Text("Insights da ALBA 🤖", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
        const SizedBox(height: 16),
        ...data.insights.map((insight) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: insight.iconType == 'doc' ? lightGreenCard : lightPinkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  insight.iconType == 'doc' ? Icons.description : Icons.image,
                  color: insight.iconType == 'doc' ? Colors.green : Colors.pink,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(insight.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(insight.description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildEmotionalWellbeing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Bem-Estar Emocional", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const Text("😐 Normal", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"].map((day) {
                  return Column(
                    children: [
                      const Text("🙂", style: TextStyle(fontSize: 24)), // Mock dos emojis
                      const SizedBox(height: 8),
                      Text(day, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildFeedbackBox(
          lightBlueCard,
          "💡 Notei que seu humor caiu nos últimos dias. Isso pode estar relacionado aos gargalos que você mencionou. Vamos trabalhar nisso juntas!",
        ),
      ],
    );
  }

  Widget _buildFocusDistribution(ProgressDataModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Distribuição do Foco", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                            Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Text("${item.value} dias", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildCustomProgressBar(item.value / 7, Color(int.parse(item.colorHex))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        _buildFeedbackBox(
          lightGreenCard,
          "📊 Você focou principalmente em Universidade. Lembre-se de equilibrar todas as áreas!",
        ),
      ],
    );
  }

  Widget _buildProductivitySection(ProgressDataModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Produtividade Semanal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              const SizedBox(height: 120, child: Center(child: Text("Gráfico de Barras Aqui (fl_chart)"))), // Placeholder para o gráfico de barras complexo
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: lightBlueCard, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Taxa de Conclusão"),
                    Text("${data.completionRate}%", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildCustomProgressBar(data.completionRate / 100, primaryBlue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottlenecksSection(ProgressDataModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Principais Gargalos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: data.bottlenecks.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 16, color: Colors.orange), // Mock ícone
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.label),
                              Text("${item.value}x", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildCustomProgressBar(item.value / 3, const Color(0xFFFF7A00)), // Baseado no valor max 3
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
        _buildFeedbackBox(
          lightOrangeCard,
          "⚠️ Identifiquei que faculdade tem sido seu maior desafio. Vou criar estratégias personalizadas para te ajudar!",
        ),
      ],
    );
  }

  Widget _buildRestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Descanso Real na Semana", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Center(
            child: Column(
              children: [
                SizedBox(
                  height: 150, width: 150,
                  child: CircularProgressIndicator(value: 0.6, strokeWidth: 20, color: Colors.blue, backgroundColor: Colors.grey),
                ), 
                SizedBox(height: 16),
                Text("Nenhum", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildFeedbackBox(
          lightPinkCard,
          "😎 Você está se mantendo produtiva, mas com pouco tempo de descanso real. Pequenos ajustes podem melhorar sua energia!",
        ),
      ],
    );
  }


  Widget _buildFeedbackBox(Color bgColor, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF334155), height: 1.4)),
    );
  }

  Widget _buildCustomProgressBar(double percentage, Color color) {
    return Stack(
      children: [
        Container(height: 8, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
        FractionallySizedBox(
          widthFactor: percentage.clamp(0.0, 1.0), // Garante que não passe de 100%
          child: Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        ),
      ],
    );
  }

}