# WLT-033 — Canal de confirmação de código na autenticação mobile

## Objetivo

Corrigir o débito `DTM-004`, definindo e refletindo na UI o canal real de envio do código de verificação.

## Valor técnico e de produto

A tela de autenticação não pode prometer um código sem explicar de forma honesta se ele chega por SMS, WhatsApp, email ou outro canal aprovado.

## Débito relacionado

- `DTM-004 — Canal de confirmação de código ambíguo`

## Escopo incluído

- Registrar decisão de produto para o canal de OTP/verificação da V1.
- Ajustar copy das telas de login e verificação.
- Garantir coerência entre backend, configuração, mocks de homologação e UI.
- Validar que navegação sem autenticação inicial continua preservada.
- Acionar Segurança e Privacidade por envolver autenticação e dados pessoais.

## Decisão oficial da V1

- O telefone celular continua sendo o identificador primário da autenticação do cliente.
- A V1 permite escolher o canal de recebimento do código entre `SMS`, `WhatsApp` e `email`.
- Quando `email` for escolhido, a interface deve solicitar o endereço de email antes de pedir o código.
- Homologação pode simular o envio, desde que a interface e a documentação sejam explícitas sobre essa condição.
- Produção deve integrar um provedor real antes de declarar envio real por qualquer canal.
- A resposta da API deve permanecer genérica e não deve vazar se o telefone/email existe, nem o código OTP.

## Fora do escopo

- Contratar provedor externo definitivo se a decisão for manter mock honesto de homologação.
- Implementar chat interno ou fluxo avançado de conta.

## Critérios de aceite

- O canal de verificação está decidido e documentado.
- A decisão explicita se a V1 suportará apenas um canal ou combinação de `SMS`, `WhatsApp` e `email`.
- A UI informa o canal correto, sem ambiguidade.
- O fluxo de homologação deixa claro se o envio é real ou simulado.
- QA, Segurança e Final Reviewer aprovam o fluxo.

## Entrega versionável

- Tipo sugerido: `PATCH`
- Motivo: corrige copy/contrato de autenticação e evita promessa falsa ao usuário.
