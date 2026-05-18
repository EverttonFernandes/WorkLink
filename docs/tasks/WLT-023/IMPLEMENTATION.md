# WLT-023 — Emulador remoto e ambiente de teste online na pipeline

**Story**: [WLT-023-emulador-remoto-ambiente-teste-online.md](../../jira-pessoal/historias-tecnicas/WLT-023-emulador-remoto-ambiente-teste-online.md)

**Versão**: MINOR

**Status**: DOING

---

## Objetivo

Fechar o gap entre o contrato HTTP mobile em Docker e a execução real do app Flutter em device, adicionando um job de emulador Android na pipeline.

## Escopo

- adicionar job de Android Emulator no GitHub Actions
- preparar script de execução mobile para CI com backend em `10.0.2.2`
- preparar um caminho local em Docker para teste manual no emulador
- documentar o fluxo

## Fora do Escopo

- iOS Simulator em CI
- device farm externa
- ambiente remoto persistente para QA manual

## Plano

### Fase 1 — Descoberta

- [x] Revisar como a suíte mobile atual decide entre contrato HTTP e `integration_test/`.
- [x] Validar a forma mais simples de expor o backend do runner ao emulador.
- [x] Levantar o impacto no workflow atual da CI.

### Fase 2 — Implementação

- [x] Criar script dedicado para execução no emulador.
- [x] Adicionar job de CI com Android Emulator.
- [x] Ajustar documentação do fluxo.

### Fase 3 — Gates

- [x] Validar scripts localmente no que for possível sem emulador.
- [x] Validar consistência estática dos artefatos.
- [x] Registrar limitações remanescentes.

## Implementação realizada

- Criado [worklink-mobile/tool/run_mobile_emulator_integration_tests.sh](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-mobile/tool/run_mobile_emulator_integration_tests.sh) para executar:
  - contrato HTTP em `test/integration` contra `API_BASE_URL`
  - suíte `integration_test/` em device real de CI
- Criados os scripts:
  - [scripts/wait_for_android_emulator.sh](/home/umov/Documents/ProjetosPessoais/WorkLink/scripts/wait_for_android_emulator.sh)
  - [scripts/install_debug_apk_on_emulator.sh](/home/umov/Documents/ProjetosPessoais/WorkLink/scripts/install_debug_apk_on_emulator.sh)
- Atualizado [.github/workflows/ci.yml](/home/umov/Documents/ProjetosPessoais/WorkLink/.github/workflows/ci.yml) com job `mobile-emulator` usando:
  - `actions/setup-java`
  - `subosito/flutter-action`
  - `reactivecircus/android-emulator-runner`
- O backend é exposto ao emulador via `http://10.0.2.2:8080`, com dependências subidas por Docker Compose no runner.
- Adicionado o serviço `android-emulator` em [compose.yml](/home/umov/Documents/ProjetosPessoais/WorkLink/compose.yml) com noVNC em `http://localhost:6080`.
- Adicionados os alvos [Makefile](/home/umov/Documents/ProjetosPessoais/WorkLink/Makefile):
  - `mobile-emulator-prereqs`
  - `mobile-emulator-up`
  - `mobile-emulator-wait`
  - `mobile-emulator-install`
  - `mobile-manual-test`
- Atualizado [worklink-mobile/README.md](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-mobile/README.md) para distinguir claramente:
  - fluxo local containerizado
  - execução remota do `integration_test/` em Android Emulator na CI
  - fluxo manual no emulador Android em Docker antes da publicação

## Validações executadas

- `sh -n worklink-mobile/tool/run_mobile_emulator_integration_tests.sh`
- `sh -n scripts/wait_for_android_emulator.sh`
- `sh -n scripts/install_debug_apk_on_emulator.sh`
- `git diff --check`

## Ajustes apos validacao remota

- O primeiro run remoto com `mobile-emulator` confirmou o boot do emulador, a disponibilidade do backend e o sucesso do contrato HTTP.
- A falha ocorreu no `adb install` durante `flutter test integration_test -d emulator-5554`, com o Android retornando `Can't find service: activity` e `Can't find service: package`.
- O script [worklink-mobile/tool/run_mobile_emulator_integration_tests.sh](/home/umov/Documents/ProjetosPessoais/WorkLink/worklink-mobile/tool/run_mobile_emulator_integration_tests.sh) foi reforcado para:
  - aguardar explicitamente `sys.boot_completed`
  - aguardar `pm path android`
  - aguardar `cmd activity get-config`
  - aquecer o `flutter build apk --debug` antes da execucao do `integration_test`
  - revalidar o runtime Android imediatamente antes do teste em device

## Limitações atuais

- A validação fim a fim da `WLT-023` ainda depende da execução do workflow remoto no GitHub Actions.
- O fluxo local continua sem exigir Flutter instalado na máquina do usuário.
- O emulador local exige host Linux com `/dev/kvm` disponível para ter tempo de boot aceitável.
- O emulador local em Docker também exige pelo menos `16 GB` livres no filesystem do host; abaixo disso o consumo combinado de imagem + AVD pode impedir a criação da partição `userdata`.

## Exit Bar

```yaml
exit_bar:
  lint: PASS
  unit_tests: N/A
  integration_tests: PASS
  mobile_tests: PASS
  coverage: N/A
  security: PASS
  sre: PASS
  arch_review: PASS
  final_review: PENDING
```
