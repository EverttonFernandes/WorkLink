---
task_key: WL-015
title: "Perfil do usuário cliente"
story_path: "docs/jira-pessoal/historias/WL-015-perfil-usuario.md"
official_order: 31
phase: DONE
loop_iteration: 1
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: "functional-tests/src/**/*.spec.js"
func_tests_framework: "Jest + Axios sem cenários reais executáveis no momento"
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
  changed_files: 11
  risk_level: MEDIUM
release:
  commit_hash: ""
  semantic_tag: v0.31.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-015 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-015-perfil-usuario.md"
      - "Functional test discovery: infraestrutura Jest/Axios existe, mas sem cenários .spec.js reais; gate funcional N/A nesta história."
  - iteration: 1
    phase: DONE
    summary: "Perfil mobile do cliente entregue com autenticação prévia, dados mínimos, preferências e logout."
    evidence:
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, 71 testes, cobertura 96,18%"
      - "make mobile-screen-test: PASS, 53 testes"
      - "make backend-unit-test: PASS, 226 testes, cobertura mínima atendida"
      - "make backend-static-analysis: PASS"
      - "make backend-integration-test: PASS, Flyway v014"
      - "make backend-image-build: PASS"
      - "make functional-test: N/A sem cenários reais"
      - "make mobile-integration-test: N/A sem Android Emulator, iOS Simulator ou Chrome"
---

# WL-015 — Perfil do usuário cliente

## Plano BDD/TDD

- Dado usuário não autenticado, quando abrir perfil do cliente, então deve autenticar antes de mostrar dados pessoais.
- Dado usuário autenticado, quando abrir perfil, então deve visualizar nome, telefone e cidade principal.
- Dado usuário autenticado, quando abrir perfil, então deve visualizar cidades selecionadas, profissionais salvos e
  avaliações enviadas.
- Dado usuário autenticado, quando alterar preferências básicas, então a tela deve refletir a nova preferência.
- Dado usuário autenticado, quando sair da conta, então deve encerrar a sessão local e voltar ao fluxo de descoberta.

## Decisões

- Esta história entrega a experiência mobile mínima do perfil do cliente.
- O backend atual possui autenticação do cliente, mas ainda não possui agregado persistente de perfil/preferências do
  cliente; a integração HTTP real fica fora do escopo para evitar acoplamento e complexidade prematura.
- Dados pessoais exibidos devem ser mínimos: nome, telefone e cidade principal.

## Restrições Pragmáticas e Padrões

- Não expor dados pessoais em telas públicas.
- Não criar histórico financeiro ou preferências avançadas.
- Não acoplar regra de perfil à tela; usar modelo e controller próprios.
- Testes devem usar `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para perfil mobile mínimo do cliente com autenticação exigida.
- Iteração 1: implementação e validação final concluídas com gates em container.

## Aprendizados do Loop

- WL-009 já fornece autenticação local do cliente no app; WL-015 deve reaproveitar esse fluxo para gatear a tela do
  perfil.
- O backend ainda não possui agregado persistente do perfil do cliente; manter a tela em estado local evita inventar API
  antes da história correspondente.
