# WLT-011 — Autenticidade, rastreabilidade e auditoria de ações sensíveis

## História

Como time técnico, quero registrar autoria e auditoria das ações sensíveis da V1, para permitir responsabilização, moderação e investigação sem expor dados sensíveis desnecessários.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-011-rastreabilidade-auditoria-acoes-sensiveis.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`

## Critérios de aceite

- [x] Toda ação sensível deve registrar autor interno.
- [x] Avaliação anônima deve preservar autoria interna.
- [x] Acesso administrativo à autoria interna deve ser auditado.
- [x] Acesso a evidência confidencial deve ser auditado.
- [x] Logs/auditoria não devem expor dados sensíveis desnecessários.

## Escopo técnico

- Criar modelo de evento de auditoria de ação sensível.
- Criar porta de persistência para auditoria.
- Criar use case de registro de auditoria.
- Criar tabela PostgreSQL para eventos de auditoria.
- Criar adapter JDBC para persistir eventos.
- Registrar auditoria nos endpoints sensíveis existentes.
- Preparar catálogo de ações para contato, feedback, avaliação, denúncia, contestação, disponibilidade e admin.

## Fora do escopo

- SIEM completo.
- Workflow avançado de investigação.
- Tela administrativa de consulta.
- Implementação dos fluxos funcionais futuros que ainda não existem.

## Evidências de conclusão

- Backend unitário: `rm -rf worklink-api/target && make backend-unit-test` com 143 testes e cobertura JaCoCo mínima atendida.
- Backend estático: `make backend-static-analysis` sem violações.
- Backend integração: `make backend-integration-test` com migrations até `v009` aplicadas e cobertura atendida.
- Mobile estático: `make mobile-static-analysis` sem issues.
- Mobile unitário: `make mobile-unit-test` com 33 testes e 99,51% de cobertura.
- Mobile tela/widget: `make mobile-screen-test` com 22 testes aprovados.
- Mobile integração: `make mobile-integration-test` classificado como N/A por exigir Android Emulator, iOS Simulator ou Chrome.
- Funcional/E2E: `make functional-test` classificado como N/A por ainda não haver cenários reais.
- Segurança: varredura local não encontrou segredos; apenas placeholder esperado de senha no `compose.yml`.
- Integridade do diff: `git diff --check` sem erros.
