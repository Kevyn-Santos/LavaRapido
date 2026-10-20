class Veiculo {
  final String id;
  final String modelo;
  final String placa;
  final String cor;

  /// Se [id] não for informado, é gerado um na hora (o back-end poderá
  /// fornecer o id real depois).
  Veiculo({
    String? id,
    required this.modelo,
    required this.placa,
    required this.cor,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Veiculo copiarCom({String? modelo, String? placa, String? cor}) {
    return Veiculo(
      id: id,
      modelo: modelo ?? this.modelo,
      placa: placa ?? this.placa,
      cor: cor ?? this.cor,
    );
  }

  @override
  bool operator ==(Object other) => other is Veiculo && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
