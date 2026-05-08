---
task_key: WLT-011
title: "Autenticidade, rastreabilidade e auditoria de ações sensíveis"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-011-rastreabilidade-auditoria-acoes-sensiveis.md"
official_order: 22
phase: DONE
loop_iteration: 1
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: "functional-tests/src/**/*.spec.js"
func_tests_framework: "Jest + Axios"
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  func_tests: N/A
  mobile_tests: PASS
  coverage: PASS
  sonar: N/A
  sre: PASS
  security: PASS
  arch_review: PASS
  final_review: PASS
metrics:
  unit_coverage_minimum: 95
  changed_files: 23
  risk_level: HIGH
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.22.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-011 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-011-rastreabilidade-auditoria-acoes-sensiveis.md"
  - iteration: 1
    phase: DONE
    summary: "Auditoria persistida de ações sensíveis entregue com BDD/TDD, portas e adapters."
    evidence:
      - "Backend unitário PASS: 143 testes e cobertura mínima >= 95%."
      - "Backend estático PASS: Checkstyle sem violações."
      - "Backend integração PASS: Flyway até v009 e testes integrados aprovados."
      - "Mobile PASS: análise estática, unitários 99,51% e widgets/telas aprovados."
      - "Funcional N/A: ainda sem cenários reais."
      - "Segurança PASS: sem segredos no diff, apenas placeholder esperado no compose.yml."
---

# WLT-011 — Autenticidade, rastreabilidade e auditoria de ações sensíveis

## Plano BDD/TDD

- Dado uma ação sensível executada por principal autenticado, quando a ação for concluída, então deve registrar autor, perfil, ação, alvo e data.
- Dado uma avaliação anônima futura, quando for registrada, então a auditoria deve suportar autoria interna sem expor essa autoria publicamente.
- Dado acesso administrativo à autoria interna, quando o acesso ocorrer, então deve existir ação auditável específica.
- Dado acesso a evidência confidencial, quando o acesso ocorrer, então deve existir ação auditável específica.
- Dado um registro de auditoria, quando persistido, então não deve gravar payload sensível bruto, token, telefone, documento ou segredo.

## Decisões

- A auditoria ficará na camada de aplicação, atrás de porta de persistência.
- O adapter JDBC persistirá somente metadados mínimos: ação, autor, perfil, alvo, tipo de alvo, resultado e data.
- Controllers só orquestram resolução de principal, autorização, execução do caso de uso e registro do evento.
- As ações funcionais futuras serão modeladas no enum de auditoria agora, mas só serão disparadas quando os fluxos existirem.

## Restrições Pragmáticas e Padrões

- Não criar SIEM, fila ou outbox nesta entrega.
- Não persistir payload de requisição, access token, refresh token, telefone, documento ou segredo.
- Não acoplar auditoria ao framework ou a detalhes HTTP.
- Testes devem usar padrão `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para trilha de auditoria persistida de ações sensíveis.
- Iteração 1: modelo de auditoria, porta, caso de uso, adapter JDBC, migration e registros nos endpoints sensíveis existentes foram implementados e validados.

## Aprendizados do Loop

- A WLT-010 já centralizou principal autenticado e ações sensíveis; a WLT-011 deve reaproveitar esse contrato sem misturar autorização e auditoria.
- A auditoria deve registrar metadados mínimos e preparar ações futuras sem antecipar fluxos funcionais ainda inexistentes.
