import 'package:flutter/material.dart';

import 'package:flash_splash/core/theme/theme_controller.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({super.key});

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  bool _notificacoes = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notificações'),
            subtitle: const Text('Receber avisos do Fast Splash'),
            value: _notificacoes,
            onChanged: (valor) {
              setState(() {
                _notificacoes = valor;
              });
            },
          ),

          // Liga o switch ao tema do app de verdade.
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, modo, _) {
              return SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Modo escuro'),
                subtitle: const Text('Usar aparência escura'),
                value: modo == ThemeMode.dark,
                onChanged: (valor) {
                  ThemeController.definirEscuro(valor);
                },
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Alterar senha'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tela de alteração de senha.'),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ajuda'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Ajuda'),
                    content: const Text(
                      'Entre em contato com o Flash Splash '
                      'para receber suporte.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('FECHAR'),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o aplicativo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Flash Splash',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    'Aplicativo de gerenciamento de lava-rápido.',
              );
            },
          ),
        ],
      ),
    );
  }
}
