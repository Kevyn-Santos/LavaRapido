import 'package:flutter/material.dart';

/// Guarda o tema atual do app. O `FlashSplashApp` escuta este valor e
/// reconstrói o MaterialApp quando ele muda.
class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  static bool get escuroAtivo => themeMode.value == ThemeMode.dark;

  static void definirEscuro(bool escuro) {
    themeMode.value = escuro ? ThemeMode.dark : ThemeMode.light;
  }
}
