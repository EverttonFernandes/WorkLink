---
task_key: WLT-031
title: "Remoção de labels técnicas da UI mobile"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-031-remocao-labels-tecnicas-ui-mobile.md"
official_order: 52
phase: DONE
loop_iteration: 2
version_suggestion: PATCH
func_tests_detected: true
func_tests_path: "functional-tests/src/specs"
func_tests_framework: "jest"
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  func_tests: PASS
  mobile_tests: PASS
  coverage: PASS
  sonar: N/A
  sre: PASS
  security: PASS
  arch_review: PASS
  final_review: PASS
metrics:
  unit_coverage_minimum: 95
  changed_files: 6
  risk_level: LOW
release:
  commit_hash: ""
  semantic_tag: ""
correction_queue:
  - id: "WLT-031-MOBILE-001"
    origin: "product_manager"
    severity: "CRITICAL"
    status: "DONE"
    description: "Auditar e bloquear vazamento de enums, chaves internas, códigos técnicos e mensagens de debug nas telas mobile."
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-031 iniciada como próxima história elegível após fechamento da WLT-030 e CI verde."
    evidence:
      - "docs/jira-pessoal/KANBAN-OFICIAL.md"
      - "docs/jira-pessoal/historias-tecnicas/WLT-031-remocao-labels-tecnicas-ui-mobile.md"
      - "docs/debitos-tecnicos/DEBITOS-HOMOLOGACAO-MOBILE-2026-05-22.md#DTM-002"
      - "Functional Test Discovery: infraestrutura Jest detectada em functional-tests/src/specs."
  - iteration: 1
    phase: EXECUTION
    summary: "Mapeamentos públicos adicionados para classificações de perfil, categorias/cidades/profissionais sem mapa e sinais administrativos desconhecidos."
    evidence:
      - "worklink-mobile/lib/app/worklink_application_gateway.dart"
      - "worklink-mobile/lib/features/discovery/discovery_professional.dart"
      - "worklink-mobile/test/unit/app/worklink_application_gateway_test.dart"
  - iteration: 2
    phase: DONE
    summary: "Exit Bar local concluída; testes mobile, funcionais Docker e coverage aprovados."
    evidence:
      - "flutter analyze: PASS em /tmp/worklink-mobile-wlt031-validate"
      - "flutter test test/unit: 153 tests PASS"
      - "flutter test test/widget: 74 tests PASS"
      - "flutter test --coverage test/unit test/widget: 227 tests PASS, coverage 95.89%"
      - "make functional-test: 4 suites PASS, 10 tests PASS"
---

# WLT-031 — Plano de implementação

## Objetivo

Remover da interface mobile qualquer label técnica visível ao usuário final, com foco no débito `DTM-002`.
O domínio pode continuar usando enums e códigos internos, mas toda apresentação ao usuário deve passar por labels de produto
em português.

## Escopo

- Auditar telas Flutter em `worklink-mobile/lib`.
- Criar ou reforçar mapeamentos explícitos de labels públicas.
- Cobrir mapeamentos críticos e telas com testes.
- Adicionar verificação automatizada anti-vazamento técnico no mobile.
- Registrar evidência de QA para a história.

## Fora do escopo

- Alterar semântica dos enums internos.
- Trocar contratos HTTP com backend.
- Resolver massa regional, canais de OTP ou governança de homologação, que pertencem a WLT-032, WLT-033, WLT-034 e WLT-035.

## Critérios de aceite

- [x] Nenhuma tela mobile revisada exibe enum, chave interna, código técnico ou mensagem de debug.
- [x] Labels de confiança/completude aparecem em português e coerentes com o produto.
- [x] Testes protegem pelo menos os mapeamentos de labels críticos.
- [x] QA registra verificação anti-label técnica como `PASS`.

## Estratégia técnica

- Usar labels públicas junto dos modelos de apresentação existentes, sem alterar valores internos usados pela API.
- Adicionar teste de auditoria em widget/unit que falhe quando textos técnicos conhecidos aparecerem em telas de usuário.
- Manter nomes explícitos e testes no padrão `GIVEN/WHEN/THEN`.
- Validar com `flutter analyze`, `flutter test test/unit`, `flutter test test/widget` e CI GitHub Actions quando versionado.

## Log de Iterações (Ralph Loop)

- Iteração 0: história iniciada, plano criado e fonte oficial definida.
- Iteração 1: teste de guarda encontrou vazamento real de `professional-sem-mapa` em denúncias/análises administrativas.
- Iteração 2: fallback público para profissional não mapeado aplicado e validações locais aprovadas.

## Aprendizados do Loop

- A UI mobile pode conviver com códigos de backend desde que o mapeamento para label pública seja centralizado e testado.
- Testes anti-label técnica precisam incluir dados administrativos e métricas, não apenas a vitrine pública.
- `sonar` ficou `N/A` nesta história porque não há configuração Sonar específica para o módulo Flutter no repositório atual.
