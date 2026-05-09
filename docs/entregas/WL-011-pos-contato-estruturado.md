# Entrega WL-011 — Pós-contato estruturado

## Identificador

- História: `WL-011`
- Data: `2026-05-09`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que o cliente registre o que aconteceu após iniciar contato com um profissional, criando sinais estruturados
para responsividade, realização de serviço e futuras avaliações do WorkLink.

## Personas afetadas

- Usuário cliente: informa se conseguiu falar, como foi a resposta e se o serviço foi realizado.
- Profissional: passa a ter interações pós-contato rastreáveis para sinais futuros.
- Produto/operação: ganha base objetiva para reputação, qualidade e auditoria.

## Requisitos atendidos

- Feedback pós-contato apenas para intenção de contato existente.
- Registro obrigatório do resultado da conversa.
- Registro obrigatório da responsividade percebida.
- Registro obrigatório do resultado de execução do serviço.
- Persistência das respostas para indicadores futuros.
- RN02/RN03/RN04/RN05/RN11: autenticação, autorização, auditoria, rastreabilidade e privacidade.

## O que foi implementado

- Domínio `PostContactFeedback` com respostas estruturadas e validações obrigatórias.
- Caso de uso `RegisterPostContactFeedbackUseCase` validando cliente autenticado, contato existente e ownership.
- Endpoint `POST /api/v1/post-contact-feedbacks`.
- Persistência em `worklink.post_contact_feedbacks` via migração `V011`.
- Auditoria sensível para `REGISTER_POST_CONTACT_FEEDBACK`.
- Tela mobile `Pós-contato` com escolhas estruturadas.
- Navegação mobile a partir da tela `Falar com o profissional` após WhatsApp aberto.

## O que não foi implementado

- Ranking algorítmico.
- Mediação de conflitos.
- Texto livre de avaliação.
- Adapter HTTP real do app mobile para o endpoint, que fica para a integração mobile/API futura.

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela mobile de contato com o profissional.
- Tela mobile de pós-contato estruturado.
- Endpoint `POST /api/v1/post-contact-feedbacks`.
- Migração `V011__create_post_contact_feedbacks.sql`.
- Protótipos:
  - `docs/prototipos-de-tela/tela-falar-com-o-profissional.png`
  - `docs/prototipos-de-tela/tela-avaliacao-profissional.png`

## Estratégia de testes

- Backend domínio: respostas obrigatórias e criação válida.
- Backend aplicação: intenção existente, intenção inexistente, ownership e perfil autenticado.
- Backend API: contrato HTTP, autenticação, payload de resposta e auditoria.
- Backend infraestrutura: persistência JDBC do feedback.
- Mobile unitário: estado/controller do pós-contato, bloqueio de respostas incompletas e submissão estruturada.
- Mobile tela: perguntas obrigatórias, erro de formulário, sucesso e navegação a partir do contato WhatsApp.

## Evidências de validação

- `make backend-unit-test`: PASS, 192 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v011`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 97,91%.
- `make mobile-screen-test`: PASS, 37 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
- `git diff --check`: PASS.
- Security diff scan: PASS.

## Riscos ou limitações remanescentes

- O app mobile ainda usa callback local para submissão do pós-contato; a chamada HTTP real será conectada quando a
  camada de comunicação mobile/API for introduzida.
- A entrega armazena sinais brutos. Cálculo de métricas e ranking fica para histórias posteriores.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/domain/contact`
- `worklink-api/src/main/java/br/com/worklink/application/contact`
- `worklink-api/src/main/java/br/com/worklink/api/contact`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/contact`
- `worklink-mobile/lib/features/post_contact_feedback`
- `worklink-mobile/lib/features/professional_contact`
- `worklink-mobile/lib/main.dart`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma nova capacidade funcional de pós-contato estruturado com persistência e
rastreabilidade, mantendo compatibilidade com as funcionalidades existentes.
