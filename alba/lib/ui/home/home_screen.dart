import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/auth_repository.dart';
import 'package:alba/data/repositories/tarefas_repository.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/login/login_screen.dart';
import 'package:alba/ui/metas/gerenciamento_metas_screen.dart';
import 'package:alba/ui/progresso/progresso_screen.dart';
import 'package:alba/ui/progresso/progresso_viewmodel.dart';
import 'package:alba/ui/tarefas/gerenciamento_tarefas_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authRepository = injector.get<AuthRepository>();
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const InicioScreen(),
    ChangeNotifierProvider(create: (context) => ProgressViewModel(),
        child: const ProgressScreen()
        ), // Progresso
    const SizedBox(), // ALBA (Dummy para manter os indices)
    const _ProximamentScreen(), // On-Demand
    const _ProximamentScreen(), // Menu
  ];

  Future<void> _openAlbaWhatsapp() async {
    // NÃºmero oficial da ALBA (pode ser ajustado aqui)
    final whatsappUrl = Uri.parse('whatsapp://send?phone=5581995705981');
    final webUrl = Uri.parse('https://wa.me/5581995705981');
    final shouldOpenWhatsappApp =
        !kIsWeb && await canLaunchUrl(whatsappUrl);
    final targetUrl = shouldOpenWhatsappApp ? whatsappUrl : webUrl;

    final launched = await launchUrl(
      targetUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && targetUrl != webUrl) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex.clamp(0, _screens.length - 1).toInt();

    return Scaffold(
      backgroundColor: context.colors.whiteColor,
      body: _screens[selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _AlbaNavButton(onTap: _openAlbaWhatsapp),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) async {
          if (index == 2) {
            await _openAlbaWhatsapp();
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: context.colors.azulAlba,
        selectedItemColor: context.colors.whiteColor,
        unselectedItemColor: Color(0xFFB3CCFF),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progresso',
          ),
          const BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            activeIcon: SizedBox.shrink(),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'On-Demand',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}

class _AlbaNavButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AlbaNavButton({required this.onTap});

  @override
  State<_AlbaNavButton> createState() => _AlbaNavButtonState();
}

class _AlbaNavButtonState extends State<_AlbaNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.12 : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7FE2E1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x33000000),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'ALBA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final authRepository = injector.get<AuthRepository>();
  final tarefasRepository = TarefasRepository();

  String get _userName =>
      authRepository.currentUser?.displayName ?? 'Estudante';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.whiteColor,
      body: SafeArea(
        child: StreamBuilder<List<TarefaDto>>(
          stream: tarefasRepository.buscarTarefasStream(
            '',
            dia: DateTime.now().day,
          ),
          builder: (context, snapshot) {
            final tarefasHoje = snapshot.data ?? [];
            final tarefasCompletas = tarefasHoje
                .where((t) => t.status == 'concluida')
                .length;
            final percentualProgresso = tarefasHoje.isEmpty
                ? 0
                : ((tarefasCompletas / tarefasHoje.length) * 100).toInt();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${_getGreeting()}, ${_userName.split(' ').first}!',
                                  style: TextStyle(
                                    color: context.colors.azulAlba,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '👋',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Container(
                                color: context.colors.whiteColor,
                                child: SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(
                                          Icons.logout,
                                          color: context.colors.errorColor,
                                        ),
                                        title: Text(
                                          'Sair',
                                          style: TextStyle(
                                            color: context.colors.errorColor,
                                          ),
                                        ),
                                        onTap: () {
                                          authRepository.logout();
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.azulAlba,
                            ),
                            child: Center(
                              child: Text(
                                _userName.isNotEmpty
                                    ? _userName[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  color: context.colors.whiteColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progresso do Dia',
                                style: TextStyle(
                                  color: const Color(0xFF333333),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$percentualProgresso%',
                                style: TextStyle(
                                  color: const Color(0xFF84F41E),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: tarefasHoje.isEmpty
                                  ? 0
                                  : (tarefasCompletas / tarefasHoje.length),
                              minHeight: 8,
                              backgroundColor: const Color(0xFFDDD9D9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF84F41E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Você completou ${tarefasHoje.isEmpty ? 0 : percentualProgresso}% das suas\ntarefas hoje',
                            style: TextStyle(
                              color: const Color(0xFF888888),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (tarefasHoje.isNotEmpty) ...[
                      Text(
                        'Suas tarefas para hoje',
                        style: TextStyle(
                          color: const Color(0xFF333333),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.azulAlba,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: tarefasHoje.map((tarefa) {
                            final isConcluida = tarefa.status == 'concluida';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: context.colors.whiteColor,
                                        width: 2,
                                      ),
                                      color: isConcluida
                                          ? Color(0xFF10B981)
                                          : Colors.transparent,
                                    ),
                                    child: isConcluida
                                        ? Icon(
                                            Icons.check,
                                            color: context.colors.whiteColor,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tarefa.tituloTarefa,
                                          style: TextStyle(
                                            color: context.colors.whiteColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            decoration: isConcluida
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if (tarefa.horario != null)
                                          Text(
                                            tarefa.horario!,
                                            style: TextStyle(
                                              color: context.colors.whiteColor
                                                  .withAlpha(
                                                    (255 * 0.7).toInt(),
                                                  ),
                                              fontSize: 12,
                                            ),
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
                      const SizedBox(height: 24),
                    ],

                    // Gerenciamento
                    Text(
                      'Gerenciamento',
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _GerenciamentoButton(
                            icon: Icons.check_circle,
                            label: 'Tarefas',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GerenciamentoTarefasScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GerenciamentoButton(
                            icon: Icons.location_on,
                            label: 'Metas',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GeraciamentoMetasScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GerenciamentoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GerenciamentoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.azulAlba,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7FE2E1),
              ),
              child: Icon(icon, color: context.colors.azulAlba, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: context.colors.whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProximamentScreen extends StatelessWidget {
  const _ProximamentScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: context.colors.textPrimaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Em breve',
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta funcionalidade em breve estará disponível',
            style: TextStyle(color: const Color(0xFF888888)),
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
