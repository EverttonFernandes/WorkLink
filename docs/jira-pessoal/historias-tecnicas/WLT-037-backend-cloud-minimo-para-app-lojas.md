# WLT-037 — Backend cloud mínimo para aplicativo nas lojas

## Objetivo

Provisionar um backend cloud mínimo, estável e de baixo custo para sustentar o aplicativo publicado na Play Store e futuramente na App Store.

## Valor técnico

Mesmo publicado nas lojas, o app precisa carregar cidades, categorias, profissionais, autenticação, avaliações, denúncias e perfis a partir de uma API viva. Esta história evita que o aplicativo publicado quebre por depender de túnel temporário, localhost ou ambiente manual.

## Decisão fechada

- O app das lojas deve apontar para uma API HTTPS estável.
- A nuvem inicial deve ser de baixo custo, mas não pode ser temporária.
- DigitalOcean permanece como opção preferencial para API e PostgreSQL, salvo decisão manual posterior.
- Web/PWA não é objetivo desta história.

## Responsável principal

- SRE e Mobile Infra, com ações manuais do Everton quando houver conta/billing/secrets.

## Escopo incluído

- Definir provedor cloud inicial para API e banco.
- Provisionar API Java/Spring.
- Provisionar PostgreSQL.
- Configurar migrations.
- Configurar variáveis e secrets de produção controlada.
- Configurar URL HTTPS estável para API.
- Configurar health/readiness.
- Definir seed inicial sem misturar massa fake com dados reais.
- Definir backup mínimo do banco.
- Documentar custo mensal inicial e limites aceitos.

## Fora do escopo

- Flutter Web/PWA.
- Alta disponibilidade avançada.
- Kubernetes.
- Multi-região.
- Storage definitivo de fotos, salvo se bloquear fluxo de loja.

## Critérios de aceite

- API responde em HTTPS estável.
- PostgreSQL cloud conectado e com migrations aplicadas.
- Health/readiness aprovados.
- App mobile consegue carregar dados reais da API cloud.
- Secrets não são versionados.
- Custo mensal inicial documentado.
- Procedimento de recuperação básica documentado.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: cria a base real para o app publicado funcionar.
