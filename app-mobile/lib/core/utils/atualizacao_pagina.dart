import 'package:flutter/material.dart';

import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/data/repositorio.dart';

/// Reconsulta os dados atuais do servidor ao tocar ou arrastar para atualizar.
/// Não altera registros: apenas executa GETs já disponíveis no repositório.
class AtualizacaoPagina {
  AtualizacaoPagina._();

  static Future<void> dadosCliente(BuildContext context, {bool catalogo = false}) async {
    try {
      if (catalogo) await Repositorio.carregarCatalogo();
      await Repositorio.carregarDadosCliente();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível atualizar. Tente novamente.')),
        );
      }
    }
  }
}
