import 'package:flutter/material.dart';

import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/models/veiculo.dart';
import 'package:flash_splash/core/utils/formatadores.dart';
import 'package:flash_splash/features/home/servico_card.dart';

class NovoAgendamento extends StatefulWidget {
  const NovoAgendamento({super.key});

  @override
  State<NovoAgendamento> createState() => _NovoAgendamentoState();
}

class _NovoAgendamentoState extends State<NovoAgendamento> {
  Servico? _servico;
  Veiculo? _veiculo;
  DateTime? _data;
  TimeOfDay? _hora;

  bool get _completo =>
      _servico != null && _veiculo != null && _data != null && _hora != null;

  Future<void> _escolherData() async {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data ?? hoje,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 90)),
    );
    if (!mounted) return;
    if (escolhida != null) {
      setState(() {
        _data = escolhida;
      });
    }
  }

  Future<void> _escolherHora() async {
    final escolhida = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (!mounted) return;
    if (escolhida != null) {
      setState(() {
        _hora = escolhida;
      });
    }
  }

  void _confirmar() {
    final servico = _servico;
    final veiculo = _veiculo;
    final data = _data;
    final hora = _hora;
    if (servico == null || veiculo == null || data == null || hora == null) {
      return;
    }

    final dataHora = DateTime(
      data.year,
      data.month,
      data.day,
      hora.hour,
      hora.minute,
    );

    if (!dataHora.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha um horário no futuro.')),
      );
      return;
    }

    Repositorio.adicionarAgendamento(
      Agendamento(servico: servico, veiculo: veiculo, dataHora: dataHora),
    );

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Agendamento confirmado!')),
    );
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final hora = _hora;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo agendamento'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _titulo('1. Serviço'),
          for (final servico in Repositorio.servicos)
            ServicoCard(
              servico: servico,
              selecionado: servico == _servico,
              onTap: () {
                setState(() {
                  _servico = servico;
                });
              },
            ),

          _titulo('2. Veículo'),
          ValueListenableBuilder<List<Veiculo>>(
            valueListenable: Repositorio.veiculos,
            builder: (context, lista, _) {
              if (lista.isEmpty) {
                return const Text(
                  'Cadastre um veículo em Perfil > Meus veículos '
                  'para continuar.',
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final veiculo in lista)
                    ChoiceChip(
                      label: Text('${veiculo.modelo} • ${veiculo.placa}'),
                      selected: veiculo == _veiculo,
                      onSelected: (_) {
                        setState(() {
                          _veiculo = veiculo;
                        });
                      },
                    ),
                ],
              );
            },
          ),

          _titulo('3. Data e horário'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                data == null ? 'Escolher data' : Formatadores.data(data),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _escolherData,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                hora == null
                    ? 'Escolher horário'
                    : Formatadores.horaMinuto(hora.hour, hora.minute),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _escolherHora,
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _completo ? _confirmar : null,
              child: const Text(
                'CONFIRMAR AGENDAMENTO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
