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

- MySQL 8 ou superior;
- MySQL Workbench ou outro cliente compatível com MySQL.

---

## Como criar o banco

### 1. Executar o `schema.sql`

Abra o arquivo:

```text
database/schema.sql