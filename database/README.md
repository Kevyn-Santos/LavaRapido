# Banco de Dados - Lava-Rápido

Este diretório contém os arquivos responsáveis pela criação e população inicial do banco de dados do projeto.

## Arquivos

### `schema.sql`

Responsável por criar a estrutura do banco de dados.

Ele contém:

- criação do banco `lava_rapido`;
- criação das tabelas;
- chaves primárias;
- chaves estrangeiras;
- restrições `UNIQUE`;
- restrições `CHECK`;
- campos `ENUM`;
- índices;
- regras `ON DELETE` e `ON UPDATE`.

### `seed.sql`

Responsável por inserir dados fictícios de desenvolvimento e testes.

O arquivo contém registros de exemplo para:

- clientes;
- veículos;
- serviços;
- agendamentos;
- serviços contratados;
- colaboradores;
- atendimentos;
- colaboradores vinculados aos atendimentos;
- pagamentos.

> **Importante:** o `seed.sql` deve ser executado em um banco recém-criado e vazio, logo após o `schema.sql`.

Os dados de relacionamento do `seed.sql` assumem que os campos `AUTO_INCREMENT` iniciam em `1`.

---

## Requisitos

- MySQL 8.0.16 ou superior;
- MySQL Workbench ou outro cliente compatível com MySQL.

---

## Como criar o banco

### 1. Executar o `schema.sql`

Abra o arquivo:

```text
database/schema.sql
```

Execute todo o conteúdo do arquivo.

O `schema.sql` será responsável pela criação do banco de dados `lava_rapido`, das tabelas e de todos os relacionamentos necessários.

### 2. Executar o `seed.sql`

Após a criação do banco, abra o arquivo:

```text
database/seed.sql
```

Execute todo o conteúdo do arquivo.

Esse arquivo adiciona dados fictícios utilizados para desenvolvimento e testes.

---

## Ordem de execução

Os arquivos devem ser executados nesta ordem:

```text
schema.sql
    ↓
seed.sql
```

1. O `schema.sql` cria toda a estrutura do banco de dados.
2. O `seed.sql` adiciona os dados iniciais de desenvolvimento e testes.

---

## Observações

- O `schema.sql` deve ser executado antes do `seed.sql`.
- O `seed.sql` foi criado para ser executado em um banco recém-criado e vazio.
- Os IDs utilizados nos relacionamentos assumem que os campos `AUTO_INCREMENT` começam em `1`.
- Os pagamentos estão relacionados diretamente aos agendamentos.
- Dessa forma, um pagamento pode ser registrado antes da criação ou do início de um atendimento.
- A tabela `atendimento` representa a execução do serviço após o agendamento.
- A tabela `pagamento` armazena as informações referentes ao pagamento do agendamento.
- As formas de pagamento disponíveis no banco são `DINHEIRO`, `PIX`, `CREDITO` e `DEBITO`.
- Os dados presentes no `seed.sql` são fictícios e destinados apenas ao desenvolvimento e aos testes do sistema.