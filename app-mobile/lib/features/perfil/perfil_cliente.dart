import 'package:flutter/material.dart';

import 'package:flash_splash/core/session/sessao.dart';
import 'package:flash_splash/core/theme/app_theme.dart';
import 'package:flash_splash/core/utils/cpf.dart';
import 'package:flash_splash/features/agendamentos/agendamentos.dart';
import 'package:flash_splash/features/auth/tela_inicial.dart';
import 'package:flash_splash/features/configuracoes/configuracoes.dart';
import 'package:flash_splash/features/pagamento/pagamento.dart';
import 'package:flash_splash/features/perfil/meus_veiculos.dart';
import 'package:flash_splash/features/perfil/notificacoes.dart';
import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/cliente_api.dart';
import 'package:flash_splash/core/api/model/cliente_model.dart';

class PerfilCliente extends StatefulWidget {
  const PerfilCliente({super.key});

  @override
  State<PerfilCliente> createState() => _PerfilClienteState();
}

class _PerfilClienteState extends State<PerfilCliente> {
  late final ClienteApi _clienteApi;
  late Future<ClienteModel> _futuroCliente;

  @override
  void initState() {
    super.initState();
    _clienteApi = ClienteApi(apiClient: APIClient());
    _futuroCliente = _clienteApi.buscar(); // o servidor identifica o cliente pela sessão
  }

  Future<void> _atualizar() async {
    final futuro = _clienteApi.buscar();
    setState(() => _futuroCliente = futuro);
    try {
      await futuro;
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o perfil.')),
      );
    }
  }

  Future<void> _editarPerfil(ClienteModel cliente) async {
    final atualizado = await showDialog<ClienteModel>(
      context: context,
      builder: (_) => _EditarPerfilDialog(cliente: cliente, api: _clienteApi),
    );
    if (atualizado != null && mounted) {
      setState(() => _futuroCliente = Future.value(atualizado));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso.')),
      );
    }
  }

  Widget _opcao(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required Widget destino,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icone),
        title: Text(titulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destino),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final cpf = Sessao.cpf.isEmpty ? '—' : Cpf.formatar(Sessao.cpf);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: [
          IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh), onPressed: _atualizar),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizar,
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 15),
          const CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.cianoEscuro,
            child: Icon(
              Icons.person,
              size: 55,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: FutureBuilder<ClienteModel>(
              future: _futuroCliente,
              builder: (context, snapshot) {
                final cliente = snapshot.data;
                final nome = cliente?.nome ?? '';
                return Column(
                  children: [
                    Text(
                      nome.isEmpty ? 'Cliente Fast Splash' : nome,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (cliente != null)
                      TextButton.icon(
                        onPressed: () => _editarPerfil(cliente),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Editar meus dados'),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              'CPF: $cpf',
              style: TextStyle(color: cores.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 25),
          _opcao(
            context,
            icone: Icons.calendar_month,
            titulo: 'Meus agendamentos',
            destino: const Agendamentos(),
          ),
          _opcao(
            context,
            icone: Icons.directions_car,
            titulo: 'Meus veículos',
            destino: const MeusVeiculos(),
          ),
          _opcao(
            context,
            icone: Icons.credit_card,
            titulo: 'Formas de pagamento',
            destino: const Pagamento(),
          ),
          _opcao(
            context,
            icone: Icons.notifications,
            titulo: 'Notificações',
            destino: const Notificacoes(),
          ),
          _opcao(
            context,
            icone: Icons.settings,
            titulo: 'Configurações',
            destino: const Configuracoes(),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () {
              Sessao.limpar();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const TelaInicial(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            label: const Text(
              'Sair da conta',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
        ),
      ),
    );
  }
}


class _EditarPerfilDialog extends StatefulWidget {
  final ClienteModel cliente;
  final ClienteApi api;
  const _EditarPerfilDialog({required this.cliente, required this.api});

  @override
  State<_EditarPerfilDialog> createState() => _EditarPerfilDialogState();
}

class _EditarPerfilDialogState extends State<_EditarPerfilDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.cliente.nome);
  late final _telefone = TextEditingController(text: widget.cliente.telefone);
  late final _email = TextEditingController(text: widget.cliente.email);
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false) || _salvando) return;
    setState(() => _salvando = true);
    try {
      final atualizado = await widget.api.atualizar(
        nome: _nome.text.trim(),
        telefone: _telefone.text.trim(),
        email: _email.text.trim(),
      );
      if (mounted) Navigator.pop(context, atualizado);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Editar meus dados'),
    content: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: _nome, decoration: const InputDecoration(labelText: 'Nome'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome.' : null),
          TextFormField(controller: _telefone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone')),
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail'), validator: (v) => (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Informe um e-mail válido.' : null),
          const SizedBox(height: 8),
          const Text('O CPF não pode ser alterado por esta tela.'),
        ]),
      ),
    ),
    actions: [
      TextButton(onPressed: _salvando ? null : () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(onPressed: _salvando ? null : _salvar, child: _salvando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar')),
    ],
  );
}
