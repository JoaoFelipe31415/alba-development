import 'dart:async';

import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _showSplash = true;
  int _currentPage = 0;

  static const String _logoNome = 'assets/images/logo_nome.png';
  static const String _logoSvg = 'assets/images/logo_sem_fundo.svg';
  static const String _corujaAlba = 'assets/images/imagem_alba_progresso.png';

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      imageType: _OnboardingImageType.logoNome,
      title: 'Bem-vindo(a) ao seu novo ritmo!',
      description:
          'Organize estudos, trabalho e bem-estar com mais clareza, leveza e inteligência.',
    ),
    _OnboardingData(
      imageType: _OnboardingImageType.coruja,
      title: 'Produtividade com Inteligência!',
      description:
          'Receba orientações e sugestões personalizadas para transformar metas em rotina.',
    ),
    _OnboardingData(
      imageType: _OnboardingImageType.logoSvg,
      title: 'Chega do desequilíbrio!',
      description:
          'Com Alba no WhatsApp, você acompanha sua evolução e recebe dicas certeiras para equilibrar estudos, negócio e bem-estar.',
      highlightWord: 'WhatsApp',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;

      setState(() {
        _showSplash = false;
      });

      _restartAnimation();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _restartAnimation() {
    _animationController
      ..reset()
      ..forward();
  }

  Future<void> _finalizarOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_visto', true);

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _proximaPagina() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    _finalizarOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const _SplashAlbaScreen();
    }

    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: context.colors.whiteColor,
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundDecoration(),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isLastPage)
                        TextButton(
                          onPressed: _finalizarOnboarding,
                          child: Text(
                            'Pular',
                            style: TextStyle(
                              color: context.colors.azulAlba.withOpacity(0.75),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      _restartAnimation();
                    },
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _OnboardingPage(data: _pages[index]),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                  child: Column(
                    children: [
                      _ProgressDots(
                        currentPage: _currentPage,
                        totalPages: _pages.length,
                      ),
                      const SizedBox(height: 28),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        child: isLastPage
                            ? _StartButton(
                                key: const ValueKey('start_button'),
                                onPressed: _finalizarOnboarding,
                              )
                            : _NextButton(
                                key: const ValueKey('next_button'),
                                onPressed: _proximaPagina,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashAlbaScreen extends StatelessWidget {
  const _SplashAlbaScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.whiteColor,
      body: Stack(
        children: [
          const _BackgroundDecoration(),
          Positioned.fill(
            child: CustomPaint(
              painter: _SplashWavePainter(
                azulAlba: context.colors.azulAlba,
                neonGreen: context.colors.neonGreen,
              ),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Opacity(
                  opacity: scale.clamp(0.0, 1.0),
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: Image.asset(
                _OnboardingScreenState._logoNome,
                width: 285,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          right: -80,
          child: _BlurCircle(
            size: 210,
            color: context.colors.focusColor.withOpacity(0.12),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -95,
          child: _BlurCircle(
            size: 230,
            color: context.colors.neonGreen.withOpacity(0.10),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -90,
          child: _BlurCircle(
            size: 240,
            color: context.colors.azulAlba.withOpacity(0.08),
          ),
        ),
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  final Color azulAlba;
  final Color neonGreen;

  const _SplashWavePainter({required this.azulAlba, required this.neonGreen});

  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = neonGreen
      ..style = PaintingStyle.fill;

    final bluePaint = Paint()
      ..color = azulAlba
      ..style = PaintingStyle.fill;

    final greenPath = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.90,
        size.width * 0.58,
        size.height * 0.90,
        size.width,
        size.height * 0.62,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final bluePath = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.93,
        size.width * 0.60,
        size.height * 0.94,
        size.width,
        size.height * 0.67,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(greenPath, greenPaint);
    canvas.drawPath(bluePath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant _SplashWavePainter oldDelegate) {
    return oldDelegate.azulAlba != azulAlba ||
        oldDelegate.neonGreen != neonGreen;
  }
}

enum _OnboardingImageType { logoNome, logoSvg, coruja }

class _OnboardingData {
  final _OnboardingImageType imageType;
  final String title;
  final String description;
  final String? highlightWord;

  const _OnboardingData({
    required this.imageType,
    required this.title,
    required this.description,
    this.highlightWord,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        children: [
          const Spacer(flex: 1),
          _ImageCard(imageType: data.imageType),
          const SizedBox(height: 34),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.azulAlba,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _DescriptionText(
              description: data.description,
              highlightWord: data.highlightWord,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final _OnboardingImageType imageType;

  const _ImageCard({required this.imageType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 245, maxHeight: 295),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: context.colors.whiteColor.withOpacity(0.92),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: context.colors.azulAlba.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.azulAlba.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Center(child: _buildImage(context)),
    );
  }

  Widget _buildImage(BuildContext context) {
    switch (imageType) {
      case _OnboardingImageType.logoNome:
        return Image.asset(
          _OnboardingScreenState._logoNome,
          width: 270,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );

      case _OnboardingImageType.logoSvg:
        return SvgPicture.asset(
          _OnboardingScreenState._logoSvg,
          width: 190,
          fit: BoxFit.contain,
        );

      case _OnboardingImageType.coruja:
        return Image.asset(
          _OnboardingScreenState._corujaAlba,
          width: 235,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );
    }
  }
}

class _DescriptionText extends StatelessWidget {
  final String description;
  final String? highlightWord;

  const _DescriptionText({required this.description, this.highlightWord});

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: context.colors.azulAlba.withOpacity(0.92),
      fontSize: 21,
      fontWeight: FontWeight.w500,
      height: 1.22,
      letterSpacing: -0.15,
    );

    if (highlightWord == null || !description.contains(highlightWord!)) {
      return Text(description, textAlign: TextAlign.center, style: baseStyle);
    }

    final parts = description.split(highlightWord!);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: highlightWord,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: parts.length > 1 ? parts.last : ''),
        ],
      ),
      textAlign: TextAlign.center,
      style: baseStyle,
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _ProgressDots({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    final inactiveColor = context.colors.focusColor.withOpacity(0.38);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final selected = currentPage == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: selected ? 38 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: selected ? context.colors.azulAlba : inactiveColor,
            borderRadius: BorderRadius.circular(99),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: context.colors.azulAlba.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 72),
        GestureDetector(
          onTap: onPressed,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: context.colors.azulAlba.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Próximo',
                  style: TextStyle(
                    color: context.colors.azulAlba,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: context.colors.azulAlba,
                  size: 27,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [context.colors.azulAlba, context.colors.focusColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.azulAlba.withOpacity(0.32),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          foregroundColor: context.colors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Começar agora',
              style: TextStyle(
                color: context.colors.whiteColor,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_rounded,
              color: context.colors.whiteColor,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}
