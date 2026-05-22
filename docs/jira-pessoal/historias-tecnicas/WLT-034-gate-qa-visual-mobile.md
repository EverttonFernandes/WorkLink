# WLT-034 — Gate de QA visual para homologação mobile

## Objetivo

Corrigir o débito `DTM-005`, tornando obrigatória a validação visual/produto antes de aprovar APK, IPA ou artifact de homologação manual.

## Valor técnico e de produto

A pipeline não pode aprovar uma versão mobile apenas por compilar e instalar. O gate precisa exigir evidência visual, matriz de protótipos e validação do Mobile Front-end Specialist.

## Débito relacionado

- `DTM-005 — Gate de QA visual inexistente ou insuficiente`

## Escopo incluído

- Formalizar checklist de QA visual por tela.
- Exigir screenshots reais do APK/emulador como evidência.
- Integrar o veredito do `ralph-loop/mobile-frontend-specialist-agent` ao gate `mobile_tests`.
- Documentar o padrão de evidências oficiais de homologação.
- Avaliar viabilidade de golden tests ou screenshot diff futuro sem bloquear correção manual inicial.

## Fora do escopo

- Automatizar 100% da comparação visual se isso gerar custo/tempo desproporcional agora.
- Publicação em lojas.

## Critérios de aceite

- QA possui checklist visual oficial para APK/IPA manual.
- `mobile_tests` não pode ser `PASS` sem evidência visual quando houver UI.
- O fluxo define onde registrar screenshots oficiais de validação.
- O gate diferencia artifact técnico, preview, homologação funcional e release candidate.

## Entrega versionável

- Tipo sugerido: `PATCH`
- Motivo: corrige governança de qualidade e reduz risco de regressão visual.
