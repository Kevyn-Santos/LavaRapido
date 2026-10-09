import 'package:flutter/material.dart';

/// Paleta e temas do Flash Splash (mesma paleta do site do grupo).
class AppTheme {
  AppTheme._();

  // ---- Base / fundo (gradiente de profundidade) ----
  static const Color petroleoEscuro = Color(0xFF0A2E3B);
  static const Color petroleoMedio = Color(0xFF123F52);

  // ---- Acentos ----
  /// Ciano: bolhas, ondas, seleção, brilho, ícone/logo.
  static const Color ciano = Color(0xFF4FC7DB);

  /// Ciano escuro: texto/ícone sobre fundo claro.
  static const Color cianoEscuro = Color(0xFF0A5A68);

  /// Coral: ação principal (botões).
  static const Color coral = Color(0xFFFF7A5C);
  static const Color coralEscuro = Color(0xFFC64A32);

  // ---- Neutros ----
  static const Color superficie = Color(0xFFF5F8F7);
  static const Color bordaClara = Color(0xFFDCE3E1);
  static const Color tinta = Color(0xFF14262C);
  static const Color textoSecundario = Color(0xFF5E6F76);
  static const Color branco = Color(0xFFFFFFFF);

  // ---- Status (para uso futuro nos agendamentos) ----
  static const Color pendenteFundo = Color(0xFFEDF1F2);
  static const Color pendenteTexto = Color(0xFF5B6873);
  static const Color andamentoFundo = Color(0xFFFCEFD9);
  static const Color andamentoTexto = Color(0xFF7A5108);
  static const Color concluidoFundo = Color(0xFFDFF3E9);
  static const Color concluidoTexto = Color(0xFF0F6E4E);

  /// Gradiente de fundo das telas "de vitrine" (tela inicial).
  static const LinearGradient gradienteFundo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [petroleoEscuro, petroleoMedio],
  );

  static InputDecorationTheme _campos(Color preenchimento) {
    return InputDecorationTheme(
      filled: true,
      fillColor: preenchimento,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  static ElevatedButtonThemeData _botaoPrincipal() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: coral,
        // Texto escuro sobre o coral dá mais contraste que branco.
        foregroundColor: tinta,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _botaoSecundario(Color cor) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cor,
        side: BorderSide(color: cor, width: 1.5),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  static ThemeData get escuro {
    final cores = ColorScheme.fromSeed(
      seedColor: ciano,
      brightness: Brightness.dark,
    ).copyWith(
      primary: ciano,
      onPrimary: petroleoEscuro,
      secondary: coral,
      onSecondary: tinta,
      secondaryContainer: cianoEscuro,
      onSecondaryContainer: branco,
      surface: petroleoEscuro,
      onSurface: superficie,
      onSurfaceVariant: bordaClara,
      outline: const Color(0x994FC7DB),
      surfaceContainerLow: petroleoMedio,
      surfaceContainer: petroleoMedio,
      surfaceContainerHigh: petroleoMedio,
      surfaceContainerHighest: petroleoMedio,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cores,
      scaffoldBackgroundColor: petroleoEscuro,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: petroleoMedio,
      ),
      elevatedButtonTheme: _botaoPrincipal(),
      outlinedButtonTheme: _botaoSecundario(ciano),
      // Branco com ~7% de opacidade.
      inputDecorationTheme: _campos(const Color(0x12FFFFFF)),
    );
  }

  static ThemeData get claro {
    final cores = ColorScheme.fromSeed(
      seedColor: cianoEscuro,
      brightness: Brightness.light,
    ).copyWith(
      primary: cianoEscuro,
      onPrimary: branco,
      secondary: coral,
      onSecondary: tinta,
      secondaryContainer: cianoEscuro,
      onSecondaryContainer: branco,
      surface: superficie,
      onSurface: tinta,
      onSurfaceVariant: textoSecundario,
      outline: const Color(0x805E6F76),
      outlineVariant: bordaClara,
      surfaceContainerLow: branco,
      surfaceContainer: branco,
      surfaceContainerHigh: branco,
      surfaceContainerHighest: bordaClara,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cores,
      scaffoldBackgroundColor: superficie,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: branco,
      ),
      elevatedButtonTheme: _botaoPrincipal(),
      outlinedButtonTheme: _botaoSecundario(cianoEscuro),
      inputDecorationTheme: _campos(branco),
    );
  }
}
