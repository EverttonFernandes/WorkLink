---
task_key: WL-004
title: "Listagem de profissionais com sinais mínimos"
story_path: "docs/jira-pessoal/historias/WL-004-listagem-profissionais.md"
official_order: 13
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
  changed_files: 10
  risk_level: LOW
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.13.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WL-004 iniciada a partir da próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias/WL-004-listagem-profissionais.md"
      - "docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md"
  - iteration: 1
    phase: DONE
    summary: "Cards comparáveis com sinais mínimos opcionais e ação de abrir perfil implementados no mobile."
    evidence:
      - "make mobile-static-analysis"
      - "make mobile-unit-test"
      - "make mobile-screen-test"
      - "make backend-static-analysis"
      - "make backend-unit-test"
      - "make backend-integration-test"
      - "make mobile-integration-test"
      - "make functional-test"
      - "git diff --check"
      - "security scan local sem segredo novo; ocorrência em compose.yml usa env var WORKLINK_POSTGRES_PASSWORD"
---

# WL-004 — Listagem de profissionais com sinais mínimos

## Plano BDD/TDD

- Dado profissionais compatíveis com filtros, quando a listagem renderizar, então deve exibir somente os cards compatíveis.
- Dado um profissional com dados resumidos, quando o card renderizar, então deve mostrar nome, categoria, cidade e descrição curta.
- Dado sinais mínimos preenchidos, quando o card renderizar, então deve exibir somente os badges justificados por dados.
- Dado profissional sem disponibilidade informada, quando o card renderizar, então não deve receber destaque indevido de disponibilidade.
- Dado um card de profissional, quando o usuário tocar para abrir perfil, então a ação de abertura deve receber o identificador do profissional.

## Decisões

- Os sinais mínimos serão dados opcionais no modelo mobile de descoberta, mantendo a UI honesta quando não houver disponibilidade ou atividade recente.
- A abertura de perfil será preparada por callback no `DiscoveryScreen`; a tela detalhada real pertence à `WL-005`.
- A integração HTTP real permanece fora do escopo; a história reforça a experiência de listagem sobre os dados já disponíveis.
- Não será criada regra de garantia de qualidade, ranking ou avaliação nesta entrega.

## Restrições Pragmáticas e Padrões

- Manter a lógica de filtro no controller/estado mobile existente, sem criar camada nova para integração ainda inexistente.
- Preservar nomes explícitos e testes no padrão `GIVEN`, `WHEN`, `THEN`.
- Não acoplar regra de negócio a widgets além da decisão visual de exibir ou ocultar sinais já calculados no modelo.
- Não criar abstrações genéricas para badges; usar estrutura simples e testável.

## Log de Iterações

- Iteração 0: plano criado, detecção funcional registrada como `N/A` porque existe runner funcional, mas ainda não existem cenários reais em `functional-tests/src`.
- Iteração 1: implementação concluída com modelo mobile de sinais opcionais, cards comparáveis, callback de abertura de perfil e testes BDD/TDD.

## Aprendizados do Loop

- A descoberta da história anterior já garante compatibilidade por filtros; esta história deve melhorar a comparação visual sem duplicar a regra de busca.
- Rodar targets que compartilham cache/containers em paralelo pode gerar conflito de volume/container; backend foi validado novamente em sequência.

## Resultado

- A listagem mobile usa cards com nome, categoria, cidade, descrição curta, avatar e sinais opcionais.
- Badges vazios ou ausentes não são renderizados, evitando destaque indevido de disponibilidade quando não há dado.
- Cada card expõe ação de abertura de perfil por identificador, preparando a `WL-005` sem implementar o perfil detalhado nesta história.
- Testes funcionais e integração mobile foram executados como `N/A` por ausência de cenários reais e device/emulador.
