---
task_key: WL-005
title: "Perfil público detalhado do profissional"
story_path: "docs/jira-pessoal/historias/WL-005-perfil-publico-profissional.md"
official_order: 14
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
  changed_files: 21
  risk_level: MEDIUM
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.14.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-005 iniciada a partir da próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-005-perfil-publico-profissional.md"
      - "docs/prototipos-de-tela/tela-perfil-do-profissional.png"
  - iteration: 1
    phase: DONE
    summary: "Perfil público mobile implementado com BDD/TDD, navegação pela listagem e gates executados em container."
    evidence:
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, cobertura 100.00%"
      - "make mobile-screen-test: PASS"
      - "make backend-static-analysis: PASS"
      - "make backend-unit-test: PASS, 71 testes, JaCoCo PASS"
      - "make backend-integration-test: PASS"
      - "make mobile-integration-test: N/A sem emulator/simulator/Chrome"
      - "make functional-test: N/A sem cenários reais"
---

# WL-005 — Perfil público detalhado do profissional

## Plano BDD/TDD

- Dado a listagem de profissionais, quando o usuário tocar em um card, então deve abrir o perfil público daquele profissional.
- Dado um perfil completo, quando a tela renderizar, então deve mostrar foto, nome, categoria, cidade base, cidades atendidas, descrição, serviços, disponibilidade e badges.
- Dado campos opcionais ausentes, quando a tela renderizar, então não deve exibir seções vazias.
- Dado o perfil público, quando o usuário acionar contato, então deve emitir o identificador do profissional.
- Dado o perfil público, quando o usuário acionar denúncia, então deve emitir o identificador do profissional.
- Dado badges/completude no perfil, quando a tela renderizar, então deve deixar claro que completude não garante qualidade.

## Decisões

- A tela usará dados locais até a integração HTTP real ser planejada.
- Contato e denúncia serão callbacks; fluxos completos pertencem às histórias `WL-010` e `WL-014`.
- Portfólio será representado por descrições locais sem carregar imagens remotas nesta entrega, evitando dependência de storage antes da `WLT-014`.
- Avaliações reais permanecem fora do escopo; a tela reserva a área quando houver resumo disponível.

## Restrições Pragmáticas e Padrões

- Não acoplar SDKs externos de WhatsApp, storage ou autenticação à tela.
- Não criar ranking, garantia de qualidade ou verificação documental avançada.
- Manter dados opcionais renderizados somente quando preenchidos.
- Usar nomes explícitos e testes `GIVEN`, `WHEN`, `THEN`.

## Log de Iterações

- Iteração 0: plano criado, detecção funcional registrada como `N/A` porque existe runner funcional, mas ainda não existem cenários reais em `functional-tests/src`.
- Iteração 1: testes BDD/TDD criados para modelo, tela e navegação; implementação concluída no mobile com dados locais e callbacks.

## Aprendizados do Loop

- A ação de abrir perfil já foi preparada em `WL-004`; esta história deve conectar a navegação real sem inflar backend.
- O lint mobile exigiu normalização de vírgulas finais e formatação em arquivos existentes para manter o gate estático íntegro.
