class Formatadores {
  Formatadores._();

  static String _doisDigitos(int n) => n.toString().padLeft(2, '0');

  static String data(DateTime d) {
    return '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}/${d.year}';
  }

  static String horaMinuto(int hora, int minuto) {
    return '${_doisDigitos(hora)}:${_doisDigitos(minuto)}';
  }

  static String dataHora(DateTime d) {
    return '${data(d)} às ${horaMinuto(d.hour, d.minute)}';
  }
}
