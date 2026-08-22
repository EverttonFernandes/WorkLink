# WLT-039 - Android AAB e Play Store Internal Testing

## Historia

Como dono do produto, quero gerar o Android App Bundle oficial da loja e preparar a trilha de teste interno da Play
Store, para validar o aplicativo pelo fluxo real de distribucao antes de qualquer liberacao publica.

## Fontes

- `docs/jira-pessoal/historias-tecnicas/WLT-039-android-aab-play-store-internal-testing.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/operacao/checklist-google-play-console.md`
- `docs/operacao/publicacao-lojas-mobile.md`
- `docs/operacao/mobile-secrets-assinatura.md`

## Aceite

- CI gera AAB release rastreavel.
- Build de loja aponta para API HTTPS estavel.
- Assinatura Android e Play App Signing ficam documentados.
- Internal Testing fica preparado com artifact e checklist manual completos.
- Bloqueios de backend/autenticacao/politicas ficam explicitados antes de producao.
