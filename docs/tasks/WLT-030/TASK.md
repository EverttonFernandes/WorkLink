# WLT-030 — Aderência visual aos protótipos mobile

## História

Como dono do produto, quero que as telas mobile do WorkLink respeitem fielmente os protótipos oficiais, para que o APK
de homologação represente o produto real antes de qualquer avanço em publicação, TestFlight ou Play Store.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-030-aderencia-visual-prototipos-mobile.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md`
- `docs/jira-pessoal/PLANO-REVISAO-REQUISITOS-FUNCIONAIS-TELAS.md`
- `docs/debitos-tecnicos/DEBITOS-HOMOLOGACAO-MOBILE-2026-05-22.md`

## Critérios de aceite

- [ ] Existe matriz de aderência para cada tela mobile revisada.
- [ ] Cada tela revisada possui screenshot real do APK/emulador.
- [ ] O Mobile Front-end Specialist emite veredito `APPROVED`.
- [ ] QA valida `mobile_tests = PASS` para aderência visual/produto.
- [ ] Final Reviewer emite `Product/Prototype Fit = OK`.

## Escopo técnico

- Auditar as telas Flutter ativas contra o mapa oficial de protótipos.
- Levantar divergências visuais, de microcopy, composição, navegação e estados principais.
- Corrigir o tema base do aplicativo para abandonar a aparência Material genérica.
- Registrar evidências visuais e matriz tela/protótipo/screenshot no fluxo do Ralph Loop.
- Preparar o terreno para um novo APK de homologação visualmente confiável.

## Fora do escopo

- Publicação em Play Store ou TestFlight.
- Correção da massa regional de homologação, tratada em `WLT-032`.
- Decisão final do canal de OTP, tratada em `WLT-033`.

## Evidências esperadas

- Screenshots reais do APK/emulador por tela revisada.
- Referência explícita ao protótipo correspondente em `docs/prototipos-de-tela/`.
- Testes/widget tests ajustados quando a UI revisada alterar comportamento importante.
