import 'package:flutter/material.dart';

class Notificacoes extends StatelessWidget {
  const Notificacoes({super.key});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.local_car_wash, color: cor),
              title: const Text('Bem-vindo ao Flash Splash!'),
              subtitle: const Text(
                'Aqui aparecerão seus avisos e novidades.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications_active, color: cor),
              title: const Text('Agendamentos'),
              subtitle: const Text(
                'Você receberá avisos sobre seus horários.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
