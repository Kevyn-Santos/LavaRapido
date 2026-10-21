import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/models/veiculo.dart';

/// Etapas do acompanhamento de um serviço.
enum StatusServico {
  pendente('Pendente'),
  emAndamento('Em andamento'),
  concluido('Concluído');

  final String rotulo;
  const StatusServico(this.rotulo);
}

class Agendamento {
  final String id;
  final Servico servico;
  final Veiculo veiculo;
  final DateTime dataHora;
  final StatusServico status;
  final bool pago;

  Agendamento({
    String? id,
    required this.servico,
    required this.veiculo,
    required this.dataHora,
    this.status = StatusServico.pendente,
    this.pago = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Agendamento copiarCom({Veiculo? veiculo, StatusServico? status, bool? pago}) {
    return Agendamento(
      id: id,
      servico: servico,
      veiculo: veiculo ?? this.veiculo,
      dataHora: dataHora,
      status: status ?? this.status,
      pago: pago ?? this.pago,
    );
  }

  @override
  bool operator ==(Object other) => other is Agendamento && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
