---
task_key: "WLT-029"
branch: "main"
phase: EXECUTION
loop_iteration: 7
max_iterations: 12
fresh_context_after_iteration: 3
progress_file: "docs/tasks/WLT-029/progress.txt"
completion_promise: PENDING
func_tests_detected: true
func_tests_path: "functional-tests/src/specs"
func_tests_framework: "jest"
exit_bar:
  lint:          PASS
  unit_tests:    PASS
  integration_tests: PASS
  func_tests:    PASS
  mobile_tests:  PASS
  sonar:         PASS
  coverage:      PASS
  sre:           PENDING
  security:      PASS
  arch_review:   PENDING
  final_review:  PENDING
last_cycle:
  agent: "orquestrator"
  action: "formalizacao do parceiro Mobile Infra Specialist para o SRE"
  result: "subagente documental criado; ADR e guia operacional registram estrategia mobile Android/iOS, custos e trade-offs"
  timestamp: "2026-05-22T00:00:00-03:00"
correction_queue:
  - id: "WLT-029-BLOCKER-001"
    origin: "sre"
    severity: "CRITICAL"
    status: "OPEN"
    description: "Gerar artifact Android homologation full-stack exige WORKLINK_HOMOLOGATION_API_BASE_URL HTTPS, WORKLINK_HOMOLOGATION_ALLOWED_HOSTS e secrets de assinatura Android de homologacao."
  - id: "WLT-029-BLOCKER-002"
    origin: "security"
    severity: "CRITICAL"
    status: "RESOLVED"
    description: "Artifact promovivel nao pode ser debug, assinado com chave debug, apontar para host local/privado/fora da allowlist ou armazenar APK binario dentro do git."
metrics:
  first_pass_gates:
    - lint
    - unit_tests
    - integration_tests
    - func_tests
    - mobile_tests
    - sonar
    - coverage
  total_iterations: 1
  gates_failed_count: 0
  mode_collapse_events: 0
  convergence_notes: "CI convergiu no commit 5d2adb2; keystore de homologacao foi gerada localmente; SRE agora possui parceiro Mobile Infra Specialist documentado; fechamento segue bloqueado por URL HTTPS de homologacao para configurar GitHub Actions e gerar APK full-stack versionado."
---

# WLT-029 — Homologação mobile full-stack e artifacts estáveis

**Story**: [WLT-029-homologacao-mobile-fullstack-artifacts.md](../../jira-pessoal/historias-tecnicas/WLT-029-homologacao-mobile-fullstack-artifacts.md)

**Versão**: MINOR

**Status**: DOING

---

## Objetivo

Permitir que o dono do produto valide manualmente uma versão semântica fechada do WorkLink em Android e iOS usando um ambiente de homologação completo, com aplicativo mobile, backend, banco de dados e massa funcional de profissionais fictícios da região carbonífera.

## Contexto de Produto

A entrega protege a proposta central do WorkLink V1: descoberta local de profissionais por cidade/categoria com dados reais de backend, evitando que um APK de preview seja confundido com validação de release.

## Escopo

- [x] Criar história oficial e entrega documental para homologação full-stack.
- [x] Criar massa fake de homologação com cidades, categorias e profissionais da região carbonífera.
- [x] Criar comando local para subir backend, banco e massa de homologação.
- [x] Permitir build Android com `API_BASE_URL` configurável.
- [x] Publicar artifact Android full-stack quando a URL HTTPS de homologação e a assinatura estiverem configuradas.
- [x] Criar contrato de `artifacts/homologation/releases/<versao>/android`.
- [x] Criar promoção controlada do artifact full-stack para metadados versionados e asset de GitHub Release.
- [ ] Gerar APK Android full-stack versionado a partir de backend de homologação acessível pelo celular.
- [ ] Promover APK full-stack como asset de GitHub Release e registrar metadados em `artifacts/homologation/releases/<versao>/android`.
- [ ] Fechar tag semântica sobre o commit final da história.
- [x] Criar runbook e scripts para configurar variables/secrets de homologação Android no GitHub Actions.
- [x] Documentar parceiro especializado do SRE para infraestrutura mobile Android/iOS, custos e trade-offs.

## Fora do Escopo

- Publicação automática em Google Play.
- Publicação automática em Apple App Store.
- Assinatura final de produção.
- Provisionamento definitivo de cloud de homologação.

## Plano Técnico

### Fase 1 — Base de Homologação

- [x] Separar APK preview/offline de APK full-stack.
- [x] Adicionar seed de homologação em `functional-tests/src/scripts/seedHomologationScenario.js`.
- [x] Adicionar `make homologation-local-up`.

### Fase 2 — Build Android Full-Stack

