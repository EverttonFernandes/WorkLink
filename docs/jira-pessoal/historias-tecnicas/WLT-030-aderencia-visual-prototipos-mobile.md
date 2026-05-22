# WLT-030 — Aderência visual aos protótipos mobile

## Objetivo

Corrigir o débito `DTM-001`, garantindo que as telas mobile Android/iOS respeitem à risca os protótipos oficiais em `docs/prototipos-de-tela/`.

## Valor técnico e de produto

O APK atual instala, mas não representa visualmente o produto planejado. Esta história recoloca a identidade visual, hierarquia, composição, cards, botões, cores e estados principais sob controle de produto.

## Débito relacionado

- `DTM-001 — Aderência visual aos protótipos oficiais`

## Escopo incluído

- Auditar telas reais contra `docs/jira-pessoal/MAPA-PROTOTIPOS-TELAS.md`.
- Comparar screenshots do APK/emulador contra os protótipos oficiais.
- Corrigir a identidade visual base do app para abandonar aparência Material genérica/roxa.
- Garantir paleta, tipografia, espaçamentos, cards, botões e composição aderentes aos protótipos.
- Registrar matriz tela/protótipo/screenshot/status.
- Acionar `ralph-loop/mobile-frontend-specialist-agent` como gate obrigatório.

## Fora do escopo

- Criar funcionalidades novas fora dos RFs já mapeados.
- Publicar em Play Store ou TestFlight.
- Corrigir dados de homologação, coberto por WLT-032.

## Critérios de aceite

- Existe matriz de aderência para cada tela mobile revisada.
- Cada tela revisada possui screenshot real do APK/emulador.
- O Mobile Front-end Specialist emite veredito `APPROVED`.
- QA valida `mobile_tests = PASS` para aderência visual/produto.
- Final Reviewer emite `Product/Prototype Fit = OK`.

## Entrega versionável

- Tipo sugerido: `PATCH`
- Motivo: corrige aderência visual sem adicionar novo contrato funcional.
