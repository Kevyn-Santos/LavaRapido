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

class PerfilCliente extends StatelessWidget {
  const PerfilCliente({super.key});

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
      ),
      body: ListView(
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
          const Center(
            child: Text(
              'Cliente Fast Splash',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
    );
  }
}
