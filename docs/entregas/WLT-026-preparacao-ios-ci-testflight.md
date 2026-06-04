# Entrega WLT-026 — Preparação iOS para CI e TestFlight

## Resumo

A WLT-026 prepara o caminho iOS do WorkLink sem ativar custo recorrente de macOS runner em push e sem versionar
credenciais Apple.

## Escopo entregue

- Guia operacional em `docs/operacao/ios-ci-testflight.md`.
- Check local `make ios-readiness-check`.
- Script `scripts/check_ios_project_readiness.sh`.
- Workflow manual `.github/workflows/ios-build.yml`.
- Modo seguro `no-codesign` para validar estrutura iOS em macOS.
- Contrato de secrets Apple/TestFlight documentado.
- Bloqueio documental para `.p12`, `.p8`, `.mobileprovision`, `.provisionprofile`, `.cer`, `.key` e
  `GoogleService-Info.plist`.

## Evidências

- `make ios-readiness-check`: PASS.
- `sh -n scripts/check_ios_project_readiness.sh`: PASS.
- `make -n ios-readiness-check`: PASS.
- `git diff --check`: PASS.
- Auditoria local confirmou ausência de valores reais de certificados, profiles ou chaves privadas no diff.

## Limitações assumidas

- O workflow iOS é manual para evitar custo macOS recorrente.
- Upload real para TestFlight permanece fora do escopo e depende de Apple Developer Account e secrets reais.
- Teste em iPhone físico deve acontecer via TestFlight em incremento posterior.
