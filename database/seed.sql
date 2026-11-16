-- FastSplash | Dados demonstrativos para desenvolvimento/apresentação
-- Compatível com schema_fastSplash_final_proposta.sql (3 status e RESTRICT).
-- Execute APENAS após o schema.sql, em banco novo e vazio.
-- Nunca aplique em um banco com dados existentes.
-- Este arquivo inclui usuários DEMONSTRATIVOS com senha compartilhada:
--   FastSplash@2026
-- TROQUE/REMOVA essas contas antes de qualquer uso real ou publicação.
-- As datas dos agendamentos são relativas ao dia da execução.
-- NÃO é um script de migração ou de produção.

USE lava_rapido;
START TRANSACTION;

-- Serviços de exemplo
INSERT INTO servico (nome, descricao, preco) VALUES
('Lavagem Simples', 'Limpeza externa do veículo', 35.00),
('Lavagem Completa', 'Limpeza externa e interna', 60.00),
('Enceramento', 'Aplicação de cera de proteção', 40.00),
('Higienização Interna', 'Limpeza detalhada do interior', 120.00);

-- Pessoas fictícias; todos os logins demonstrativos compartilham senha de teste.


INSERT INTO cliente (nome, cpf, telefone, email, senha_hash) VALUES
('João Silva', '11111111111', '11999990001', 'joao.silva@example.com', '$2y$10$q2Ze/R4sf5RQcZZ.eoywsuCKVk35Mcf62aLlpQ.EfS9eqZPikXmS2'),
('Maria Oliveira', '22222222222', '11999990002', 'maria.oliveira@example.com', '$2y$10$q2Ze/R4sf5RQcZZ.eoywsuCKVk35Mcf62aLlpQ.EfS9eqZPikXmS2'),
('Carlos Santos', '33333333333', '11999990003', 'carlos.santos@example.com', '$2y$10$q2Ze/R4sf5RQcZZ.eoywsuCKVk35Mcf62aLlpQ.EfS9eqZPikXmS2');


INSERT INTO colaborador (nome, cargo, nivel_acesso, email, senha_hash) VALUES
('Kelsey Luciano', 'Administrador', 'ADMINISTRADOR', 'kelsey@example.com', '$2y$10$q2Ze/R4sf5RQcZZ.eoywsuCKVk35Mcf62aLlpQ.EfS9eqZPikXmS2'),
('Bruno Lima', 'Atendente', 'ATENDENTE', 'bruno.lima@example.com', '$2y$10$q2Ze/R4sf5RQcZZ.eoywsuCKVk35Mcf62aLlpQ.EfS9eqZPikXmS2'),
('Diego Martins', 'Lavador', 'OPERACIONAL', 'diego.martins@example.com', '$2y$10$q2Ze/R4sf5RQcZZ.eoywsuCKVk35Mcf62aLlpQ.EfS9eqZPikXmS2'),
('Fernanda Alves', 'Lavadora', 'OPERACIONAL', 'fernanda.alves@example.com', '$2y$10$q2Ze/R4sf5RQcZZ.eoywsuCKVk35Mcf62aLlpQ.EfS9eqZPikXmS2');


INSERT INTO veiculo (id_cliente, placa, marca, modelo, cor)
SELECT id_cliente, 'ABC1D23', 'Volkswagen', 'Gol', 'Prata' FROM cliente WHERE email = 'joao.silva@example.com';

INSERT INTO veiculo (id_cliente, placa, marca, modelo, cor)
SELECT id_cliente, 'DEF4G56', 'Toyota', 'Corolla', 'Preto' FROM cliente WHERE email = 'joao.silva@example.com';

INSERT INTO veiculo (id_cliente, placa, marca, modelo, cor)
SELECT id_cliente, 'GHI7J89', 'Honda', 'Civic', 'Branco' FROM cliente WHERE email = 'maria.oliveira@example.com';

INSERT INTO veiculo (id_cliente, placa, marca, modelo, cor)
SELECT id_cliente, 'KLM1N23', 'Chevrolet', 'Onix', 'Vermelho' FROM cliente WHERE email = 'carlos.santos@example.com';


-- Agendamentos demonstrativos. Cada um terá também atendimento e pagamento.
-- Registramos a origem, sem inventar colaborador para reservas dos clientes.


