import 'package:flutter/material.dart';

import 'package:flash_splash/core/session/sessao.dart';
import 'package:flash_splash/core/utils/cpf.dart';
import 'package:flash_splash/features/home/conta_cliente.dart';

class LoginCliente extends StatefulWidget {
  const LoginCliente({super.key});

  @override
  State<LoginCliente> createState() => _LoginClienteState();
}

class _LoginClienteState extends State<LoginCliente> {
  // Senha de demonstração. Troque por autenticação real (backend) antes
  // de publicar o app.
  static const String _senhaDemo = '1234';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _esconderSenha = true;

  @override
  void dispose() {
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  String? _validarCpf(String? valor) {
    final texto = valor ?? '';
    if (texto.trim().isEmpty) return 'Informe o CPF.';
    if (Cpf.somenteDigitos(texto).length != 11) {
      return 'O CPF deve ter 11 dígitos.';
    }
    if (!Cpf.valido(texto)) return 'CPF inválido.';
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe a senha.';
    return null;
  }

  void _entrar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_senhaController.text != _senhaDemo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha incorreta.')),
      );
      return;
    }

    Sessao.cpf = Cpf.somenteDigitos(_cpfController.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ContaCliente(),
      ),
    );
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
                  inputFormatters: [CpfInputFormatter()],
                  validator: _validarCpf,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    hintText: '000.000.000-00',
                    prefixIcon: Icon(Icons.person),
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
                    onPressed: _entrar,
                    child: const Text(
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
