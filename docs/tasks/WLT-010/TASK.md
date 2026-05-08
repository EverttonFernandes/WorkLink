# WLT-010 — Autorização por perfil e ownership

## História

Como time técnico, quero aplicar autorização por perfil e ownership nos endpoints sensíveis, para impedir acesso indevido a dados administrativos, dados privados e autoria interna.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-010-autorizacao-perfis-ownership.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`

## Critérios de aceite

- [x] Cliente não deve acessar dados administrativos.
- [x] Cliente não deve acessar dados privados de outros usuários.
- [x] Profissional não deve acessar denúncias internas contra terceiros.
- [x] Profissional não deve acessar autoria interna de avaliação anônima.
- [x] Endpoints sensíveis devem validar ownership e permissão.
- [x] Ações administrativas devem exigir perfil adequado.

## Escopo técnico

- Criar modelo de principal autenticado com perfil `CUSTOMER`, `PROFESSIONAL` e `ADMINISTRATOR`.
- Criar política de autorização por ação sensível e ownership.
- Criar parser/validador de access token HMAC-SHA-256 emitido na WLT-009.
- Adicionar resolver HTTP de `Authorization: Bearer`.
- Proteger endpoints administrativos de catálogo.
- Proteger alteração de perfil profissional por perfil e ownership.
- Cobrir regras com testes BDD/TDD.

## Fora do escopo

- IAM externo.
- RBAC corporativo complexo.
- Auditoria persistida, que pertence à WLT-011.
- Telas mobile.

## Evidências de validação

- `make backend-unit-test`: PASS, 132 testes, JaCoCo validado com mínimo de 95%.
- `make backend-static-analysis`: PASS, 0 violações de Checkstyle.
- `make backend-integration-test`: PASS, Flyway validado até `v008`.
- `make mobile-static-analysis`: PASS, Flutter analyze sem issues.
- `make mobile-unit-test`: PASS, cobertura unitária mobile 99.51%.
- `make mobile-screen-test`: PASS, 22 testes de tela/widget.
- `make mobile-integration-test`: N/A, sem emulador Android, iOS Simulator ou Chrome disponível no container.
- `make functional-test`: N/A, suíte funcional ainda sem cenários reais.
- `git diff --check`: PASS.
- Scan local de secrets: PASS, apenas placeholder esperado `WORKLINK_POSTGRES_PASSWORD` em `compose.yml`.
