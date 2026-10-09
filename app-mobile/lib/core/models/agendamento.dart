import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/models/veiculo.dart';

class Agendamento {
  final Servico servico;
  final Veiculo veiculo;
  final DateTime dataHora;

  const Agendamento({
    required this.servico,
    required this.veiculo,
    required this.dataHora,
  });
}