- [x] Fazer o `ApiClient` aceitar `--dart-define=API_BASE_URL`.
- [x] Adicionar `make mobile-android-homologation-candidate`.
- [x] Adicionar metadata `app_data_mode=homologation-fullstack`.
- [x] Permitir URL via repository variable, repository secret ou input manual do workflow.
- [x] Exigir URL HTTPS e rejeitar host local/privado para artifact promovível.
- [x] Exigir release build assinado com chave de homologação.
- [x] Exigir allowlist obrigatória do host de homologação.

### Fase 3 — Artifact Versionado

- [x] Criar `artifacts/homologation/README.md`.
- [x] Criar `scripts/promote_android_homologation_artifact.sh`.
- [x] Criar `scripts/generate_android_homologation_keystore.sh`.
- [x] Criar `scripts/configure_android_homologation_github_env.sh`.
- [x] Criar `docs/operacao/homologacao-android-github-actions.md`.
- [x] Bloquear promoção de artifact `preview`.
- [x] Bloquear promoção de artifact sem `api_base_url`.
- [x] Bloquear promoção de APK debug ou assinado com chave debug.
- [x] Evitar versionamento do APK binário dentro do git; APK fica como asset do GitHub Release.
- [x] Validar certificado real do APK com `apksigner` e fingerprint SHA-256 esperado.
- [x] Validar checksum antes da promoção.
- [ ] Executar promoção real para uma versão semântica.

### Fase 4 — Fechamento

- [ ] Validar APK instalado no Android físico.
- [ ] Registrar evidências finais.
- [ ] Mover WLT-029 para Done.
- [ ] Commit de fechamento e tag semântica no mesmo hash.

## Estratégia de Testes

- GitHub Actions `WorkLink CI` é o gate principal para artifact promovível.
- Docker Desktop foi detectado via `docker.exe` no ambiente local; Flutter segue indisponível diretamente no WSL.
- Testes funcionais detectados em `functional-tests/src/specs` com Jest; gate obrigatório.
- Testes mobile e integração Android são validados pelo job `Mobile integration on Android emulator`.
- O APK full-stack precisa ser gerado por workflow com `homologation_api_base_url`, variable ou secret.

## Evidências Já Coletadas

- Run `26197769468`: `completed success`.
- Run `26198971069`: `completed success`.
- Run `26253710509`: `completed success` no commit `6b3c100e5490befd0b7df743bae7ed5f45f91d51`.
- Run `26259403194`: `completed success` no commit `17d805d41f2ff52d3446dfcdba9f933eb511d6a6`.
- Run `26259983380`: `completed success` no commit `5d2adb216e7eb6145fb9391f4921385a1e2709e1`.
- Jobs verdes:
  - `Backend quality gates`
  - `Dependency scan`
  - `API Docker image`
  - `Mobile integration on Android emulator`
  - `Mobile quality gates`
- Artifacts do run `26253710509`:
  - `worklink-android-test-candidate-6b3c100e5490befd0b7df743bae7ed5f45f91d51`
  - `mobile-emulator-diagnostics-26253710509-1`
  - `worklink-android-homologation-*` ausente, conforme esperado enquanto variables/secrets de homologação não existem.
- Artifacts do run `26259403194`:
  - `worklink-android-test-candidate-17d805d41f2ff52d3446dfcdba9f933eb511d6a6`
  - `mobile-emulator-diagnostics-26259403194-1`
  - `worklink-android-homologation-*` ausente, conforme esperado enquanto variables/secrets de homologação não existem.
- Artifacts do run `26259983380`:
  - `worklink-android-test-candidate-5d2adb216e7eb6145fb9391f4921385a1e2709e1`
  - `mobile-emulator-diagnostics-26259983380-1`
  - `worklink-android-homologation-*` ausente, conforme esperado enquanto variables/secrets de homologação não existem.

## Bloqueio Atual

O repositório ainda não possui `WORKLINK_HOMOLOGATION_API_BASE_URL` como variable nem secret, `WORKLINK_HOMOLOGATION_ALLOWED_HOSTS`, `WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256` e também não possui os secrets de assinatura Android de homologação.

A keystore Android de homologação já foi gerada localmente em `artifacts/local-secrets/android-homologation/`, pasta ignorada pelo git.

Para gerar o APK versionado full-stack há duas rotas válidas:

1. Informar uma URL HTTPS pública/estável de backend de homologação, configurar allowlist, fingerprint, secrets de assinatura e executar o workflow manualmente com `homologation_api_base_url`.
2. Para teste rápido no Android físico, subir `make homologation-local-up` e gerar `make mobile-android-local-fullstack-candidate`; esse APK local é debug e não pode ser promovido como versão estável.

Scripts de apoio criados:

- `make generate-android-homologation-keystore`
- `WORKLINK_HOMOLOGATION_API_BASE_URL=https://... make configure-android-homologation-github-env`

## Critérios de Aceite

