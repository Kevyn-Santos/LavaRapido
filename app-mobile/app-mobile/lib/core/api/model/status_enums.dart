/// Enums que espelham os ENUMs do MySQL / da API. Cada um converte o texto do JSON
/// (`fromJson`) e devolve o texto que a API espera (`valor`).

/// Ciclo do agendamento: AGENDADO -> CANCELADO | CONCLUIDO.
enum StatusAgendamento {
  agendado('AGENDADO'),
  cancelado('CANCELADO'),
  concluido('CONCLUIDO');

  final String valor;
  const StatusAgendamento(this.valor);

  /// `null` ou valor desconhecido -> `null` (o app não deve quebrar se a API ganhar um status novo).
  static StatusAgendamento? fromJson(String? texto) {
    for (final s in values) {
      if (s.valor == texto) return s;
    }
    return null;
  }
}

/// Ciclo do atendimento: AGUARDANDO -> EM_LAVAGEM -> FINALIZADO -> ENTREGUE.
/// A API manda `null` enquanto o agendamento não virou atendimento.
enum StatusAtendimento {
  aguardando('AGUARDANDO'),
  emLavagem('EM_LAVAGEM'),
  finalizado('FINALIZADO'),
  entregue('ENTREGUE');

  final String valor;
  const StatusAtendimento(this.valor);

  static StatusAtendimento? fromJson(String? texto) {
    for (final s in values) {
      if (s.valor == texto) return s;
    }
    return null;
  }
}

/// Ciclo do pagamento: PENDENTE -> PAGO | CANCELADO.
enum StatusPagamento {
  pendente('PENDENTE'),
  pago('PAGO'),
  cancelado('CANCELADO');

  final String valor;
  const StatusPagamento(this.valor);

  static StatusPagamento? fromJson(String? texto) {
    for (final s in values) {
      if (s.valor == texto) return s;
    }
    return null;
  }
}

/// Forma de pagamento. O app só pode enviar [pix], [credito] e [debito] em
/// `POST /agendamentos/{id}/pagar`; [dinheiro] é exclusivo do atendente (site) e só chega
/// do servidor, na listagem.
enum FormaPagamento {
  pix('PIX'),
  credito('CREDITO'),
  debito('DEBITO'),
  dinheiro('DINHEIRO');

  final String valor;
  const FormaPagamento(this.valor);

  /// Formas que o cliente pode escolher no app.
  static const List<FormaPagamento> doApp = [pix, credito, debito];

  static FormaPagamento? fromJson(String? texto) {
    for (final f in values) {
      if (f.valor == texto) return f;
    }
    return null;
  }
}
