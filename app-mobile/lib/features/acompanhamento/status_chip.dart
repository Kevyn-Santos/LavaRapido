import 'package:flutter/material.dart';

import 'package:flash_splash/core/models/agendamento.dart';
import 'package:flash_splash/core/theme/app_theme.dart';

/// Etiqueta colorida com a etapa do serviço (cores da paleta do projeto).
class StatusChip extends StatelessWidget {
  final StatusServico status;

  const StatusChip({super.key, required this.status});

  static Color fundo(StatusServico s) {
    switch (s) {
      case StatusServico.pendente:
        return AppTheme.pendenteFundo;
      case StatusServico.emAndamento:
        return AppTheme.andamentoFundo;
      case StatusServico.concluido:
        return AppTheme.concluidoFundo;
    }
  }

  static Color texto(StatusServico s) {
    switch (s) {
      case StatusServico.pendente:
        return AppTheme.pendenteTexto;
      case StatusServico.emAndamento:
        return AppTheme.andamentoTexto;
      case StatusServico.concluido:
        return AppTheme.concluidoTexto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.rotulo,
        style: TextStyle(
          color: texto(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
