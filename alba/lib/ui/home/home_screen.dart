import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/metas/gerenciamento_metas_screen.dart';
import 'package:alba/ui/progresso/progresso_screen.dart';
import 'package:alba/ui/progresso/progresso_viewmodel.dart';
import 'package:alba/ui/tarefas/gerenciamento_tarefas_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _albaCircleColor = Color(0xFF7FE2E1);
const Color _unselectedNavColor = Color(0xFFB3CCFF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    ChangeNotifierProvider(
      create: (context) => ProgressViewModel(),
      child: const ProgressScreen(),
    ),

    const GeraciamentoMetasScreen(),

    const SizedBox(),

    const GerenciamentoTarefasScreen(),

    const _ProximamentScreen(),
  ];

  Future<void> _openAlbaWhatsapp() async {
    final whatsappUrl = Uri.parse('whatsapp://send?phone=5581995705981');
    final webUrl = Uri.parse('https://wa.me/5581995705981');

    final shouldOpenWhatsappApp = !kIsWeb && await canLaunchUrl(whatsappUrl);
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
    final keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: context.colors.whiteColor,
      body: _screens[selectedIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Quando o teclado abre, escondemos a bolinha ALBA.
      // Isso impede que ela suba e fique por cima da tela.
      floatingActionButton: keyboardIsOpen
          ? null
          : _AlbaNavButton(onTap: _openAlbaWhatsapp),

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
        selectedItemColor: _albaCircleColor,
        unselectedItemColor: _unselectedNavColor,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(
          color: _albaCircleColor,
          size: 30,
        ),
        unselectedIconTheme: const IconThemeData(
          color: _unselectedNavColor,
          size: 26,
        ),
        selectedLabelStyle: const TextStyle(
          color: _albaCircleColor,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          color: _unselectedNavColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        enableFeedback: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progresso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            activeIcon: SizedBox.shrink(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
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
              color: _albaCircleColor,
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
          const Text(
            'Em breve',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta funcionalidade em breve estará disponível',
            style: TextStyle(color: Color(0xFF888888)),
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