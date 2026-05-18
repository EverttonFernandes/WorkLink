# WLT-023 — Emulador remoto e ambiente de teste online na pipeline

**Story**: [WLT-023-emulador-remoto-ambiente-teste-online.md](../../jira-pessoal/historias-tecnicas/WLT-023-emulador-remoto-ambiente-teste-online.md)

**Versão**: MINOR

**Status**: DOING

---

## Objetivo

Executar a suíte mobile de integração em Android Emulator na CI, preservando o modelo local baseado em Docker e sem exigir Flutter instalado diretamente na máquina do usuário.

## Critérios de aceite resumidos

- job dedicado de emulador Android na CI
- backend acessível ao emulador durante o teste
- `integration_test/` executando em ambiente real de device
- documentação alinhada ao fluxo local e remoto
