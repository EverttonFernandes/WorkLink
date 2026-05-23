---
task_key: WLT-030
title: "Aderência visual aos protótipos mobile"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-030-aderencia-visual-prototipos-mobile.md"
official_order: 51
phase: EXECUTION
loop_iteration: 2
version_suggestion: PATCH
func_tests_detected: true
func_tests_path: "functional-tests/src/specs"
func_tests_framework: "jest"
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PENDING
  func_tests: PENDING
  mobile_tests: PASS
  coverage: PASS
  sonar: PENDING
  sre: PENDING
  security: PENDING
  arch_review: PENDING
  final_review: PENDING
metrics:
  unit_coverage_minimum: 95
  changed_files: 9
  risk_level: HIGH
release:
  commit_hash: ""
  semantic_tag: ""
correction_queue:
  - id: "WLT-030-MOBILE-001"
    origin: "mobile_frontend"
    severity: "CRITICAL"
    status: "DONE"
    description: "O app atual usa MaterialApp sem tema de produto consolidado, o que favorece aparência visual genérica e divergente dos protótipos oficiais."
  - id: "WLT-030-MOBILE-002"
    origin: "mobile_frontend"
    severity: "CRITICAL"
    status: "DONE"
    description: "As telas de descoberta, seleção de cidades e autenticação foram implementadas com estrutura utilitária básica e ainda não possuem matriz formal tela/protótipo/screenshot."
  - id: "WLT-030-PROCESS-001"
    origin: "product_manager"
    severity: "HIGH"
    status: "DONE"
    description: "A WLT-029 permanecia em Doing mesmo após a repriorização dos débitos; o Kanban foi ajustado para permitir a execução cronológica honesta da WLT-030."
  - id: "WLT-030-EVIDENCE-001"
    origin: "qa"
    severity: "HIGH"
    status: "OPEN"
    description: "Ainda faltam screenshots reais e veredito formal do mobile front-end specialist para fechar aderencia visual e homologacao manual."
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-030 iniciada como próxima história elegível após repriorização dos débitos de homologação mobile."
    evidence:
      - "docs/jira-pessoal/KANBAN-OFICIAL.md"
      - "docs/jira-pessoal/historias-tecnicas/WLT-030-aderencia-visual-prototipos-mobile.md"
      - "Functional Test Discovery: infraestrutura Jest detectada em functional-tests/src/specs."
      - "Leitura inicial das telas Flutter em worklink-mobile/lib/main.dart e features principais."
  - iteration: 1
    phase: EXECUTION
    summary: "Primeira rodada de correção visual aplicada ao foundation do app, autenticacao, selecao de cidades e descoberta."
    evidence:
      - "worklink-mobile/lib/main.dart"
      - "worklink-mobile/lib/features/customer_authentication/customer_authentication_screen.dart"
      - "worklink-mobile/lib/features/city_selection/city_selection_screen.dart"
      - "worklink-mobile/lib/features/discovery/discovery_screen.dart"
      - "worklink-mobile/test/widget/features/customer_authentication/customer_authentication_screen_test.dart"
      - "worklink-mobile/test/widget/features/city_selection/city_selection_screen_test.dart"
      - "worklink-mobile/test/widget/features/discovery/discovery_screen_test.dart"
  - iteration: 2
    phase: EXECUTION
    summary: "Segunda rodada de aderencia visual aplicada ao perfil profissional e cadastro; toolchain Flutter validada via Docker Desktop com analyze, unit tests, coverage e widget tests."
    evidence:
      - "worklink-mobile/lib/features/professional_profile/professional_profile_screen.dart"
      - "worklink-mobile/lib/features/professional_registration/professional_registration_screen.dart"
      - "worklink-mobile/lib/features/administrative_console/administrative_console_screen.dart"
      - "worklink-mobile/test/widget/features/professional_profile/professional_profile_screen_test.dart"
      - "worklink-mobile/test/widget/features/professional_registration/professional_registration_screen_test.dart"
      - "worklink-mobile/test/widget/features/administrative_console/administrative_console_screen_test.dart"
      - "worklink-mobile/test/widget/features/customer_authentication/customer_authentication_screen_test.dart"
      - "worklink-mobile/test/widget/features/discovery/discovery_screen_test.dart"
      - "worklink-mobile/test/widget/worklink_app_widget_test.dart"
      - "DOCKER=docker.exe make mobile-static-analysis"
      - "DOCKER=docker.exe make mobile-unit-test"
      - "DOCKER=docker.exe make mobile-screen-test"
