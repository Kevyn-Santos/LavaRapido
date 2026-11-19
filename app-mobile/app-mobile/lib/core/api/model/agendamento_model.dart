import 'status_enums.dart';

/// Serviço de um agendamento: [valor] é o preço **praticado na época** (não o preço atual do
/// catálogo); a soma dos [valor] é o `total_servico` do agendamento.
class ServicoDoAgendamento {
  final String id;
  final String nome;
  final double valor;

  const ServicoDoAgendamento({required this.id, required this.nome, required this.valor});

  factory ServicoDoAgendamento.fromJson(Map<String, dynamic> json) => ServicoDoAgendamento(
        id: json['id_servico'].toString(),
        nome: (json['nome'] ?? '') as String,
        valor: (json['valor'] as num).toDouble(),
      );
}

/// Agendamento como a API manda (`GET /agendamentos`):
/// `{id_agendamento, id_veiculo, data_agendamento ("yyyy-MM-dd"), hora_agendamento ("HH:mm"),
/// id_servico[], servicos[{id_servico, nome, valor}], total_servico, status, status_atendimento, status_pagamento, forma_pagamento}`.
///
/// Os campos de status são `null` quando o servidor não os informa (ex.: [statusAtendimento]
/// só existe depois que o agendamento vira atendimento; [formaPagamento] só depois de pago).
class AgendamentoModel {
  final String id;
  final String idVeiculo;
  final DateTime data;
  final String horario;
  final List<String> idServicos;

  /// Todos os serviços do agendamento, com nome e valor praticado (para exibir na consulta).
  final List<ServicoDoAgendamento> servicos;
  final double total;
  final StatusAgendamento? status;
  final StatusAtendimento? statusAtendimento;
  final StatusPagamento? statusPagamento;
  final FormaPagamento? formaPagamento;

  AgendamentoModel({
    required this.id,
    required this.idVeiculo,
    required this.data,
    required this.horario,
    required this.idServicos,
    this.servicos = const [],
    required this.total,
    this.status,
    this.statusAtendimento,
    this.statusPagamento,
    this.formaPagamento,
  });

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) {
    final partes = (json['data_agendamento'] as String).split('-'); // yyyy-MM-dd
    return AgendamentoModel(
      id: json['id_agendamento'].toString(),
      idVeiculo: json['id_veiculo'].toString(),
      data: DateTime(int.parse(partes[0]), int.parse(partes[1]), int.parse(partes[2])),
      horario: (json['hora_agendamento'] ?? '').toString(),
      idServicos: [for (final id in json['id_servico'] as List<dynamic>) id.toString()],
      servicos: [
        for (final s in (json['servicos'] as List<dynamic>? ?? const []))
          ServicoDoAgendamento.fromJson(s as Map<String, dynamic>),
      ],
      total: (json['total_servico'] as num).toDouble(),
      status: StatusAgendamento.fromJson(json['status'] as String?),
      statusAtendimento: StatusAtendimento.fromJson(json['status_atendimento'] as String?),
      statusPagamento: StatusPagamento.fromJson(json['status_pagamento'] as String?),
      formaPagamento: FormaPagamento.fromJson(json['forma_pagamento'] as String?),
    );
  }
}
