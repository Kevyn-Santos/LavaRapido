import 'package:flutter/material.dart';

import 'package:flash_splash/features/acompanhamento/acompanhar_servicos.dart';
import 'package:flash_splash/features/agendamentos/agendamentos.dart';
import 'package:flash_splash/features/home/inicio_cliente.dart';
import 'package:flash_splash/features/perfil/perfil_cliente.dart';

class ContaCliente extends StatefulWidget {
  const ContaCliente({super.key});

  @override
  State<ContaCliente> createState() => _ContaClienteState();
}

class _ContaClienteState extends State<ContaCliente> {
  int _paginaSelecionada = 0;

  static const List<Widget> _paginas = [
    InicioCliente(),
    Agendamentos(),
    AcompanharServicos(),
    PerfilCliente(),
  ];

  @override
  Widget build(BuildContext context) {
    // Voltar em outra aba leva para a aba Início (a "tela anterior");
    // só da aba Início o voltar sai desta tela, sem pedir login de novo.
    return PopScope(
      canPop: _paginaSelecionada == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() {
            _paginaSelecionada = 0;
          });
        }
      },
      child: Scaffold(
      // IndexedStack mantém o estado de cada aba ao trocar entre elas.
      body: IndexedStack(
        index: _paginaSelecionada,
        children: _paginas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _paginaSelecionada,
        onDestinationSelected: (index) {
          setState(() {
            _paginaSelecionada = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Acompanhar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      ),
    );
  }
}