- [x] Existe uma história oficial rastreável para homologação mobile full-stack.
- [x] O projeto possui comando para preparar ambiente local de homologação com backend, banco e massa fake.
- [x] O Android possui build candidate full-stack com `API_BASE_URL` configurável em tempo de build.
- [x] A pipeline publica artifact Android de homologação quando a URL de backend estiver configurada.
- [x] A pasta `artifacts/homologation` documenta como versões estáveis devem ser guardadas no repositório.
- [x] Nenhum APK preview/offline pode ser registrado como versão estável de homologação full-stack.
- [x] Nenhum APK debug ou assinado com chave debug pode ser promovido como homologação estável.
- [x] O APK estável deve ser versionado como asset de GitHub Release, com checksum/metadados no git.
- [x] A promoção deve verificar o certificado real do APK antes de publicar o asset.
- [x] Existe runbook operacional para configurar variables/secrets no GitHub Actions.
- [x] Existe ADR e guia operacional para o Mobile Infra Specialist Agent apoiar o SRE em Android, iOS, emuladores, lojas, assinatura e custos.
- [x] O plano deixa explícito que iOS precisa validar o mesmo backend e a mesma massa antes de App Store.
- [ ] APK Android full-stack versionado foi gerado, publicado como asset de GitHub Release, promovido e registrado em `artifacts/homologation/releases/<versao>/android`.

## Log de Iterações (Ralph Loop)

### Iteração 1 — Retomada e materialização do loop

- Functional Test Discovery: detectados testes funcionais em `functional-tests/src/specs` usando Jest.
- Gates de CI já aprovados nos runs `26197769468` e `26198971069`.
- Bloqueio SRE registrado: ausência de URL/ambiente de homologação para gerar APK full-stack versionado.
- Ambiente local verificado:
  - `docker`: disponível via Docker Desktop/`docker.exe`.
  - `flutter`: indisponível diretamente no WSL atual.

### Iteração 2 — Correções de segurança e promoção

- Security Specialist reprovou promoção de APK debug, chave debug, URL sem validação e APK binário dentro do git.
- QA confirmou falha no script de promoção por uso de `gh run view --json artifacts`, incompatível com a CLI atual.
- Ação em andamento:
  - `mobile-android-homologation-candidate` passa a exigir HTTPS, host público/allowlist e assinatura de homologação.
  - Promotion passa a descobrir artifacts via GitHub API e registrar apenas metadados/checksum no git.
  - APK estável passa a ser asset do GitHub Release da tag semântica.
  - Criado candidato local full-stack debug separado para teste rápido no Android físico, sem promoção.
- Security Specialist rejeitou a primeira correção por allowlist opcional, parser frágil de URL e validação baseada só em metadados.
- Correções adicionais:
  - allowlist `WORKLINK_HOMOLOGATION_ALLOWED_HOSTS` passou a ser obrigatória.
  - parser de URL passou a usar `urllib.parse` e `ipaddress`, rejeitando IPv6/IPs locais/privados.
  - promoção passou a exigir `apksigner` e comparar fingerprint real com `WORKLINK_ANDROID_HOMOLOGATION_CERT_SHA256`.
- Terceira revisão de Segurança aprovou:
  - promoção revalida `api_base_url` contra allowlist;
  - upload não falha quando o asset usa o nome padrão;
  - APK permanece fora do git, com metadados/checksum/ponteiro versionados.

### Iteração 3 — Operacionalização das variáveis e secrets

- Usuário autorizou criar história nova se necessário, mas a fila oficial ainda bloqueia nova história enquanto WLT-029 está em Doing.
- Decisão: continuar dentro da WLT-029 e criar automação operacional para o bloqueio atual.
- Criados scripts para:
  - gerar keystore Android de homologação local e não versionada;
  - configurar variables/secrets no GitHub via `gh`.
- Criado runbook em `docs/operacao/homologacao-android-github-actions.md`.

### Iteração 4 — CI verde após automação de secrets

- Run GitHub Actions `26253710509` concluído com sucesso no commit `6b3c100e5490befd0b7df743bae7ed5f45f91d51`.
- Jobs aprovados:
  - `API Docker image`
  - `Dependency scan`
  - `Mobile integration on Android emulator`
  - `Backend quality gates`
  - `Mobile quality gates`
- Artifacts gerados:
  - `worklink-android-test-candidate-6b3c100e5490befd0b7df743bae7ed5f45f91d51`
  - `mobile-emulator-diagnostics-26253710509-1`
- Artifact `worklink-android-homologation-*` não foi gerado porque o repositório ainda não possui variables/secrets de homologação, comportamento esperado e seguro.

### Iteração 5 — Redução do bloqueio de keytool local

