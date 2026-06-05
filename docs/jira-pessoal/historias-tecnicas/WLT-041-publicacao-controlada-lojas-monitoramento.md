# WLT-041 — Publicação controlada nas lojas e monitoramento inicial

## Objetivo

Definir e executar a liberação controlada do WorkLink nas lojas, começando pela Play Store e preparando App Store, com monitoramento mínimo de estabilidade, uso e rollback.

## Valor técnico

Publicar na loja sem observabilidade mínima pode transformar a vitrine em risco. Esta história garante que a primeira versão pública seja liberada com critérios de bloqueio, acompanhamento e reação.

## Decisão fechada

- Play Store é a primeira publicação pública planejada.
- App Store entra depois de TestFlight aprovado.
- Web/PWA não é meta desta etapa.
- Backend cloud, autenticação real/controlada e dados mínimos precisam estar operacionais antes da liberação pública.

## Escopo incluído

- Definir critérios finais de go/no-go para Play Store.
- Definir trilha inicial: teste interno, teste fechado ou produção gradual.
- Preparar notas de versão.
- Validar política de privacidade e dados de segurança.
- Configurar monitoramento mínimo de API, logs e erros mobile.
- Definir canal de suporte.
- Definir plano de rollback/hotfix.
- Registrar versão, commit, AAB/IPA, loja e data de publicação.
- Documentar primeiros indicadores de sucesso: downloads, cadastros, contatos iniciados e feedbacks.

## Fora do escopo

- Marketing pago.
- Suporte 24x7.
- Automação completa de atendimento.
- Publicação simultânea obrigatória Android/iOS.
- Web/PWA.

## Critérios de aceite

- Checklist go/no-go aprovado.
- Versão de loja rastreada por tag/commit.
- Monitoramento mínimo ativo.
- Canal de suporte definido.
- Rollback/hotfix documentado.
- Primeira publicação controlada na Play Store executada ou bloqueios finais documentados.
- Plano para App Store mantido em sequência.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: fecha o ciclo de loja com controle operacional mínimo.
