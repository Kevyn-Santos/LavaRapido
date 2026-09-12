-- =====================================================
-- DADOS INICIAIS PARA DESENVOLVIMENTO E TESTES
-- =====================================================
-- IMPORTANTE:
-- Este arquivo deve ser executado após o schema.sql
-- em um banco recém-criado e sem dados.
-- Os relacionamentos abaixo assumem que os IDs
-- AUTO_INCREMENT começam em 1.
-- =====================================================

USE lava_rapido;

-- =====================================================
-- CLIENTES
-- =====================================================

INSERT INTO cliente (
	nome,
    cpf,
    telefone,
    email,
    senha_hash
) VALUES
(
	'Joao Silva',
    '11111111111',
    '11999990001',
    'joao.silva@teste.com',
    'HASH_TESTE_CLIENTE_01'
),
(
	'Maria Oliveira',
    '22222222222',
    '11999990002',
    'maria.oliveira@teste.com',
    'HASH_TESTE_CLIENTE_02'
),
(
    'Carlos Santos',
    '33333333333',
    '11999990003',
    'carlos.santos@teste.com',
    'HASH_TESTE_CLIENTE_03'
);

-- =====================================================
-- VEICULOS
-- =====================================================

INSERT INTO veiculo (
    id_cliente,
    placa,
    marca,
    modelo,
    cor
) VALUES
(
    1,
    'ABC1D23',
    'Volkswagen',
    'Gol',
    'Prata'
),
(
    1,
    'DEF4G56',
    'Toyota',
    'Corolla',
    'Preto'
),
(
    2,
    'GHI7J89',
    'Honda',
    'Civic',
    'Branco'
),
(
    3,
    'KLM1N23',
    'Chevrolet',
    'Onix',
    'Vermelho'
);

-- =====================================================
-- SERVICOS
-- =====================================================

INSERT INTO servico (
    nome,
    descricao,
    preco
) VALUES
(
    'Lavagem Simples',
    'Lavagem externa do veiculo',
    35.00
),
(
    'Lavagem Completa',
    'Lavagem externa e limpeza interna',
    60.00
),
(
    'Enceramento',
    'Aplicacao de cera para protecao e brilho',
    40.00
),
(
    'Higienizacao Interna',
    'Limpeza detalhada do interior do veiculo',
    120.00
);

-- =====================================================
-- AGENDAMENTOS
-- =====================================================

INSERT INTO agendamento (
    id_veiculo,
    data,
    horario,
    status
) VALUES
(
    1,
    '2026-09-15',
    '09:00:00',
    'AGENDADO'
),
(
    2,
    '2026-09-15',
    '10:30:00',
    'AGENDADO'
),
(
    3,
    '2026-09-16',
    '14:00:00',
    'CONCLUIDO'
),
(
    4,
    '2026-09-17',
    '08:30:00',
    'CANCELADO'
);

-- =====================================================
-- AGENDAMENTO_SERVICO
-- =====================================================

INSERT INTO agendamento_servico (
    id_agendamento,
    id_servico,
    valor_praticado
) VALUES
(
    1,
    1,
    35.00
),
(
    1,
    3,
    40.00
),
(
    2,
    2,
    60.00
),
(
    3,
    2,
    60.00
),
(
    3,
    4,
    120.00
),
(
    4,
    1,
    35.00
);

-- =====================================================
-- COLABORADORES
-- =====================================================

INSERT INTO colaborador (
    nome,
    cargo,
    nivel_acesso,
    email,
    senha_hash
) VALUES
(
    'Ana Souza',
    'Gerente',
    'ADMINISTRADOR',
    'ana.souza@teste.com',
    'HASH_TESTE_COLABORADOR_01'
),
(
    'Bruno Lima',
    'Atendente',
    'ATENDENTE',
    'bruno.lima@teste.com',
    'HASH_TESTE_COLABORADOR_02'
),
(
    'Diego Martins',
    'Lavador',
    'OPERACIONAL',
    'diego.martins@teste.com',
    'HASH_TESTE_COLABORADOR_03'
),
(
    'Fernanda Alves',
    'Lavadora',
    'OPERACIONAL',
    'fernanda.alves@teste.com',
    'HASH_TESTE_COLABORADOR_04'
);

-- =====================================================
-- ATENDIMENTOS
-- =====================================================

INSERT INTO atendimento (
    id_agendamento,
    status,
    data_inicio,
    data_fim
) VALUES
(
    2,
    'EM_LAVAGEM',
    '2026-09-15 10:35:00',
    NULL
),
(
    3,
    'ENTREGUE',
    '2026-09-16 14:05:00',
    '2026-09-16 15:40:00'
);

-- =====================================================
-- COLABORADOR_ATENDIMENTO
-- =====================================================

INSERT INTO colaborador_atendimento (
    id_colaborador,
    id_atendimento
) VALUES
(
    3,
    1
),
(
    3,
    2
),
(
    4,
    2
);

-- =====================================================
-- PAGAMENTOS
-- =====================================================

INSERT INTO pagamento (
    id_atendimento,
    data_pagamento,
    valor,
    forma_pagamento,
    status_pagamento
) VALUES
(
    1,
    NULL,
    60.00,
    'CREDITO',
    'PENDENTE'
),
(
    2,
    '2026-09-16 15:45:00',
    180.00,
    'PIX',
    'PAGO'
);