---

# WLT-030 — Aderência visual aos protótipos mobile

## Contexto da história

O produto já conseguiu gerar APK de homologação manual, mas a validação humana mostrou que as telas atuais não
representam a identidade visual e a experiência previstas nos protótipos oficiais do WorkLink V1. A prioridade agora é
fechar essa lacuna antes de retomar a esteira de publicação.

## Objetivo de negócio da entrega atual

Garantir que o APK de homologação deixe de ser apenas "instalável" e passe a representar, visualmente e em jornada, o
produto que o dono da ideia pretende validar.

## Personas afetadas

- Dono do produto, que faz validação manual no Android físico.
- Usuário cliente, que navega descoberta, autenticação e perfil.
- Profissional prestador, representado pelas telas de perfil e cadastro.

## Requisitos relacionados

- RF03, RF04, RF05, RF06, RF07, RF08, RF09, RF10, RF11, RF12
- RF14, RF15, RF16, RF17
- RF18, RF19, RF20, RF21, RF22
- RF31, RF32, RF33, RF34, RF35
- RF40, RF41, RF42, RF43, RF44, RF45
- RF47, RF48, RF49, RF50, RF51, RF52
- RF53, RF54, RF55, RF56, RF57

## Escopo incluído

- Criar a matriz inicial de auditoria visual por tela.
- Identificar divergências entre protótipos e telas Flutter atuais.
- Consolidar o primeiro plano técnico para correção do tema e das telas críticas.
- Registrar quais telas podem ser corrigidas nesta história e quais dependem de histórias irmãs, como WLT-032 e WLT-033.

## Escopo explicitamente não incluído

- Deploy em lojas.
- Assinatura de produção.
- Alterações de massa regional, tratadas na WLT-032.
- Decisão do canal de OTP, tratada na WLT-033.

## Critérios de aceite verificáveis

- [ ] Existe matriz de aderência para cada tela mobile revisada.
- [ ] Cada tela revisada possui screenshot real do APK/emulador.
- [ ] O Mobile Front-end Specialist emite veredito `APPROVED`.
- [ ] QA valida `mobile_tests = PASS` para aderência visual/produto.
- [ ] Final Reviewer emite `Product/Prototype Fit = OK`.

## Estratégia técnica

1. Auditar o tema base em `worklink-mobile/lib/main.dart`.
2. Mapear as telas Flutter principais para seus protótipos oficiais.
3. Priorizar as telas de maior divergência percebida na homologação manual:
   descoberta, seleção de cidades, autenticação, perfil profissional e cadastro profissional.
4. Corrigir primeiro o foundation layer visual:
   tema, cores, tipografia, espaçamentos, componentes reutilizáveis.
5. Em seguida, atacar a composição de telas e os estados principais.

## Matriz inicial de aderência visual

| História | Protótipo oficial | Tela Flutter atual | Estado auditado | Status inicial | Divergência principal |
| --- | --- | --- | --- | --- | --- |
| WL-002 | `docs/prototipos-de-tela/tela-selecionar-cidades.png` | `worklink-mobile/lib/features/city_selection/city_selection_screen.dart` | seleção manual de cidades | FAIL | composição simples de lista e checkbox, sem hierarquia visual nem clima do protótipo |
| WL-003/WL-004 | `docs/prototipos-de-tela/tela-nenhum-profissional-encontrado.png` | `worklink-mobile/lib/features/discovery/discovery_screen.dart` | descoberta e estado vazio | FAIL | filtros e listagem utilitários, sem estrutura visual do produto e sem estado vazio aderente |
| WL-009 | `docs/prototipos-de-tela/tela-login-autenticacao.png` | `worklink-mobile/lib/features/customer_authentication/customer_authentication_screen.dart` | entrada de telefone e verificação de código | FAIL | tela utilitária, copy ainda genérica e sem construção visual compatível com o protótipo |
| WL-005 | `docs/prototipos-de-tela/tela-perfil-do-profissional.png` | `worklink-mobile/lib/features/professional_profile/professional_profile_screen.dart` | perfil público do profissional | PENDING | leitura inicial concluída, auditoria detalhada ainda pendente |
| WL-006 | `docs/prototipos-de-tela/tela-cadastro-do-profissional.png` | `worklink-mobile/lib/features/professional_registration/professional_registration_screen.dart` | cadastro progressivo | PENDING | leitura inicial concluída, auditoria detalhada ainda pendente |

