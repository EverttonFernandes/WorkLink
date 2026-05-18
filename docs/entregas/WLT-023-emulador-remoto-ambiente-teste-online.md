# Entrega WLT-023 — Emulador remoto e ambiente de teste online na pipeline

## Identificador

- História: `WLT-023`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Executar os testes mobile de integração em Android Emulator dentro da CI, cobrindo a suíte `integration_test/` sem exigir Flutter SDK ou emulador configurado na máquina local do usuário.

## Contexto

O projeto já valida contrato HTTP mobile x backend real em Docker, mas ainda deixa `integration_test/` como `N/A` fora de ambientes com device. Esta história move essa validação para o pipeline.

## Implementação em progresso

- job `mobile-emulator` em [.github/workflows/ci.yml](/home/umov/Documents/ProjetosPessoais/WorkLink/.github/workflows/ci.yml)
- script [worklink-mobile/tool/run_mobile_emulator_integration_tests.sh](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-mobile/tool/run_mobile_emulator_integration_tests.sh)
- scripts auxiliares:
  - [scripts/wait_for_android_emulator.sh](/home/umov/Documents/ProjetosPessoais/WorkLink/scripts/wait_for_android_emulator.sh)
  - [scripts/install_debug_apk_on_emulator.sh](/home/umov/Documents/ProjetosPessoais/WorkLink/scripts/install_debug_apk_on_emulator.sh)
- backend e dependências sobem com Docker Compose no runner
- emulador acessa o backend via `http://10.0.2.2:8080`
- emulador local em Docker com noVNC para teste manual em `http://localhost:6080`

## Escopo assumido

- Android Emulator em GitHub Actions
- execução de `test/integration` e `integration_test/`
- documentação mínima do fluxo local versus remoto

## Fora do escopo

- iOS Simulator em CI
- device farm terceirizada
- ambiente remoto persistente para QA manual

## Evidências esperadas para fechamento

- workflow remoto executado com sucesso
- suíte `integration_test/` rodando em Android Emulator
- documentação atualizada sem prometer setup local fora do modelo em Docker

## Estado atual

- o job remoto de CI para Android Emulator foi preparado em `.github/workflows/ci.yml`
- o fluxo local containerizado foi estruturado com scripts, `Makefile` e imagem derivada do emulador
- o host atual ainda bloqueia o boot completo da AVD por limitação de espaço livre em disco
- por isso a história ainda depende da execução remota no GitHub Actions para ser fechada

## Observação

Enquanto a execução remota ainda não for observada no GitHub Actions, esta entrega deve permanecer em progresso e não pode ser considerada fechada.
