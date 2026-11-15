import 'package:flutter/material.dart';

import 'package:flash_splash/core/session/sessao.dart';
import 'package:flash_splash/core/theme/app_theme.dart';
import 'package:flash_splash/core/theme/theme_controller.dart';
import 'package:flash_splash/features/auth/tela_inicial.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

/// Sessão do servidor expirou (30 min sem uso no Tomcat): limpa o login e volta para a tela inicial.
void voltarAoLogin() {
  Sessao.limpar();
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const TelaInicial()),
    (route) => false,
  );
  messengerKey.currentState?.showSnackBar(
    const SnackBar(content: Text('Sessão expirada. Entre novamente.')),
  );
}

class FlashSplashApp extends StatelessWidget {
  const FlashSplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, modo, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: messengerKey,
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
