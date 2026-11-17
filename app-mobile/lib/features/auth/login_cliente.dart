import 'package:flutter/material.dart';

import 'package:flash_splash/core/session/sessao.dart';
import 'package:flash_splash/core/data/repositorio.dart';
import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/cliente_api.dart';
import 'package:flash_splash/core/utils/cpf.dart';
import 'package:flash_splash/features/agendamentos/novo_agendamento.dart';
import 'package:flash_splash/features/home/conta_cliente.dart';

class LoginCliente extends StatefulWidget {
  /// Quando verdadeiro, depois do login já abre o novo agendamento
  /// (vindo do botão "Agendar lavagem").
  final bool abrirAgendamento;

  const LoginCliente({super.key, this.abrirAgendamento = false});

  @override
  State<LoginCliente> createState() => _LoginClienteState();
}

class _LoginClienteState extends State<LoginCliente> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final ClienteApi _clienteApi = ClienteApi(apiClient: APIClient());

  bool _esconderSenha = true;
  bool _carregando = false;

  @override
  void dispose() {
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  String? _validarCpf(String? valor) {
    final cpf = Cpf.somenteDigitos(valor ?? '');
    if (cpf.isEmpty) return 'Informe o CPF.';
    if (!Cpf.valido(cpf)) return 'CPF inválido.';
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe a senha.';
    return null;
  }

  Future<void> _entrar() async {
    if (_carregando) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _carregando = true);
    try {
      final cliente = await _clienteApi.login(
        Cpf.somenteDigitos(_cpfController.text),
        _senhaController.text,
      );
      Sessao.id = cliente.id;
      Sessao.cpf = Cpf.somenteDigitos(cliente.cpf);
      try {
        await Repositorio.carregarCatalogo();
        await Repositorio.carregarDadosCliente();
      } on ApiException catch (e) {
        _avisar('Login realizado, mas não foi possível carregar seus dados: ${e.mensagem}');
      }
    } on ApiException catch (e) {
      _avisar(e.mensagem);
      return;
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
    if (!mounted) return;

    final navegador = Navigator.of(context);
    navegador.pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ContaCliente(),
      ),
    );
    if (widget.abrirAgendamento) {
      navegador.push(
        MaterialPageRoute(
          builder: (_) => const NovoAgendamento(),
        ),
      );
    }
  }

  void _avisar(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login do cliente'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 25),
                Icon(
                  Icons.local_car_wash,
                  size: 75,
                  color: cores.primary,
                ),
                const SizedBox(height: 15),
                Text(
                  'FAST SPLASH',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: cores.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Acesse sua conta',
                  style: TextStyle(
                    color: cores.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  inputFormatters: [CpfInputFormatter()],
                  validator: _validarCpf,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    hintText: '000.000.000-00',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _senhaController,
                  obscureText: _esconderSenha,
                  textInputAction: TextInputAction.done,
                  validator: _validarSenha,
                  onFieldSubmitted: (_) => _entrar(),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      tooltip: _esconderSenha ? 'Mostrar senha' : 'Ocultar senha',
                      icon: Icon(
                        _esconderSenha
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _esconderSenha = !_esconderSenha;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    child: _carregando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'ENTRAR',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'A recuperação de senha será implementada '
                          'posteriormente.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Esqueci minha senha'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
