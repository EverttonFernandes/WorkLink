# WLT-039 — Android AAB e Play Store Internal Testing

## Objetivo

Preparar o build Android em formato AAB e publicar o WorkLink em trilhas de teste da Google Play antes da produção
pública.

## Valor técnico

A Play Store usa Android App Bundle como formato principal. Esta história transforma o APK interno em um fluxo oficial de loja, com assinatura correta, metadados, trilha de teste e validação manual.

## Decisão fechada

- Play Store é a primeira loja-alvo.
- O build de loja deve apontar para a API cloud estável.
- Produção pública só pode acontecer após teste interno aprovado pelo dono do produto.

## Escopo incluído

- Configurar build `flutter build appbundle --release`.
- Configurar `API_BASE_URL` de produção controlada.
- Configurar assinatura Android compatível com Play App Signing.
- Criar workflow GitHub Actions para gerar AAB.
- Registrar checksum e metadados do AAB.
- Preparar artifact e checklist para upload manual em `Internal testing`.
- Documentar passos no Google Play Console para continuação operacional.
- Definir checklist de aprovação antes de liberar produção.

## Fora do escopo

- Upload manual na Play Console.
- Execução do `Internal testing` pelo dono do produto.
- Execução do `Closed testing` com testers reais.
- Publicação pública em produção.
- Campanha de marketing.
- iOS/TestFlight.
- Web/PWA.

## Critérios de aceite

- AAB release gerado pela CI.
- AAB aponta para API HTTPS estável.
- Assinatura de loja documentada.
- Artifact é rastreável por commit/tag.
- Checklist manual da Play Console criado e apontando para a continuação operacional.
- Bloqueio explícito se backend, autenticação ou políticas estiverem incompletos.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: habilita o primeiro caminho real para Play Store.
