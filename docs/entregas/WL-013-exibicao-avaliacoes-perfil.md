# Entrega WL-013 — Exibição de avaliações no perfil

## Identificador

- História: `WL-013`
- Data: `2026-05-09`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Exibir avaliações no perfil público do profissional para apoiar a decisão do cliente antes do contato, preservando o
anonimato público quando solicitado e mantendo rastreabilidade interna para análise de abuso.

## Personas afetadas

- Usuário cliente: consulta nota média, quantidade de avaliações e comentários públicos.
- Profissional: consegue solicitar análise de uma avaliação considerada indevida.
- Produto/operação: recebe pedidos rastreáveis de análise para moderação futura.

## Requisitos atendidos

- Perfil exibe avaliações existentes.
- Perfil exibe nota média e quantidade quando houver dados.
- Avaliações anônimas aparecem sem identidade pública.
- Comentários continuam opcionais.
- Profissional avaliado pode solicitar análise de avaliação indevida.
- RN09/RN10/RN11/RN12: minimização, privacidade, auditoria e rastreabilidade.

## O que foi implementado

- Projeção pública `ProfessionalReviewProfileResponse` com resumo e lista de comentários seguros.
- Caso de uso `ListProfessionalReviewProfileUseCase` calculando média simples e quantidade de avaliações.
- Caso de uso `RequestProfessionalReviewAnalysisUseCase` validando profissional autenticado e ownership da avaliação.
- Endpoint `GET /api/v1/professional-reviews/professionals/{professionalIdentifier}`.
- Endpoint `POST /api/v1/professional-reviews/{professionalReviewIdentifier}/analysis-requests`.
- Persistência de solicitações em `worklink.professional_review_analysis_requests` via migração `V013`.
- Auditoria sensível para `REQUEST_REVIEW_ANALYSIS`.
- Tela mobile de perfil com resumo de avaliações, comentários públicos e ação `Solicitar análise`.

## O que não foi implementado

- Moderação completa da avaliação.
- Ranking algorítmico de reputação.
- Adapter HTTP real do app mobile para consultar avaliações e solicitar análise.

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela mobile de perfil público do profissional.
- Endpoint `GET /api/v1/professional-reviews/professionals/{professionalIdentifier}`.
- Endpoint `POST /api/v1/professional-reviews/{professionalReviewIdentifier}/analysis-requests`.
- Migração `V013__create_professional_review_analysis_requests.sql`.
- Protótipos:
  - `docs/prototipos-de-tela/tela-perfil-do-profissional.png`
  - `docs/prototipos-de-tela/tela-avaliacao-concluida.png`

## Estratégia de testes

- Backend domínio: criação de pedido de análise com campos obrigatórios e motivo opcional.
- Backend aplicação: listagem com média, estado sem avaliações, autorização do profissional e bloqueio de terceiro.
- Backend API: contratos HTTP de listagem e solicitação de análise com auditoria.
- Backend infraestrutura: persistência da solicitação e mapeamento JDBC de avaliações públicas.
- Mobile unitário: formatação de média, quantidade e comentário opcional.
- Mobile tela: exibição do resumo, comentários públicos e emissão do pedido de análise.

## Evidências de validação

- `make backend-unit-test`: PASS, 215 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v013`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 97,60%.
- `make mobile-screen-test`: PASS, 44 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
- `git diff --check`: PASS.
- Security diff scan: PASS.

## Riscos ou limitações remanescentes

- O app mobile ainda recebe os dados de avaliação por callback/configuração local; a integração HTTP real será conectada
  quando a camada mobile/API for introduzida.
- Solicitação de análise é registrada, mas a fila administrativa de moderação completa fica para história futura.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/domain/review`
- `worklink-api/src/main/java/br/com/worklink/application/review`
- `worklink-api/src/main/java/br/com/worklink/api/review`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/review`
- `worklink-api/src/main/resources/db/migration/V013__create_professional_review_analysis_requests.sql`
- `worklink-mobile/lib/features/professional_profile`
- `worklink-mobile/lib/main.dart`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona nova capacidade funcional de consulta pública de avaliações e solicitação de análise,
mantendo compatibilidade com as funcionalidades existentes.