## Camadas afetadas

- `worklink-mobile/lib/main.dart`
- `worklink-mobile/lib/features/discovery/`
- `worklink-mobile/lib/features/city_selection/`
- `worklink-mobile/lib/features/customer_authentication/`
- `worklink-mobile/lib/features/professional_profile/`
- `worklink-mobile/lib/features/professional_registration/`

## Estratégia de testes

- `flutter analyze`
- `flutter test`
- Widget tests das telas alteradas
- Revalidação do gate `mobile_tests`
- Evidência visual real por screenshot do APK/emulador

## Dados, privacidade e rastreabilidade

- Esta história não deve introduzir novos dados pessoais.
- Qualquer ajuste de copy em autenticação precisa permanecer coerente com segurança e privacidade.
- As evidências visuais devem ser rastreáveis por tela e por protótipo.

## Riscos e pontos de atenção

- O mapa de protótipos ainda possui lacunas para Home e listagem exclusiva.
- Ajustes visuais podem quebrar widget tests existentes.
- Algumas telas podem depender de massa regional mais rica para validação completa.
- O fluxo de autenticação visual depende da WLT-033 para ficar semanticamente fechado.

## Checklist de conclusão

- [ ] Kanban ajustado para execução cronológica honesta da WLT-030.
- [ ] Matriz inicial de auditoria registrada.
- [ ] Tema base visual revisado.
- [ ] Telas prioritárias corrigidas.
- [ ] Testes e evidências coletados.
- [ ] QA, Segurança, Arquitetura e Final Reviewer aprovados.

## Plano BDD/TDD

- Dado o protótipo oficial de uma tela, quando compararmos com a tela Flutter atual, então cada divergência material deve
  ser registrada com ação corretiva objetiva.
- Dado o aplicativo sem tema de produto consolidado, quando aplicarmos o foundation visual do WorkLink, então a aparência
  deve abandonar o padrão genérico e refletir a identidade prevista.
- Dado um novo screenshot de homologação, quando comparado ao protótipo, então QA e Mobile Front-end Specialist devem
  conseguir decidir `PASS` ou `FAIL` com evidência suficiente.

## Restrições pragmáticas e padrões

- Não reinventar a navegação do app fora do que já existe.
- Não misturar nesta história a correção da massa regional ou do canal de OTP.
- Não aprovar divergência visual sem decisão explícita de produto.
- Não expor labels técnicas, enums ou copy ambígua ao usuário final.

## Log de iterações

- Iteração 0: história iniciada, Kanban saneado para priorização dos débitos, functional test discovery confirmado em
  `functional-tests/src/specs`, leitura inicial do tema e das telas Flutter prioritárias concluída.
- Iteração 1: foundation visual do `MaterialApp` recebeu paleta verde, superfícies mais próximas do protótipo e
  componentes mais arredondados; autenticação, seleção de cidades e descoberta/estado vazio saíram do layout puramente
  utilitário para um primeiro desenho aderente ao produto.
- Iteração 2: perfil profissional e cadastro profissional receberam composição visual próxima aos protótipos oficiais;
  os widget tests quebrados foram saneados para o novo layout; `flutter analyze`, `mobile-unit-test` com cobertura
  `95.64%` e `mobile-screen-test` passaram via Docker.

## Aprendizados do loop

- O maior problema agora não é mais geração de artifact; é fidelidade de produto.
- O app já tem telas suficientes para uma auditoria útil, mesmo antes de refinar toda a fundação visual.
- O Kanban precisava refletir a realidade para o Ralph Loop não violar a própria regra cronológica.
- O projeto já consegue validar Flutter de forma isolada usando `docker.exe` + `docker compose`, sem instalar Flutter na
  máquina Windows hospedeira.
- Ajustes visuais profundos em telas mobile costumam exigir revisão paralela dos widget tests, especialmente quando a UI
  passa a ter mais de um `Scrollable` na mesma tela.
