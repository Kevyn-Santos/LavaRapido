import 'package:flutter/material.dart';

/// Tipo de serviço. Os 4 tipos virão do back-end (ver [Repositorio]).
class Servico {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final IconData icone;

  const Servico({
    required this.id,
    required this.nome,
    this.descricao = '',
    required this.preco,
    this.icone = Icons.local_car_wash,
  });

  String get precoFormatado {
    final valor = preco.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $valor';
  }

  @override
  bool operator ==(Object other) => other is Servico && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
