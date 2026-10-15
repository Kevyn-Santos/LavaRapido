import 'package:flutter/material.dart';

class Servico {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final IconData icone;

  const Servico({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.icone,
  });

  String get precoFormatado {
    final valor = preco.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $valor';
  }
}
