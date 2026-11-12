-- Migracao do schema_atual.sql para o novo schema.sql
-- Banco: lava_rapido
-- MySQL 8.0+
-- Faça backup antes de executar.

USE lava_rapido;

-- 1. Novas colunas: registros existentes recebem ativo = TRUE e excluido_em = NULL.
ALTER TABLE cliente
    ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN excluido_em DATETIME NULL;

ALTER TABLE veiculo
    ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN excluido_em DATETIME NULL;

ALTER TABLE servico
    ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN excluido_em DATETIME NULL;

ALTER TABLE colaborador
    ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN excluido_em DATETIME NULL;

-- 2. Atualiza as regras ON DELETE para corresponder ao novo schema.
-- Atenção: CASCADE permite que exclusões futuras no registro pai
-- excluam automaticamente os registros dependentes.

ALTER TABLE veiculo
    DROP FOREIGN KEY fk_veiculo_cliente,
    ADD CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

ALTER TABLE agendamento
    DROP FOREIGN KEY fk_agendamento_veiculo,
    ADD CONSTRAINT fk_agendamento_veiculo
        FOREIGN KEY (id_veiculo)
        REFERENCES veiculo(id_veiculo)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

ALTER TABLE atendimento
    DROP FOREIGN KEY fk_atendimento_agendamento,
    ADD CONSTRAINT fk_atendimento_agendamento
        FOREIGN KEY (id_agendamento)
        REFERENCES agendamento(id_agendamento)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

ALTER TABLE pagamento
    DROP FOREIGN KEY fk_pagamento_agendamento,
    ADD CONSTRAINT fk_pagamento_agendamento
        FOREIGN KEY (id_agendamento)
        REFERENCES agendamento(id_agendamento)
        ON UPDATE CASCADE
        ON DELETE CASCADE;

-- 3. Conferência manual após a migração:
-- SHOW CREATE TABLE cliente;
-- SHOW CREATE TABLE veiculo;
-- SHOW CREATE TABLE servico;
-- SHOW CREATE TABLE colaborador;
-- SHOW CREATE TABLE agendamento;
-- SHOW CREATE TABLE atendimento;
-- SHOW CREATE TABLE pagamento;
