import 'package:flutter/material.dart';

import 'package:flash_splash/core/models/servico.dart';

class ServicoCard extends StatelessWidget {
  final Servico servico;
  final bool selecionado;
  final VoidCallback? onTap;

  const ServicoCard({
    super.key,
    required this.servico,
    this.selecionado = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primary;

    return Card(
      shape: selecionado
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cor, width: 2),
            )
          : null,
      child: ListTile(
        leading: Icon(servico.icone, color: cor),
        title: Text(servico.nome),
        subtitle: Text(servico.descricao),
        trailing: Text(
          servico.precoFormatado,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}
