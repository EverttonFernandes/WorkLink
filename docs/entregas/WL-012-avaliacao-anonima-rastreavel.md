# Entrega WL-012 — Avaliação anônima com rastreabilidade interna

## Identificador

- História: `WL-012`
- Data: `2026-05-09`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que o cliente avalie um profissional somente após contato registrado e serviço realizado, com opção de
anonimato público e autoria interna preservada para auditoria.

## Personas afetadas

- Usuário cliente: registra nota obrigatória e comentário opcional sem precisar expor publicamente sua identidade.
- Profissional: passa a receber avaliações elegíveis a partir de serviços realizados.
- Produto/operação: mantém rastreabilidade interna para auditoria, abuso e moderação futura.

## Requisitos atendidos

- Avaliação permitida somente para contato existente.
- Avaliação permitida somente quando o pós-contato indica serviço realizado.
- Nota em estrelas obrigatória.
- Comentário opcional.
- Anonimato público sem exposição do identificador interno do autor.
- Autoria interna persistida para rastreabilidade.
- RN09/RN10/RN11/RN12: minimização, privacidade, auditoria e rastreabilidade.

## O que foi implementado

- Domínio `ProfessionalReview` com nota obrigatória, comentário opcional e projeção pública segura.
- Caso de uso `RegisterProfessionalReviewUseCase` validando cliente autenticado, contato existente, ownership e
  pós-contato com serviço realizado.
- Endpoint `POST /api/v1/professional-reviews`.
- Persistência em `worklink.professional_reviews` via migração `V012`.
- Auditoria sensível para `REGISTER_ANONYMOUS_REVIEW`.
- Tela mobile `Avaliar profissional` com estrelas, comentário opcional e opção de ocultar nome publicamente.
- Navegação mobile a partir do pós-contato, exibida apenas quando o serviço foi marcado como realizado.

## O que não foi implementado

- Exibição pública agregada das avaliações, que fica para `WL-013`.
- Moderação avançada.
- Ranking algorítmico.
- Adapter HTTP real do app mobile para o endpoint, que fica para a integração mobile/API futura.

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela mobile de pós-contato estruturado.
- Tela mobile de avaliação profissional.
- Endpoint `POST /api/v1/professional-reviews`.
- Migração `V012__create_professional_reviews.sql`.
- Protótipos:
  - `docs/prototipos-de-tela/tela-avaliacao-profissional.png`
  - `docs/prototipos-de-tela/tela-avaliacao-concluida.png`

## Estratégia de testes

- Backend domínio: criação válida, nota obrigatória e projeção anônima pública.
- Backend aplicação: contato inexistente, cliente dono, serviço realizado, serviço não realizado e autoria pública.
- Backend API: contrato HTTP, autenticação, payload de resposta e auditoria.
- Backend infraestrutura: persistência JDBC da avaliação e leitura do pós-contato elegível.
- Mobile unitário: estado/controller da avaliação, nota obrigatória, comentário normalizado e anonimato.
- Mobile tela: formulário, erro de nota ausente, sucesso e navegação a partir do pós-contato realizado.

## Evidências de validação

- `make backend-unit-test`: PASS, 203 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v012`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 97,83%.
- `make mobile-screen-test`: PASS, 43 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
- `git diff --check`: PASS.
- Security diff scan: PASS.

## Riscos ou limitações remanescentes

- O app mobile ainda usa callback local para submissão da avaliação; a chamada HTTP real será conectada quando a camada
  de comunicação mobile/API for introduzida.
- Avaliações são registradas, mas a exibição pública no perfil fica para `WL-013`.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/domain/review`
- `worklink-api/src/main/java/br/com/worklink/application/review`
- `worklink-api/src/main/java/br/com/worklink/api/review`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/review`
- `worklink-api/src/main/resources/db/migration/V012__create_professional_reviews.sql`
- `worklink-mobile/lib/features/professional_review`
- `worklink-mobile/lib/features/post_contact_feedback`
- `worklink-mobile/lib/main.dart`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma nova capacidade funcional de avaliação com privacidade e rastreabilidade,
mantendo compatibilidade com as funcionalidades existentes.
