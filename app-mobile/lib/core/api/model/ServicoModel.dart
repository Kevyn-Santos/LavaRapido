/// Serviço do catálogo como a API manda: `{id_servico, nome, descricao, preco}`.
class ServicoModel {
  final String id;
  final String nome;
  final String descricao;
  final double preco;

  ServicoModel({
    required this.id,
    required this.nome,
    this.descricao = '',
    required this.preco,
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) {
    return ServicoModel(
      id: json['id_servico'].toString(),
      nome: (json['nome'] ?? '') as String,
      descricao: (json['descricao'] ?? '') as String,
      preco: (json['preco'] as num).toDouble(),
    );
  }
}