INSERT INTO agendamento (id_veiculo, data, horario, status, criado_por_tipo, id_colaborador_criador)
SELECT id_veiculo, DATE_SUB(CURDATE(), INTERVAL 2 DAY), '09:00:00', 'CONCLUIDO', 'ADMINISTRADOR', (SELECT id_colaborador FROM colaborador WHERE email = 'kelsey@example.com')
FROM veiculo WHERE placa = 'ABC1D23';

INSERT INTO agendamento (id_veiculo, data, horario, status, criado_por_tipo, id_colaborador_criador)
SELECT id_veiculo, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '10:00:00', 'CONCLUIDO', 'ATENDENTE', (SELECT id_colaborador FROM colaborador WHERE email = 'bruno.lima@example.com')
FROM veiculo WHERE placa = 'GHI7J89';

INSERT INTO agendamento (id_veiculo, data, horario, status, criado_por_tipo, id_colaborador_criador)
SELECT id_veiculo, DATE_SUB(CURDATE(), INTERVAL 3 DAY), '11:00:00', 'CANCELADO', 'CLIENTE', NULL
FROM veiculo WHERE placa = 'KLM1N23';

INSERT INTO agendamento (id_veiculo, data, horario, status, criado_por_tipo, id_colaborador_criador)
SELECT id_veiculo, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '09:30:00', 'AGENDADO', 'CLIENTE', NULL
FROM veiculo WHERE placa = 'DEF4G56';

INSERT INTO agendamento (id_veiculo, data, horario, status, criado_por_tipo, id_colaborador_criador)
SELECT id_veiculo, DATE_ADD(CURDATE(), INTERVAL 3 DAY), '14:00:00', 'AGENDADO', 'ATENDENTE', (SELECT id_colaborador FROM colaborador WHERE email = 'bruno.lima@example.com')
FROM veiculo WHERE placa = 'GHI7J89';


-- Serviços contratados (os valores batem com os pagamentos).

INSERT INTO agendamento_servico (id_agendamento, id_servico, valor_praticado)
SELECT (SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'ABC1D23' AND a.data = DATE_SUB(CURDATE(), INTERVAL 2 DAY) AND a.horario = '09:00:00'), id_servico, preco FROM servico WHERE nome = 'Lavagem Simples';

INSERT INTO agendamento_servico (id_agendamento, id_servico, valor_praticado)
SELECT (SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'GHI7J89' AND a.data = DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND a.horario = '10:00:00'), id_servico, preco FROM servico WHERE nome = 'Lavagem Completa';

INSERT INTO agendamento_servico (id_agendamento, id_servico, valor_praticado)
SELECT (SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'GHI7J89' AND a.data = DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND a.horario = '10:00:00'), id_servico, preco FROM servico WHERE nome = 'Enceramento';

INSERT INTO agendamento_servico (id_agendamento, id_servico, valor_praticado)
SELECT (SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'KLM1N23' AND a.data = DATE_SUB(CURDATE(), INTERVAL 3 DAY) AND a.horario = '11:00:00'), id_servico, preco FROM servico WHERE nome = 'Lavagem Simples';

INSERT INTO agendamento_servico (id_agendamento, id_servico, valor_praticado)
SELECT (SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'DEF4G56' AND a.data = DATE_ADD(CURDATE(), INTERVAL 2 DAY) AND a.horario = '09:30:00'), id_servico, preco FROM servico WHERE nome = 'Lavagem Completa';

INSERT INTO agendamento_servico (id_agendamento, id_servico, valor_praticado)
SELECT (SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'GHI7J89' AND a.data = DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND a.horario = '14:00:00'), id_servico, preco FROM servico WHERE nome = 'Higienização Interna';


-- Atendimento criado para TODOS os agendamentos, inclusive pendentes e cancelados.

INSERT INTO atendimento (id_agendamento, status, data_inicio, data_fim, id_colaborador_responsavel)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'ABC1D23' AND a.data = DATE_SUB(CURDATE(), INTERVAL 2 DAY) AND a.horario = '09:00:00'), 'FINALIZADO', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY), '09:15:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY), '10:00:00'), (SELECT id_colaborador FROM colaborador WHERE email = 'kelsey@example.com'));

INSERT INTO atendimento (id_agendamento, status, data_inicio, data_fim, id_colaborador_responsavel)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'GHI7J89' AND a.data = DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND a.horario = '10:00:00'), 'FINALIZADO', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '10:10:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '11:30:00'), (SELECT id_colaborador FROM colaborador WHERE email = 'bruno.lima@example.com'));

