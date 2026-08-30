---
name: ralph-loop
description: Kernel de Orquestração Agêntica baseado no padrão Ralph Loop (Perceber → Orientar → Decidir → Agir → Registrar).
required_env: []
max_lines: 300
---

# Skill: Ralph Loop

Use esta skill quando o usuário pedir `ralph-loop` ou execução contínua das histórias do WorkLink.

## Objetivo

Concluir cada história com critérios atendidos, testes verdes, revisão especializada, documentação, commit e tag semântica no mesmo fechamento.

## Fontes Normativas

Leia somente o necessário para a história atual:

- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/spec-driven-development.md`
- `.agents/rules/spec-to-execution-plan.md`
- `.agents/rules/tdd-bdd-before-implementation.md`
- `.agents/rules/test-evidence-quality.md`
- `.agents/rules/refactor-after-functional-green.md`
- `.agents/rules/clean-code-readable-names.md`
- `.agents/rules/architecture-boundaries-and-solid.md`
- `.agents/rules/main-push-quality-and-versioning.md`
- `.agents/workflows/start-work.md`

Para tela mobile, leia também:

- `docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md`
- `docs/prototipos-de-tela/`
- `ralph-loop/mobile-frontend-specialist-agent`

## Fluxo

1. Perceber: ler kanban, história, `IMPLEMENTATION.md` e `progress.txt`.
2. Orientar: comparar estado atual com critérios, rules e gates.
3. Decidir: escolher próximo agente ou correção.
4. Agir: executar mudança, teste ou validação aplicável.
5. Registrar: atualizar artefatos, evidências, pendências e aprendizados.

## Artefatos Obrigatórios

Antes de implementar:

- `docs/tasks/<KEY>/IMPLEMENTATION.md`
- `docs/tasks/<KEY>/progress.txt`

Se não existirem, acione o fluxo de `start-work` e o `ralph-loop/product-manager`.

O `IMPLEMENTATION.md` deve conter frontmatter com:

- `phase`;
- `loop_iteration`;
- `exit_bar`;
- `correction_queue`;
- `metrics`;
- detecção de testes funcionais quando aplicável.

Status válidos de gate:

- `PASS`;
- `FAIL`;
- `PENDING`;
- `N/A`.

`SKIP`, `SKIPPED`, `ABORTED` ou status inventado equivalem a `FAIL`.

## Ordem Cronológica

A próxima história vem do topo elegível em `docs/jira-pessoal/KANBAN-OFICIAL.md`.

Não inicie história posterior enquanto a anterior não estiver:

- funcional;
- validada;
- documentada;
- versionada;
- com commit e tag no mesmo hash.

## Subagentes

Use a menor combinação necessária:

- `ralph-loop/product-manager`: escopo, plano, backlog, entrega e versão.
- `ralph-loop/executor-agent`: implementação e correções.
- `ralph-loop/qa-agent`: testes, coverage e evidências.
- `ralph-loop/mobile-frontend-specialist-agent`: Flutter, UX, protótipos, screenshots, APK/IPA.
- `ralph-loop/mobile-infra-specialist-agent`: Android/iOS, emuladores, assinatura, lojas e custos.
- `ralph-loop/sre-agent`: Docker, CI/CD, ambiente e operação.
- `ralph-loop/security-specialist-agent`: autenticação, autorização, LGPD e segurança.
- `security-guardian`: auditoria local do diff.
- `ralph-loop/architect-reviewer-agent`: arquitetura, SOLID, ports/adapters, KISS/YAGNI.
- `ralph-loop/final-reviewer-agent`: revisão final cruzando escopo, código, testes e docs.
- `git-operator`: commit seletivo e tag semântica.

## Decisão De Gate

Prioridade:

1. `correction_queue` aberta: executor.
2. testes ou coverage pendentes/falhando: QA e executor conforme achados.
3. UI mobile, APK ou IPA: mobile frontend antes do fechamento.
4. ambiente, Docker ou CI/CD: SRE.
5. Android/iOS, loja, assinatura ou emulador: mobile infra.
6. autenticação, autorização, dados ou LGPD: segurança e security guardian.
7. arquitetura pendente: arquiteto.
8. revisão holística pendente: final reviewer.
9. todos os gates verdes: PM documenta e git-operator fecha versão.

## Exit Bar

Obrigatório para finalizar:

- critérios de aceite atendidos;
- `lint`, `unit_tests`, `integration_tests`, `func_tests`, `mobile_tests`, `coverage`, `sonar` em `PASS` ou `N/A` justificado;
- `sre` em `PASS` ou `N/A` justificado;
- `security`, `arch_review` e `final_review` em `PASS`;
- documentação da entrega em `docs/entregas/`;
- kanban atualizado;
- commit seletivo da história;
- tag semântica apontando para o mesmo commit.

## Regras Inegociáveis

- TDD/BDD antes da implementação quando houver comportamento testável.
- Refatorar depois dos funcionais passarem.
- Código limpo vale para produção, testes, scripts, CI, fixtures e mobile.
- APK instalável não basta: precisa representar produto e protótipos.
- UI mobile mapeada precisa de evidência visual real ou decisão explícita de produto.
- Security é local e não depende de CI.
- Não esconda dívida manual; crie história/tarefa específica.
- Não stagear nem reverter mudanças não relacionadas.
- Persistir decisões em disco; memória conversacional não é fonte de verdade.