- `scripts/generate_android_homologation_keystore.sh` passou a operar em modo `auto`, `local` ou `docker`.
- Quando `keytool` local não existe, o modo `auto` tenta usar Docker com a imagem `eclipse-temurin:21-jdk`.
- Runbook atualizado para documentar o fallback Docker/JDK.
- Validações:
  - `sh -n` nos scripts de homologação.
  - `make -n generate-android-homologation-keystore`.
  - `make -n configure-android-homologation-github-env`.
  - fluxo fake com `keytool` local.
  - fluxo fake com Docker/JDK.
  - `scripts/check_no_mobile_signing_secrets.sh`.
- Limite remanescente: ainda é necessária uma URL HTTPS pública de backend de homologação antes de configurar as variables/secrets e gerar o APK `worklink-android-homologation-*`.

### Iteração 6 — CI verde do fallback Docker/JDK

- Commit `17d805d41f2ff52d3446dfcdba9f933eb511d6a6` enviado para `origin/main`.
- Run GitHub Actions `26259403194` concluído com sucesso.
- Jobs aprovados:
  - `API Docker image`
  - `Dependency scan`
  - `Mobile integration on Android emulator`
  - `Backend quality gates`
  - `Mobile quality gates`
- Artifacts gerados:
  - `worklink-android-test-candidate-17d805d41f2ff52d3446dfcdba9f933eb511d6a6`
  - `mobile-emulator-diagnostics-26259403194-1`
- Passos `Prepare Android homologation candidate` e `Upload Android homologation candidate` permaneceram pulados por falta de URL/secrets, comportamento esperado.

### Iteração 7 — Keystore local gerada

- Executado `DOCKER=docker.exe WORKLINK_ANDROID_HOMOLOGATION_KEYTOOL_MODE=docker make generate-android-homologation-keystore`.
- Arquivos locais e não versionados gerados:
  - `artifacts/local-secrets/android-homologation/homologation-upload.jks`
  - `artifacts/local-secrets/android-homologation/github-secrets.env`
- Fingerprint SHA-256 público da keystore gerada:
  - `fff1b9ba121d85805d3a92ba11441a43e62be9a30531dd8c63166828878763ea`
- Validações:
  - `sh -n scripts/generate_android_homologation_keystore.sh`
  - `scripts/check_no_mobile_signing_secrets.sh`
  - `git diff --check`
- Limite remanescente: informar uma URL HTTPS pública do backend de homologação para configurar GitHub Actions.

### Iteração 8 — CI verde após correção WSL/docker.exe

- Commit `5d2adb216e7eb6145fb9391f4921385a1e2709e1` enviado para `origin/main`.
- Run GitHub Actions `26259983380` concluído com sucesso.
- Jobs aprovados:
  - `Dependency scan`
  - `Mobile integration on Android emulator`
  - `API Docker image`
  - `Backend quality gates`
  - `Mobile quality gates`
- Artifacts gerados:
  - `worklink-android-test-candidate-5d2adb216e7eb6145fb9391f4921385a1e2709e1`
  - `mobile-emulator-diagnostics-26259983380-1`
- Artifact `worklink-android-homologation-*` segue ausente por falta da URL/secrets no GitHub Actions, comportamento esperado.

### Iteração 9 — Parceiro Mobile Infra Specialist do SRE

- Criado `.agents/skills/skills/ralph-loop/mobile-infra-specialist-agent/SKILL.md`.
- Atualizado `.agents/skills/skills/ralph-loop/sre-agent/SKILL.md` para exigir consulta ao parceiro quando houver Android, iOS, emuladores, assinatura, lojas, homologacao mobile, artifact governance mobile ou custo de CI/CD mobile.
- Atualizado `.agents/skills/skills/ralph-loop/SKILL.md` para registrar o parceiro no mapa de skills auxiliares.
- Criado `docs/adrs/ADR-0005-estrategia-infra-mobile-homologacao-release.md`.
- Criado `docs/operacao/guia-infra-mobile-homologacao-release.md`.
- Atualizado `docs/release/release-mobile.md`.
- Atualizada a historia `docs/jira-pessoal/historias-tecnicas/WLT-029-homologacao-mobile-fullstack-artifacts.md`.
- Decisao: manter abordagem progressiva. Automatizar Android no GitHub Actions Linux agora; adiar macOS/TestFlight/device farm ate haver necessidade real ou proximidade de loja.

## Aprendizados do Loop

- APK preview/offline é útil para navegação inicial, mas não pode virar evidência de homologação.
- O build full-stack não precisa que o backend esteja acessível pelo GitHub Actions durante o build; ele precisa embutir uma URL que o celular consiga acessar durante o teste manual.
- Se a URL for de rede local, o Android físico precisa estar na mesma rede e o backend precisa estar exposto fora do WSL, mas esse build é apenas local/debug.
- Homologação estável precisa de backend HTTPS público/permitido e assinatura controlada.
