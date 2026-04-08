import 'package:flutter/material.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';

class TarefaCard extends StatelessWidget {
  final TarefaDto tarefa;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TarefaCard({
    super.key,
    required this.tarefa,
    required this.onEdit,
    required this.onDelete,
  });

  // Widget para os círculos dos dias
  Widget _buildDia(String letra, String dia, AppColors colors) {
    final selecionado = tarefa.diasRealizacao.contains(dia);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // Usando as cores da sua extensão
        color: selecionado ? colors.neonGreen: colors.whiteColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        letra,
        style: TextStyle(
          // Invertendo a cor conforme seleção
          color: selecionado ? colors.azulAlba : colors.azulAlba,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appColors.azulAlba, // Roxo/Azul do Alba
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline, 
                color: appColors.successColor, 
                size: 22
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tarefa.tituloTarefa,
                  style: TextStyle(
                    color: appColors.whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: Icon(Icons.edit, color: appColors.successColor, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                icon: Icon(Icons.delete, color: appColors.successColor, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDia('S', 'segunda', appColors),
              _buildDia('T', 'terca', appColors),
              _buildDia('Q', 'quarta', appColors),
              _buildDia('Q', 'quinta', appColors),
              _buildDia('S', 'sexta', appColors),
              _buildDia('S', 'sabado', appColors),
              _buildDia('D', 'domingo', appColors),
            ],
          ),
        ],
      ),
    );
  }

  // Funções de lógica movidas para dentro da classe (se precisar usar)
  String _formatarTag(String? tag) {
    if (tag == null || tag.isEmpty) return '';
    return tag.toLowerCase() == 'negocio' ? 'Negócio' : 'Faculdade';
  }
}