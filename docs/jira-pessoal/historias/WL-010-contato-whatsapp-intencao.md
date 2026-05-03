# WL-010 — Contato via WhatsApp e intenção de contato

## Objetivo

Permitir que usuário autenticado chame o profissional via WhatsApp e registrar a intenção de contato.

## Valor entregue

A plataforma facilita o contato e passa a coletar o dado que habilita pós-contato e reputação futura.

## Personas

- Usuário cliente
- Profissional

## Requisitos relacionados

- RF31, RF32, RF33, RF34, RF35
- RN02, RN03, RN04, RN05

## Escopo incluído

- Ação de chamar no WhatsApp.
- Registro de intenção de contato.
- Tela/aviso de redirecionamento.
- Informação de que negociação ocorre fora do app.
- Informação de que o WorkLink não garante execução do serviço.

## Fora do escopo

- Chat interno.
- Pagamento.
- Contrato.
- Garantia do serviço.

## Critérios de aceite

- Usuário não autenticado não deve iniciar contato.
- Usuário autenticado deve conseguir iniciar contato via WhatsApp.
- Sistema deve registrar intenção de contato antes do redirecionamento.
- Tela de contato deve informar que a negociação ocorre fora do app.
- Tela de contato deve informar que o WorkLink não garante execução do serviço.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-falar-com-o-profissional.png`

### Requisitos não funcionais por tela

- intenção de contato deve ser registrada antes do redirecionamento externo;
- tela deve deixar claro que negociação ocorre fora do app e que não há garantia de execução;
- deep link/WhatsApp deve ficar isolado em adapter, sem regra de negócio acoplada à chamada externa;
- testes mobile devem cobrir usuário autenticado, usuário não autenticado, registro da intenção e erro no redirecionamento.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona contato real e base para responsividade.
