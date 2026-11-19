class ClienteModel {
  final String id;
  final String nome;
  final String email;
  final String cpf;
  final String telefone;

  ClienteModel({
    required this.id,
    required this.nome,
    required this.email,
    this.cpf = '',
    this.telefone = '',
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      // O backend manda o id como número; a sessão guarda como texto.
      id: json['id'].toString(),
      nome: (json['nome'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      cpf: (json['cpf'] ?? '') as String,
      telefone: (json['telefone'] ?? '') as String,
    );
  }
}
