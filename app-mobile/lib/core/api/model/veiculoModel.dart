/// Veículo como a API manda: `{id_veiculo, placa, marca, modelo, cor}`.
class VeiculoModel {
  final String id;
  final String placa;
  final String marca;
  final String modelo;
  final String cor;

  VeiculoModel({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    this.cor = '',
  });

  factory VeiculoModel.fromJson(Map<String, dynamic> json) {
    return VeiculoModel(
      // O backend manda o id como número; o app guarda como texto.
      id: json['id_veiculo'].toString(),
      placa: (json['placa'] ?? '') as String,
      marca: (json['marca'] ?? '') as String,
      modelo: (json['modelo'] ?? '') as String,
      cor: (json['cor'] ?? '') as String,
    );
  }
}
