---
task_key: WLT-026
title: Preparacao iOS para CI e TestFlight
phase: READY_TO_CLOSE
loop_iteration: 2
official_order: 57
version_suggestion: MINOR
progress_file: docs/tasks/WLT-026/progress.txt
func_tests_detected: false
func_tests_path: ""
func_tests_framework: ""
exit_bar:
  acceptance_criteria: PASS
  clean_code: PASS
  lint: PASS
  unit_tests: N/A
  integration_tests: N/A
  func_tests: N/A
  mobile_tests: PASS
  coverage: N/A
  sre_review: PASS
  security_review: PASS
  architecture_review: PASS
  final_review: PASS
  documentation: PASS
  kanban_updated: PASS
  git_commit: PENDING
  semantic_tag: PENDING
correction_queue:
  - id: WLT-026-IOS-001
    severity: CRITICAL
    status: RESOLVED
    description: "Preparar governanca iOS/TestFlight sem versionar certificados, profiles ou chaves privadas."
metrics:
  files_changed: 8
  tests_run:
    - "make ios-readiness-check: PASS"
    - "sh -n scripts/check_ios_project_readiness.sh: PASS"
    - "make -n ios-readiness-check: PASS"
    - "git diff --check: PASS"
  ci_run: null
---

# Plano de Execucao - WLT-026

## Contexto

A WLT-026 prepara o caminho iOS para CI macOS e TestFlight, sem executar publicacao real nem exigir conta Apple nesta
etapa.

## Proxima Historia Elegivel

A WLT-029 foi concluida e versionada em `v0.49.0`. A primeira historia restante no Backlog e a WLT-026.

## Decisao Tecnica

- O build iOS automatizado deve ser manual (`workflow_dispatch`) ate existir decisao de custo para macOS runner.
- Sem Apple Developer Account, o projeto pode validar estrutura Flutter/iOS e `flutter build ios --no-codesign`.
- TestFlight real exige certificados, provisioning profiles, App Store Connect API key e secrets protegidos.
- Nenhum certificado, `.p12`, `.p8`, `.mobileprovision`, `.provisionprofile`, `GoogleService-Info.plist` ou chave privada
  pode ser versionado.

## Escopo

1. Criar guia operacional iOS CI/TestFlight.
2. Criar script local de prontidao iOS sem secrets.
3. Criar target Makefile para o check.
4. Criar workflow manual `ios-build` como desenho executavel e guardado por secrets.
5. Atualizar release mobile, entrega e Kanban.

## Criterios de Aceite

- [x] Existe guia claro para habilitar build iOS na CI.
- [x] Os secrets e variaveis esperados estao documentados.
- [x] O projeto explicita o que pode ser validado sem conta Apple e o que depende dela.
- [x] A futura automacao de TestFlight fica mapeada como proximo incremento.
- [x] Nenhum certificado, chave privada ou profile sensivel e versionado.

## Estrategia de Testes

- Rodar `make ios-readiness-check`.
- Rodar `sh -n` nos scripts alterados.
- Validar YAML do workflow por inspecao e `git diff --check`.
- Nao executar macOS runner automaticamente nesta historia.

## Log de Iteracoes

- Iteracao 1: WLT-026 iniciada apos WLT-029 com CI verde, release `v0.49.0` criado e APK Android homologation anexado.
- Iteracao 2: guia iOS/TestFlight criado, workflow manual macOS criado, check local de estrutura iOS aprovado e auditoria
  confirmou que apenas nomes de secrets foram documentados, sem valores reais.

## Aprendizados do Loop

- iOS deve entrar de forma progressiva para evitar custo recorrente de macOS antes da conta Apple e dos secrets reais.
