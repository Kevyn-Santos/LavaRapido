import 'package:flutter/services.dart';

class Cpf {
  Cpf._();

  /// Se `false`, o login só exige 11 dígitos (útil para testes rápidos).
  /// Se `true`, confere também os dígitos verificadores.
  static const bool exigirDigitosVerificadores = true;

  static String somenteDigitos(String texto) {
    return texto.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool valido(String texto) {
    final d = somenteDigitos(texto);
    if (d.length != 11) return false;
    if (!exigirDigitosVerificadores) return true;

    // Rejeita sequências como 111.111.111-11.
    if (RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;

    int digito(int quantidade) {
      var soma = 0;
      for (var i = 0; i < quantidade; i++) {
        soma += int.parse(d[i]) * (quantidade + 1 - i);
      }
      final resto = (soma * 10) % 11;
      return resto == 10 ? 0 : resto;
    }

    return digito(9) == int.parse(d[9]) && digito(10) == int.parse(d[10]);
  }

  /// Formata 11 dígitos como 000.000.000-00. Outros tamanhos voltam como vieram.
  static String formatar(String texto) {
    final d = somenteDigitos(texto);
    if (d.length != 11) return texto;
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.'
        '${d.substring(6, 9)}-${d.substring(9)}';
  }
}

/// Máscara de CPF para campos de texto: aceita só números e formata
/// enquanto a pessoa digita.
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = Cpf.somenteDigitos(newValue.text);
    if (digitos.length > 11) {
      digitos = digitos.substring(0, 11);
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digitos[i]);
    }

    final texto = buffer.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
