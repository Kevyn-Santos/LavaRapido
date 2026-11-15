/// Agendamento como a API manda: `{id_agendamento, id_veiculo, data_agendamento ("yyyy/MM/dd"),
/// hora_agendamento, id_servico[], total_servico, status_pagamento, forma_pagamento}`.
class AgendamentoModel {
  final String id;
  final String idVeiculo;
  final DateTime data;
  final String horario;
  final List<String> idServicos;
  final double total;
  final String? statusPagamento;
  final String? formaPagamento;

  AgendamentoModel({
    required this.id,
    required this.idVeiculo,
    required this.data,
    required this.horario,
    required this.idServicos,
    required this.total,
    this.statusPagamento,
    this.formaPagamento,
  });

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) {
    final partes = (json['data_agendamento'] as String).split('/');
    return AgendamentoModel(
      id: json['id_agendamento'].toString(),
      idVeiculo: json['id_veiculo'].toString(),
      data: DateTime(int.parse(partes[0]), int.parse(partes[1]), int.parse(partes[2])),
      horario: (json['hora_agendamento'] ?? '').toString(),
      idServicos: [for (final id in json['id_servico'] as List<dynamic>) id.toString()],
      total: (json['total_servico'] as num).toDouble(),
      statusPagamento: json['status_pagamento'] as String?,
      formaPagamento: json['forma_pagamento'] as String?,
    );
  }
}
