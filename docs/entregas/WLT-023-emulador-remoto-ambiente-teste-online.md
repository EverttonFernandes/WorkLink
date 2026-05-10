# Entrega WLT-023 — Emulador remoto e ambiente de teste online na pipeline

## Identificador

- História: `WLT-023`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Configurar emulador remoto (Android Emulator na nuvem ou GitHub Actions) para que testes de integração mobile rodem automaticamente na pipeline, sem exigir device físico ou setup local.

## Contexto

Atualmente, `make mobile-integration-test` retorna "N/A: environment não tem emulador". Esta história habilita testes automatizados contra emulador remoto.

## Requisitos técnicos atendidos

- Emulador Android rodando em CI/CD.
- Testes mobile executáveis contra emulador real.
- Resultado integrado em relatório de CI.

## O que foi implementado

- **GitHub Actions workflow** (`.github/workflows/ci.yml`):
  - Job `mobile-integration-tests` com emulador Android API 31.
  - Ativa emulador com: `reactivecircus/android-emulator-runner`.
  - Executa testes Flutter contra emulador: `flutter test integration_test/`.

- **Docker Compose**:
  - Configuração para rodar emulador em Docker (alternativa local).
  - Docker image com Android SDK e emulador pré-configurado.
  - Target `docker compose up android-emulator`.

- **Makefile target**: `make mobile-integration-emulator` para rodar localmente.

- **Script de setup**: `worklink-mobile/tool/setup_emulator.sh` — configuração initial.

- **Selênio/Appium** (opcional):
  - Setup para Appium se integração mais profunda for necessária.
  - Documentado em `worklink-mobile/INTEGRATION-TEST-GUIDE.md`.

## O que não foi implementado

- Emulador iOS em CI (requer runner macOS, mais caro).
- Selenium Grid remoto (apenas emulador padrão).
- Upload de artifacts (screenshots/videos) após falha.

## Fluxos, telas, endpoints ou módulos envolvidos

- `.github/workflows/ci.yml` — novo job de integração.
- `worklink-mobile/integration_test/` — testes de integração.
- `worklink-mobile/tool/setup_emulator.sh` — setup script.
- `docker-compose.yml` — serviço android-emulator (opcional).

## Estratégia de testes

- CI: Emulador setup automático, testes executados contra ele.
- Local: `flutter run -d emulator` ou `docker compose up android-emulator`.
- Backend: Roda em container Docker durante testes.

## Evidências de validação

- `make mobile-integration-test` em CI sem timeout.
- Todos os testes passam contra emulador remoto.
- CI log mostra execução de testes e cobertura.
- Relatório gerado: `worklink-mobile/coverage/integration-report.html`.

## Riscos ou limitações remanescentes

- Emulador em CI pode ser lento (~5-10min por suite).
- Flakiness em emulador pode causar falsos negativos (requer retry logic).
- iOS integration tests ainda requerem setup manualem runner macOS.

## Arquivos ou módulos relevantes

- `.github/workflows/ci.yml` — novo job.
- `worklink-mobile/integration_test/` — testes mobile.
- `worklink-mobile/tool/setup_emulator.sh` — script de setup.
- `worklink-mobile/INTEGRATION-TEST-GUIDE.md` — documentação.
- `docker-compose.yml` — serviço emulador (opcional).

## Justificativa do versionamento

Entrega `MINOR` porque adiciona capacidade de teste sem mudança de produção. Essencial para E2E automático na pipeline.
