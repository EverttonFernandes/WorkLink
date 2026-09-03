---
name: ralph-loop/orquestrator
description: Orquestrador Senior do Ralph Loop. Coordena subagentes até atingir Exit Bar com máxima qualidade.
required_env: []
max_lines: 300
metadata:
  progressive_disclosure: "Comece por KANBAN, IMPLEMENTATION e progress; chame subagentes e rules somente quando o estado da historia exigir."
  conditional_details: "if historia nao iniciada then start-work/execution-plan; else_if gate falhou then acionar especialista; else_if pronta then final-reviewer e git-operator."
---

# Skill: Orquestrador Ralph Loop

Coordene a execução da história sem implementar código diretamente.

## Fontes

- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/tasks/<KEY>/IMPLEMENTATION.md`
- `docs/tasks/<KEY>/progress.txt`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/spec-driven-development.md`
- `.agents/rules/`
- `.agents/workflows/start-work.md`

Para UI mobile:

- `docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md`
- `docs/prototipos-de-tela/`

## Ciclo

1. Perceber: releia artefatos da história e frontmatter.
2. Orientar: compare critérios, regras e gates.
3. Decidir: escolha o próximo subagente.
4. Agir: forneça contexto mínimo e peça resultado verificável.
5. Registrar: atualize `IMPLEMENTATION.md` e `progress.txt`.

## Pré-Requisito

Se `IMPLEMENTATION.md` ou `progress.txt` não existir:

1. acione `ralph-loop/product-manager`;
2. crie plano e memória operacional;
3. aplique `.agents/rules/spec-to-execution-plan.md`;
4. só então libere execução técnica.

## Functional Test Discovery

Na primeira iteração, procure infraestrutura funcional:

- `functional-tests/`;
- `specs/`;
- `features/`;
- `src/test/functional`;
- `*FunctionalTest*`;
- `*IntegrationTest*`;
- `*IT.java`;
- Playwright, Cypress, Cucumber, Failsafe ou runner equivalente.

Persistir no frontmatter:

- `func_tests_detected`;
- `func_tests_path`;
- `func_tests_framework`.

Se existir, `func_tests` é obrigatório. Se não existir, `func_tests = N/A` com justificativa.

## Árvore De Decisão

1. `correction_queue` aberta: acione executor.
2. Gates de teste/qualidade pendentes ou falhando: acione QA.
3. UI mobile, protótipo, APK ou IPA: acione mobile frontend.
4. Ambiente, Docker, CI/CD ou disponibilidade: acione SRE.
5. Android/iOS, emulador, assinatura ou loja: acione mobile infra.
6. Auth, autorização, dados, LGPD ou superfície sensível: acione segurança e security guardian.
7. Arquitetura pendente: acione arquiteto.
8. Revisão final pendente: acione final reviewer.
9. Tudo aprovado: acione PM e git-operator para fechamento.

## Subagentes

- Product Manager: escopo, backlog, plano, entrega e versionamento sugerido.
- Executor: TDD, implementação e correções.
- QA: testes, coverage, evidência funcional e anti-reward hacking.
- Mobile Front-end: aderência visual, UX Flutter, microcopy e screenshots.
- Mobile Infra: CI mobile, emuladores, signing, lojas e trade-offs.
- SRE: Docker, CI/CD, configuração e operação.
- Segurança: autenticação, autorização, LGPD e auditoria local.
- Arquiteto: fronteiras, SOLID, ports/adapters, KISS/YAGNI.
- Final Reviewer: cruzamento final entre critérios, código, testes e docs.
- Git Operator: staging seletivo, commit semântico e tag.

## Exit Bar

Para concluir:

- todos os critérios de aceite marcados e verificados;
- testes aplicáveis verdes;
- coverage aplicável aprovado;
- SRE aprovado ou `N/A` justificado;
- security, arch_review e final_review em `PASS`;
- tela mobile validada contra protótipo quando aplicável;
- `docs/entregas/` atualizado;
- kanban atualizado;
- commit e tag semântica no mesmo hash.

## Controles

- `SKIP` é `FAIL`.
- Executor não aprova gate.
- QA, SRE, Segurança, Arquiteto e Final Reviewer aprovam apenas seu domínio.
- Sem evidência visual, UI mobile não fecha.
- Sem backend real, APK de homologação não pode ser vendido como full-stack.
- Sem teste local obrigatório, não há push para `main`.
- Sem tag no mesmo commit, a versão não está fechada.
- Sem história anterior funcional, não começa a próxima.

## Persistência

Registre a cada iteração:

- ação realizada;
- achado;
- teste executado;
- resultado;
- próximos passos;
- riscos remanescentes;
- itens manuais separados.

Ao detectar repetição do mesmo erro por 3 ciclos, registre mode collapse e mude a abordagem antes de continuar.
