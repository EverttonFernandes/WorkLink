# Entrega WL-014 — Denúncia de profissional

## Identificador

- História: `WL-014`
- Data: `2026-05-09`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que o usuário denuncie um profissional por fraude, assédio, ameaça, perfil falso, serviço não realizado ou outro
motivo, registrando o caso para análise posterior sem expor dados sensíveis publicamente.

## Personas afetadas

- Usuário cliente: consegue registrar uma denúncia a partir do perfil do profissional.
- Produto/operação: recebe registro estruturado para análise administrativa futura.
- Segurança/compliance: preserva rastreabilidade, auditoria e minimização de dados.

## Requisitos atendidos

- Usuário consegue abrir denúncia a partir do perfil.
- Denúncia exige motivo.
- Denúncia permite descrição opcional.
- Evidência é opcional e referenciada por identificador de arquivo seguro.
- Denúncia é registrada para análise.
- Casos graves exibem orientação para buscar autoridades competentes.
- RN09/RN10/RN11/RN12: minimização, privacidade, auditoria e rastreabilidade.

## O que foi implementado

- Domínio `ProfessionalReport` com motivo obrigatório, descrição opcional, evidência opcional e orientação para casos
  graves.
- Caso de uso `RegisterProfessionalReportUseCase` com autenticação obrigatória e validação de profissional existente.
- Endpoint `POST /api/v1/professional-reports`.
- Persistência em `worklink.professional_reports` via migração `V014`.
- Adapter JDBC para salvar denúncias.
- Auditoria sensível para `REGISTER_PROFESSIONAL_REPORT`.
- Tela mobile `ProfessionalReportScreen` acessível a partir do perfil público do profissional.
- Testes BDD/TDD de domínio, aplicação, API, infraestrutura, controller mobile e tela.

## O que não foi implementado

- Painel administrativo de moderação.
- Decisão automática sobre procedência da denúncia.
- Processo jurídico ou mediação completa.
- Upload real de evidência no fluxo mobile; a tela usa referência local até integração HTTP/storage mobile.

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela mobile de perfil público do profissional.
- Tela mobile de denúncia de profissional.
- Endpoint `POST /api/v1/professional-reports`.
- Migração `V014__create_professional_reports.sql`.
- Protótipos:
  - `docs/prototipos-de-tela/tela-perfil-do-profissional.png`
  - `docs/prototipos-de-tela/tela-denunciar-profissional.png`

## Estratégia de testes

- Backend domínio: motivo obrigatório, descrição normalizada, evidência opcional e orientação para casos graves.
- Backend aplicação: registro autenticado, bloqueio sem autenticação, bloqueio de profissional inexistente e motivo
  inválido sem persistência.
- Backend API: contrato HTTP de denúncia com auditoria e bloqueio sem autenticação.
- Backend infraestrutura: persistência JDBC da denúncia.
- Mobile unitário: motivo obrigatório, submissão com descrição/evidência e orientação para caso grave.
- Mobile tela: bloqueio sem motivo, orientação para ameaça e submissão preenchida.

## Evidências de validação

- `make backend-unit-test`: PASS, 226 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v014`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 96,58%.
- `make mobile-screen-test`: PASS, 48 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
- `git diff --check`: PASS.
- Security diff scan: PASS.

## Riscos ou limitações remanescentes

- Denúncias são registradas, mas a triagem administrativa fica para `WL-016`.
- A tela mobile ainda não usa adapter HTTP real para salvar a denúncia.
- Evidência usa apenas identificador seguro no backend; upload mobile completo será conectado quando a camada de
  integração mobile/API for introduzida.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/domain/report`
- `worklink-api/src/main/java/br/com/worklink/application/report`
- `worklink-api/src/main/java/br/com/worklink/api/report`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/report`
- `worklink-api/src/main/resources/db/migration/V014__create_professional_reports.sql`
- `worklink-mobile/lib/features/professional_report`
- `worklink-mobile/lib/main.dart`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma nova capacidade funcional de denúncia de profissional, mantendo compatibilidade
com as funcionalidades existentes.
