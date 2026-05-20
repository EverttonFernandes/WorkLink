# Entrega WLT-023 — Emulador remoto e ambiente de teste online na pipeline

## Identificador

- História: `WLT-023`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Executar os testes mobile de integração em Android Emulator dentro da CI, cobrindo a suíte `integration_test/` sem exigir Flutter SDK ou emulador configurado na máquina local do usuário.

## Contexto

O projeto já valida contrato HTTP mobile x backend real em Docker, mas ainda deixa `integration_test/` como `N/A` fora de ambientes com device. Esta história move essa validação para o pipeline.

## Implementação concluída

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

## Evidências de fechamento

- GitHub Actions run `26176837198` executado com sucesso em `main`.
- Job `Mobile integration on Android emulator` concluído com sucesso em `13m20s`.
- A suíte `integration_test/` rodou em Android Emulator no CI.
- Backend e dependências subiram no runner e foram acessados pelo app no emulador via `10.0.2.2`.
- A validação continua sem exigir Flutter SDK ou device físico na máquina local do usuário.

## Estado atual

- história fechada com evidência remota verde no GitHub Actions
- o host local continua não sendo requisito para validar emulador Android
- próximos ajustes de DevOps mobile seguem nas histórias WLT-024 em diante

## Observação

A execução remota verde substitui a limitação do host local como critério de fechamento desta entrega.
