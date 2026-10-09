import 'package:flutter/material.dart';

import 'package:flash_splash/core/theme/app_theme.dart';
import 'package:flash_splash/core/theme/theme_controller.dart';
import 'package:flash_splash/features/auth/tela_inicial.dart';

class FlashSplashApp extends StatelessWidget {
  const FlashSplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, modo, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fast Splash',
          theme: AppTheme.claro,
          darkTheme: AppTheme.escuro,
          themeMode: modo,
          home: const TelaInicial(),
        );
      },
    );
  }
}
