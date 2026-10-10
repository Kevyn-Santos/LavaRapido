# Flash Splash

## Atualização: nova tela inicial e paleta do site

Este pacote traz a tela inicial nova (layout do site, ilustração original) e a
paleta do site aplicada no tema claro e escuro do app inteiro.

### Como aplicar no seu projeto

1. Extraia o zip e copie o conteúdo **por cima da raiz do seu projeto**
   (`flash_splash`), escolhendo **Substituir** quando o Windows perguntar.
   Isso atualiza:
   - `lib/` (tema, tela inicial e ajustes de cor nas outras telas)
   - `assets/hero_lavagem.png` (a ilustração nova)
   - `pubspec.yaml` (agora declara `assets/hero_lavagem.png`)
   - `design/hero_lavagem.svg` (arquivo vetorial, para o time do site)
2. No Android Studio, clique em **Pub get**.
3. Rode o app (se já estiver rodando, pare e rode de novo, não basta hot reload).

A imagem antiga `assets/fast.splash.png` não é mais usada e pode ser apagada.

### Dados para testar

- CPF válido de exemplo: `529.982.247-25`
- Senha: `1234`

Para aceitar qualquer CPF com 11 dígitos, mude `exigirDigitosVerificadores`
para `false` em `lib/core/utils/cpf.dart`.

## Paleta (lib/core/theme/app_theme.dart)

| Uso | Cor |
| --- | --- |
| Fundo (início do gradiente) | `#0A2E3B` |
| Fundo (fim do gradiente) | `#123F52` |
| Ciano (bolhas, seleção, logo) | `#4FC7DB` |
| Ciano escuro (texto sobre fundo claro) | `#0A5A68` |
| Coral (ação principal) | `#FF7A5C` |
| Coral escuro | `#C64A32` |
| Superfície / bordas / texto | `#F5F8F7` / `#DCE3E1` / `#14262C` |
| Texto secundário / cards | `#5E6F76` / `#FFFFFF` |

As cores de status (pendente, em andamento, concluído) já estão no
`AppTheme`, prontas para quando os agendamentos tiverem status.

## Estrutura

```
assets/        hero_lavagem.png (ilustração da tela inicial)
design/        hero_lavagem.svg (fonte vetorial da ilustração)
lib/
  main.dart, app.dart
  core/
    constants/   caminho da ilustração
    data/        repositorio.dart (serviços, veículos e agendamentos em memória)
    models/      servico, veiculo, agendamento
    session/     CPF do cliente logado
    theme/       paleta, temas claro/escuro e controle do modo escuro
    utils/       CPF (validação e máscara) e formatação de data/hora
  features/
    auth/            tela_inicial, login_cliente
    home/            conta_cliente (abas), inicio_cliente, servico_card
    agendamentos/    agendamentos, novo_agendamento
    perfil/          perfil_cliente, meus_veiculos, notificacoes
    pagamento/       pagamento
    configuracoes/   configuracoes
```

Os dados (veículos, agendamentos) ficam só em memória e somem ao fechar o app.
