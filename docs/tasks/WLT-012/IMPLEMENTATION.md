---
task_key: WLT-012
title: "LGPD, privacidade e minimização de dados"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-012-lgpd-privacidade-dados-sensiveis.md"
official_order: 23
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
  changed_files: 18
  risk_level: HIGH
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.23.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-012 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-012-lgpd-privacidade-dados-sensiveis.md"
  - iteration: 1
    phase: DONE
    summary: "Privacidade por padrão entregue com inventário executável, rejeição de campos extras e projeção de anonimato."
    evidence:
      - "Backend unitário PASS: 159 testes e cobertura mínima >= 95%."
      - "Backend estático PASS: Checkstyle sem violações."
      - "Backend integração PASS: Flyway até v009 e testes integrados aprovados."
      - "Mobile PASS: análise estática, unitários 99,51% e widgets/telas aprovados."
      - "Funcional N/A: ainda sem cenários reais."
      - "Segurança PASS: sem segredos no diff, apenas placeholder esperado no compose.yml."
---

# WLT-012 — LGPD, privacidade e minimização de dados

## Plano BDD/TDD

- Dado o contrato público da V1, quando uma requisição HTTP enviar campos desconhecidos, então a API deve rejeitar a entrada.
- Dado o inventário de dados pessoais da V1, quando um campo permitido for consultado, então deve existir finalidade clara, retenção e política de exposição.
- Dado um dado fora do escopo da V1, quando a política for consultada, então ele deve ser rejeitado.
- Dado uma avaliação anônima futura, quando a autoria pública for projetada, então deve ocultar identidade pública sem remover autoria interna.
- Dado dados sensíveis, quando a política for consultada, então deve indicar exposição restrita ou interna.

## Decisões

- A política de privacidade será executável na camada de aplicação, independente do framework.
- A rejeição de campos desconhecidos será configurada no adapter HTTP para evitar coleta silenciosa.
- Exclusão de conta, retenção e incidentes serão documentados como desenho técnico mínimo nesta entrega.

## Restrições Pragmáticas e Padrões

- Não implementar fluxos funcionais futuros.
- Não criar portal LGPD ou workflow administrativo completo.
- Não coletar dados bancários, cartão, documentos com foto, localização contínua ou dados financeiros.
- Testes devem usar `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para política executável de privacidade por padrão.
- Iteração 1: inventário LGPD, hardening JSON e projeção de anonimato público foram implementados e validados.

## Aprendizados do Loop

- A WLT-012 deve complementar criptografia, autorização e auditoria existentes sem duplicar essas responsabilidades.
- Rejeitar campos desconhecidos no contrato HTTP reduz risco de coleta silenciosa de dados fora do escopo da V1.
