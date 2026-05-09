---
task_key: WL-009
title: "Autenticação simplificada do cliente por telefone"
story_path: "docs/jira-pessoal/historias/WL-009-autenticacao-cliente-telefone.md"
official_order: 25
phase: DONE
loop_iteration: 2
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
  changed_files: 14
  risk_level: MEDIUM
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.25.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-009 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-009-autenticacao-cliente-telefone.md"
      - "Backend de autenticação existente em application/api/infrastructure/authentication."
      - "Functional test discovery: infraestrutura Jest/Axios existe, mas sem cenários .spec.js reais; gate funcional N/A nesta história."
  - iteration: 1
    phase: EXECUTION
    summary: "Implementado fluxo mobile de autenticação por telefone e bloqueio de contato sem sessão."
    evidence:
      - "Novo teste backend: telefone existente autentica sem duplicar conta."
      - "Novos testes mobile unitários para telefone, código, reenvio e edição."
      - "Novos testes de tela para autenticação e contato sensível."
      - "make backend-unit-test: PASS, 173 testes e coverage aprovado."
      - "make mobile-unit-test: PASS, cobertura 99,26%."
      - "make mobile-screen-test: PASS."
  - iteration: 2
    phase: DONE
    summary: "Gates finais e documentação preparados para commit/tag v0.25.0."
    evidence:
      - "make backend-static-analysis: PASS."
      - "make backend-integration-test: PASS."
      - "make mobile-static-analysis: PASS."
      - "make mobile-integration-test: N/A por ausência de device/browser."
      - "make functional-test: N/A por ausência de cenários reais."
      - "docs/entregas/WL-009-autenticacao-cliente-telefone.md"
      - "git diff --check: PASS."
      - "Varredura de segredos: PASS com placeholder esperado em compose.yml."
---

# WL-009 — Autenticação simplificada do cliente por telefone

## Plano BDD/TDD

- Dado o usuário não autenticado, quando navegar e buscar profissionais, então a descoberta deve permanecer acessível.
- Dado o usuário não autenticado, quando tentar contato, então deve ser direcionado para autenticação por telefone.
- Dado telefone válido, quando continuar, então deve abrir verificação de código sem expor existência de conta.
- Dado código válido, quando confirmar, então deve concluir autenticação e liberar o contato sensível.
- Dado código incorreto, quando confirmar, então deve exibir mensagem genérica.
- Dado telefone em verificação, quando reenviar ou editar telefone, então deve permitir nova tentativa.

## Decisões

- A tela mobile não envia SMS real nesta história; ela modela a jornada e fica pronta para plugar adapter HTTP futuro.
- Login de conta existente e criação automática de conta nova permanecem no backend já implementado.
- O app preserva descoberta pública e exige autenticação apenas no contato sensível.

## Restrições Pragmáticas e Padrões

- Não adicionar login social.
- Não criar cadastro complexo de cliente.
- Não acoplar tela mobile a detalhes internos de OTP/backend.
- Testes devem usar `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado para fechar a experiência mobile da autenticação simplificada.
- Iteração 1: fluxo mobile implementado com TDD para controller/estado/tela e integração no perfil público.
- Iteração 2: gates QA/SRE/segurança/arquitetura aprovados por evidências locais; entrega pronta para fechamento
  semântico `v0.25.0`.

## Aprendizados do Loop

- O backend seguro de autenticação já existe; a WL-009 deve evitar duplicar regra no mobile e focar no fluxo do usuário.
- O contato real fica corretamente para WL-010; nesta história, o limite é autenticar antes da ação sensível.
