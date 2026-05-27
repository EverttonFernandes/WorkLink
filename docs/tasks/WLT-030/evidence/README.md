# Evidencias visuais da WLT-030

Esta pasta concentra as evidencias coletadas para a historia `WLT-030`.

## Status atual

- `generated/`: evidencias visuais geradas por `flutter test --update-goldens`
  a partir das telas Flutter revisadas.
- Estas imagens ajudam a auditar aderencia visual de forma reprodutivel no
  ambiente local mesmo quando o preview web dockerizado ou o emulador nao estao
  disponiveis.
- Elas **nao substituem** completamente a homologacao manual em APK/emulador,
  portanto servem como evidencia provisoria forte para QA e produto.

## Arquivos gerados

- `01-auth-phone-entry.png`
- `02-auth-verification.png`
- `03-city-selection.png`
- `04-discovery-results.png`
- `05-discovery-empty-state.png`
- `06-professional-profile.png`
- `07-professional-registration.png`
- `08-customer-profile.png`
- `09-professional-contact.png`
- `10-post-contact-feedback.png`
- `11-professional-review.png`
- `12-professional-review-success.png`
- `13-professional-report.png`

## Como regenerar

```bash
./scripts/capture_wlt_030_visual_evidence.sh
```
