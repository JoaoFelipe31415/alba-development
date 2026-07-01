import 'package:alba/config/dependencies.dart';
import 'package:alba/core/locales.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/login/login_screen.dart';
import 'package:alba/ui/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

const Color _albaLightBlue = Color(0xFF7FE2E1);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupInjector();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final bool onboardingVisto = prefs.getBool('onboarding_visto') ?? false;

  runApp(
    MainApp(
      onboardingVisto: onboardingVisto,
    ),
  );
}

class MainApp extends StatelessWidget {
  final bool onboardingVisto;

  const MainApp({
    super.key,
    required this.onboardingVisto,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      debugShowCheckedModeBanner: false,

      home: onboardingVisto
          ? const LoginScreen()
          : const OnboardingScreen(),

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _albaLightBlue,
          selectionColor: Color(0x667FE2E1),
          selectionHandleColor: _albaLightBlue,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFABABAB),
              width: 1.4,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFABABAB),
              width: 1.4,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: _albaLightBlue,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFFF0004),
              width: 1.4,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFFF0004),
              width: 2,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
        ),
        extensions: <ThemeExtension<dynamic>>[
          const AppColors(),
        ],
      ),
      localizationsDelegates: [
        LucidLocalizationDelegate.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
} 