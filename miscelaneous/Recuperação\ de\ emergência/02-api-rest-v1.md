# API REST v1 — Implementação Recuperada

Commits: `65ebce0`, `89f866e`, `06a5c85`, `3f1569b`, `1b68b57` (mai-ago 2026)

## Estrutura

### Localização

```
src/main/java/com/splash/web/api/
├── v1/
│   ├── AgendamentoApiServlet.java      @WebServlet("/api/v1/agendamentos/*")
│   ├── ServicoApiServlet.java          @WebServlet("/api/v1/servicos/*")
│   └── VeiculoApiServlet.java          @WebServlet("/api/v1/veiculos/*")
├── dto/
│   ├── NovoAgendamentoRequest.java
│   ├── ServicoResponse.java
│   └── ... (DTOs de entrada/saída)
└── Json.java                           Utilitário de serialização
```

### Mapeamento de Rotas

| Método | Rota | Servlet | Descrição | Implementado |
|--------|------|---------|-----------|-------------|
| GET | `/api/v1/servicos` | ServicoApiServlet | Listar todos serviços | ✓ |
| POST | `/api/v1/agendamentos` | AgendamentoApiServlet | Novo agendamento | ✓ |
| GET | `/api/v1/agendamentos` | AgendamentoApiServlet | Listar agendamentos | ✓ |
| GET | `/api/v1/veiculos/{id_cliente}` | VeiculoApiServlet | Veículos do cliente | ✓ |
| POST | `/api/v1/veiculos` | VeiculoApiServlet | Novo veículo | ✓ |
| DELETE | `/api/v1/veiculos/{id_veiculo}` | VeiculoApiServlet | Remover veículo | ✓ (parcial) |

### DTOs Implementados

**Entrada:**

- `NovoAgendamentoRequest` — `{ idVeiculo, data, horario, idServicos[], idColaboradores[] }`
- Implícito em `VeiculoApiServlet.post()` — `{ placa, modelo, ano, cliente_id }`

**Saída:**

- `ServicoResponse` — `{ id, nome, descricao, preco, duracao }`
- JSON genérico via `Json.toJson()` para listas e objetos

### Serialização

Classe `Json.java` fornece:

```java
Json.toJson(Object)          // Qualquer objeto → JSON string
Json.fromJson(String, Class) // JSON string → Object (jackson)
```

Dependências:

- `com.fasterxml.jackson.core:jackson-databind` (pom.xml)
- Configurado para ignorar campos desconhecidos no desserialize

## Funcionalidades

### ServicoApiServlet (`/api/v1/servicos`)

**GET** — Retorna array JSON de todos os serviços cadastrados

```json
[
  {
    "id": 1,
    "nome": "Lavagem Básica",
    "descricao": "...",
    "preco": 50.00,
    "duracao": 30
  }
]
```

Status: `200 OK` | Erro DB → `500 Internal Server Error`

### VeiculoApiServlet (`/api/v1/veiculos`)

**POST** — Novo veículo (requer autenticação cliente em sessão)

```json
{
  "placa": "ABC-1234",
  "modelo": "Corsa",
  "ano": 2020
}
```

Resposta sucesso: `201 Created` + JSON `{ id, placa, modelo, ano }`
Erro: `400 Bad Request` | `409 Conflict` (placa duplicada) | `500` (DB)

**GET** `/api/v1/veiculos/{id_cliente}` — Lista veículos do cliente

```json
[
  { "id": 1, "placa": "ABC-1234", "modelo": "Corsa", "ano": 2020 },
  ...
]
```

Status: `200 OK` | `404 Not Found` (cliente inexistente)

**DELETE** `/api/v1/veiculos/{id_veiculo}` — Remove veículo (parcial em v1)

Status: `204 No Content` | `404 Not Found`

### AgendamentoApiServlet (`/api/v1/agendamentos`)

**POST** — Novo agendamento (requer sessão cliente)

```json
{
  "idVeiculo": 5,
  "data": "2026-11-20",
  "horario": "14:30",
  "idServicos": [1, 3],
  "idColaboradores": []
}
```

Resposta sucesso: `201 Created` + JSON agendamento criado
Validações: data/horario futuros, veículo pertence ao cliente, serviços existem
Erro: `400 Bad Request` | `409 Conflict` (agendamento duplicado) | `500` (DB)

**GET** `/api/v1/agendamentos` — Lista agendamentos do cliente em sessão

```json
[
  {
    "id": 1,
    "data": "2026-11-20",
    "horario": "14:30",
    "placa": "ABC-1234",
    "servicos": ["Lavagem Básica", "Enceramento"],
    "status": "CONFIRMADO"
  }
]
```

Status: `200 OK`

## Autenticação e Contexto

- Usa `WebSupport.clienteId` (sessão) — redirecionada para `/login` se ausente
- Admin/colaborador: rotas not allowed → `403 Forbidden`
- Sem token Bearer ou API key — apenas sessão HTTP

## Documentação OpenAPI

Arquivo: `miscelaneous/openapi.yml`

Atualizado com v1 (últimas alterações em `repositorios-removidos-e-cadastro-unico.md` — commit `bec8212` de 2026-10-18).

Pode estar desatualizado se houve mudanças após essa data não refletidas no YAML.

## Status Atual

| Aspecto | Status | Notas |
|---------|--------|-------|
| Compilação | ✓ | Sem erros |
| Testes unit | ✓ | DAOCliente testado |
| Integração | Parcial | Servlets presentes, mas sem testes de integração |
| Documentação | ⚠️ | openapi.yml pode estar desatualizado |
| Consumo (app-mobile) | ✗ | app-mobile ainda usa dados em-memória (`lib/core/data/repositorio.dart`) |

## Próximos Passos

1. Testar endpoints localmente (curl, Postman, app-mobile)
2. Validar JSON parsing com Jackson para casos edge
3. Integração com app-mobile Flutter — trocar repositório em-memória por chamadas REST
4. Adicionar testes de integração para as servlets (API test)
5. Considerar versionamento: v1 lock, v2 para mudanças breaking
