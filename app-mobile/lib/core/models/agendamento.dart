import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/models/veiculo.dart';

enum StatusServico {
  pendente('Agendado'),
  emAndamento('Em andamento'),
  concluido('Concluído'),
  cancelado('Cancelado');

  final String rotulo;
  const StatusServico(this.rotulo);
}

class Agendamento {
  final String id;
  final List<Servico> servicos;
  final Veiculo veiculo;
  final DateTime dataHora;
  final StatusServico status;
  final bool pago;

  Servico get servico => servicos.first;
  double get valorTotal => servicos.fold(0, (total, item) => total + item.preco);

  Agendamento({
    String? id,
    required Servico servico,
    List<Servico>? servicos,
    required this.veiculo,
    required this.dataHora,
    this.status = StatusServico.pendente,
    this.pago = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
       servicos = List.unmodifiable(servicos ?? [servico]);

  Agendamento copiarCom({Veiculo? veiculo, StatusServico? status, bool? pago}) {
    return Agendamento(
      id: id,
      servico: servico,
      servicos: servicos,
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