INSERT INTO atendimento (id_agendamento, status, data_inicio, data_fim, id_colaborador_responsavel)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'KLM1N23' AND a.data = DATE_SUB(CURDATE(), INTERVAL 3 DAY) AND a.horario = '11:00:00'), 'AGUARDANDO', NULL, NULL, NULL);

INSERT INTO atendimento (id_agendamento, status, data_inicio, data_fim, id_colaborador_responsavel)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'DEF4G56' AND a.data = DATE_ADD(CURDATE(), INTERVAL 2 DAY) AND a.horario = '09:30:00'), 'AGUARDANDO', NULL, NULL, NULL);

INSERT INTO atendimento (id_agendamento, status, data_inicio, data_fim, id_colaborador_responsavel)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'GHI7J89' AND a.data = DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND a.horario = '14:00:00'), 'AGUARDANDO', NULL, NULL, NULL);


-- Lavadores apenas nos atendimentos realizados.

INSERT INTO colaborador_atendimento (id_colaborador, id_atendimento)
SELECT c.id_colaborador, at.id_atendimento FROM colaborador c JOIN atendimento at
 ON at.id_agendamento = (SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'ABC1D23' AND a.data = DATE_SUB(CURDATE(), INTERVAL 2 DAY) AND a.horario = '09:00:00')
WHERE c.email = 'diego.martins@example.com';

INSERT INTO colaborador_atendimento (id_colaborador, id_atendimento)
SELECT c.id_colaborador, at.id_atendimento FROM colaborador c JOIN atendimento at
 ON at.id_agendamento = (SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'GHI7J89' AND a.data = DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND a.horario = '10:00:00')
WHERE c.email = 'diego.martins@example.com';

INSERT INTO colaborador_atendimento (id_colaborador, id_atendimento)
SELECT c.id_colaborador, at.id_atendimento FROM colaborador c JOIN atendimento at
 ON at.id_agendamento = (SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'GHI7J89' AND a.data = DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND a.horario = '10:00:00')
WHERE c.email = 'fernanda.alves@example.com';


-- Pagamentos coerentes com as somas de agendamento_servico.

INSERT INTO pagamento (id_agendamento, data_pagamento, valor, forma_pagamento, status_pagamento)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'ABC1D23' AND a.data = DATE_SUB(CURDATE(), INTERVAL 2 DAY) AND a.horario = '09:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY), '08:55:00'), 35.00, 'PIX', 'PAGO');

INSERT INTO pagamento (id_agendamento, data_pagamento, valor, forma_pagamento, status_pagamento)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'GHI7J89' AND a.data = DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND a.horario = '10:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:55:00'), 100.00, 'DEBITO', 'PAGO');

INSERT INTO pagamento (id_agendamento, data_pagamento, valor, forma_pagamento, status_pagamento)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'KLM1N23' AND a.data = DATE_SUB(CURDATE(), INTERVAL 3 DAY) AND a.horario = '11:00:00'), NULL, 35.00, NULL, 'CANCELADO');

INSERT INTO pagamento (id_agendamento, data_pagamento, valor, forma_pagamento, status_pagamento)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'DEF4G56' AND a.data = DATE_ADD(CURDATE(), INTERVAL 2 DAY) AND a.horario = '09:30:00'), NULL, 60.00, NULL, 'PENDENTE');

INSERT INTO pagamento (id_agendamento, data_pagamento, valor, forma_pagamento, status_pagamento)
VALUES ((SELECT a.id_agendamento FROM agendamento a JOIN veiculo v ON v.id_veiculo = a.id_veiculo WHERE v.placa = 'GHI7J89' AND a.data = DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND a.horario = '14:00:00'), NULL, 120.00, NULL, 'PENDENTE');


COMMIT;

-- Conferências não destrutivas (execute após a importação):
-- SELECT 'cliente' AS tabela, COUNT(*) AS total FROM cliente
-- UNION ALL SELECT 'veiculo', COUNT(*) FROM veiculo
-- UNION ALL SELECT 'servico', COUNT(*) FROM servico
-- UNION ALL SELECT 'colaborador', COUNT(*) FROM colaborador
-- UNION ALL SELECT 'agendamento', COUNT(*) FROM agendamento
-- UNION ALL SELECT 'agendamento_servico', COUNT(*) FROM agendamento_servico
-- UNION ALL SELECT 'atendimento', COUNT(*) FROM atendimento
-- UNION ALL SELECT 'colaborador_atendimento', COUNT(*) FROM colaborador_atendimento
-- UNION ALL SELECT 'pagamento', COUNT(*) FROM pagamento;
