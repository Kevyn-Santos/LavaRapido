import 'package:flutter/material.dart';

import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/models/servico.dart';
import 'package:flash_splash/core/models/veiculo.dart';
import 'package:flash_splash/core/utils/formatadores.dart';
import 'package:flash_splash/features/home/servico_card.dart';

class NovoAgendamento extends StatefulWidget {
  final Servico? servicoInicial;
  const NovoAgendamento({super.key, this.servicoInicial});
  @override
  State<NovoAgendamento> createState() => _NovoAgendamentoState();
}

class _NovoAgendamentoState extends State<NovoAgendamento> {
  final List<Servico> _servicosSelecionados = [];
  Veiculo? _veiculo;
  DateTime? _data;
  String? _hora;
  List<String> _horarios = [];
  bool _carregandoHorarios = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.servicoInicial != null) _servicosSelecionados.add(widget.servicoInicial!);
  }

  Future<void> _escolherData() async {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data ?? hoje,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 90)),
    );
    if (!mounted || escolhida == null) return;
    setState(() { _data = escolhida; _hora = null; _horarios = []; });
    await _carregarHorarios(escolhida);
  }

  Future<void> _carregarHorarios(DateTime data) async {
    setState(() => _carregandoHorarios = true);
    try {
      final horarios = await Repositorio.horariosLivres(data);
      if (!mounted) return;
      setState(() => _horarios = horarios);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } finally {
      if (mounted) setState(() => _carregandoHorarios = false);
    }
  }

  Future<void> _confirmar() async {
    final veiculo = _veiculo;
    final data = _data;
    final hora = _hora;
    if (_servicosSelecionados.isEmpty || veiculo == null || data == null || hora == null || _salvando) return;
    final partes = hora.split(':');
    final dataHora = DateTime(data.year, data.month, data.day, int.parse(partes[0]), int.parse(partes[1]));
    if (!dataHora.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escolha um horário no futuro.')));
      return;
    }
    setState(() => _salvando = true);
    try {
      await Repositorio.criarAgendamento(veiculo: veiculo, servicosSelecionados: List.unmodifiable(_servicosSelecionados), dataHora: dataHora);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agendamento confirmado com sucesso!')));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
      if (mounted && _data != null) await _carregarHorarios(_data!);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _titulo(String texto) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      appBar: AppBar(title: const Text('Novo agendamento')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _titulo('1. Serviços (selecione um ou mais)'),
          ValueListenableBuilder<List<Servico>>(
            valueListenable: Repositorio.servicos,
            builder: (context, lista, _) => Column(children: [
              for (final servico in lista)
                ServicoCard(servico: servico, selecionado: _servicosSelecionados.contains(servico),
                  onTap: () => setState(() {
                    if (_servicosSelecionados.contains(servico)) {
                      _servicosSelecionados.remove(servico);
                    } else {
                      _servicosSelecionados.add(servico);
                    }
                  })),
              if (lista.isEmpty) const Text('Nenhum serviço disponível no servidor.'),
            ]),
          ),
          _titulo('2. Veículo'),
          ValueListenableBuilder<List<Veiculo>>(
            valueListenable: Repositorio.veiculos,
            builder: (context, lista, _) {
              if (lista.isEmpty) return const Text('Cadastre um veículo em Perfil > Meus veículos para continuar.');
              return Wrap(spacing: 8, runSpacing: 8, children: [
                for (final v in lista)
                  ChoiceChip(label: Text('${v.marca} ${v.modelo} • ${v.placa}'), selected: v == _veiculo,
                    onSelected: (_) => setState(() => _veiculo = v)),
              ]);
            },
          ),
          _titulo('3. Data'),
          Card(child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(data == null ? 'Escolher data' : Formatadores.data(data)),
            trailing: const Icon(Icons.chevron_right), onTap: _escolherData,
          )),
          _titulo('4. Horários disponíveis'),
          if (data == null) const Text('Escolha uma data para consultar os horários livres.'),
          if (_carregandoHorarios) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
          if (data != null && !_carregandoHorarios && _horarios.isEmpty)
            const Text('Não há horários disponíveis nesta data.'),
          if (_horarios.isNotEmpty)
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final h in _horarios)
                ChoiceChip(label: Text(h), selected: _hora == h, onSelected: (_) => setState(() => _hora = h)),
            ]),
          const SizedBox(height: 24),
          SizedBox(height: 55, child: ElevatedButton(
            onPressed: _servicosSelecionados.isNotEmpty && _veiculo != null && data != null && _hora != null && !_salvando ? _confirmar : null,
            child: _salvando ? const CircularProgressIndicator() : const Text('CONFIRMAR AGENDAMENTO', style: TextStyle(fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }
}
