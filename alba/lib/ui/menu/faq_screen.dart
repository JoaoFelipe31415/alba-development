import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _faqOriginal = [
    {
      'pergunta': 'O que é o ALBA?',
      'resposta':
          'O ALBA é um ecossistema projetado para facilitar a vida do estudante empreendedor. Através de automações inteligentes e ferramentas integradas, ajudamos universitários a gerenciar seus negócios com eficiência, permitindo equilibrar a rotina acadêmica com o crescimento do seu próprio empreendimento.',
    },
    {
      'pergunta': 'Como funciona o acompanhamento de metas do ALBA?',
      'resposta':
          'O ALBA ajuda você a equilibrar sua jornada acadêmica e profissional de forma integrada. O monitoramento de suas metas e tarefas acontece tanto no aplicativo quanto diretamente no seu WhatsApp, através da nossa assistente virtual, a Allbinha. Na tela inicial do app, você gerencia suas prioridades, cria tarefas específicas e acompanha a evolução do seu desempenho através de gráficos simples e intuitivos.',
    },
    {
      'pergunta': 'Como posso alterar meus dados acadêmicos?',
      'resposta':
          'Basta acessar o Menu, expandir o seu card de Perfil e selecionar "Mais informações". Lá você poderá atualizar sua universidade, curso, período atual e o ramo do seu negócio.',
    },
    {
      'pergunta': 'Quais são as formas de pagamento aceitas?',
      'resposta':
          'Atualmente aceitamos pagamentos via Pix e cartões de crédito. A renovação da assinatura é automática a cada mês.',
    },
    {
      'pergunta': 'Como faço para cancelar minha assinatura?',
      'resposta':
          'Você pode solicitar o cancelamento a qualquer momento diretamente pela aba "Plano e Assinatura", ou entrando em contato com o nosso suporte pelo e-mail suporte@albaapp.com.br.',
    },
    {
      'pergunta': 'O aplicativo funciona offline?',
      'resposta':
          'Algumas funções de visualização de metas e tarefas salvas localmente funcionam offline, mas para sincronizar suas atualizações no banco de dados e interagir com a Allbinha é necessária uma conexão com a internet.',
    },
  ];

  List<Map<String, String>> _faqFiltrado = [];

  @override
  void initState() {
    super.initState();
    _faqFiltrado = _faqOriginal;
  }

  void _filtrarPerguntas(String query) {
    setState(() {
      if (query.isEmpty) {
        _faqFiltrado = _faqOriginal;
      } else {
        _faqFiltrado = _faqOriginal
            .where(
              (item) =>
                  item['pergunta']!.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  item['resposta']!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.colors.azulAlba,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Perguntas Frequentes",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.colors.azulAlba,
          ),
        ),
        backgroundColor: context.colors.whiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Barra de Pesquisa
          Container(
            color: context.colors.whiteColor,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrarPerguntas,
              style: TextStyle(
                color: context.colors.azulAlba,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: "Digite sua dúvida (ex: plano, curso...)",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.colors.azulAlba.withOpacity(0.5),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: context.colors.azulAlba,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _filtrarPerguntas('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _faqFiltrado.isEmpty
                ? Center(
                    child: Text(
                      "Nenhuma pergunta encontrada.",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _faqFiltrado.length,
                    itemBuilder: (context, index) {
                      final item = _faqFiltrado[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: context.colors.whiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.colors.azulAlba.withOpacity(0.04),
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            iconColor: context.colors.focusColor,
                            collapsedIconColor: context.colors.azulAlba
                                .withOpacity(0.5),
                            title: Text(
                              item['pergunta']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.colors.azulAlba,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Text(
                                  item['resposta']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: context.colors.azulAlba.withOpacity(
                                      0.75,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}
