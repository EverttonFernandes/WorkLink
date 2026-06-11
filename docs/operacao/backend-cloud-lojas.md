# Backend cloud minimo para app nas lojas

## Objetivo

Garantir que o WorkLink publicado na Play Store/App Store consuma uma API HTTPS estavel, com PostgreSQL persistente,
migrations controladas, health checks e custo conhecido.

## Decisao atual

A decisao atual e seguir com estrategia **free-first**: hospedar a API e o banco em provedores com plano gratuito para
validar o produto antes de assumir custo mensal fixo.

DigitalOcean deixa de ser a opcao preferencial imediata e passa a ser rota de upgrade quando o app demonstrar tracao,
uso real ou receita.

## Caminhos avaliados

| Opcao | Vantagem | Risco | Uso recomendado |
| ----- | -------- | ----- | --------------- |
| Koyeb Free Instance + Supabase/Neon Free Postgres | Custo inicial zero e suporte a Docker/Spring Boot | Limites de memoria, pausa/limites do banco, sem SLA forte | Caminho preferencial para validacao inicial |
| Render Free + Supabase/Neon Free Postgres | Custo inicial zero e simples para API | Servico free pode dormir/reiniciar; latencia inicial | Alternativa se Koyeb nao funcionar |
| DigitalOcean App Platform + Managed PostgreSQL | Mais simples, HTTPS e deploy gerenciados | Custo mensal maior que uma VPS simples | Melhor para publicar com menos DevOps |
| DigitalOcean Droplet unica com Docker Compose | Menor custo fixo | Backups, HTTPS, updates e seguranca ficam sob nossa responsabilidade | Bom para validacao barata, com mais operacao manual |
| Tunnel temporario | Rapido para teste local | Quebra sem previsibilidade | Proibido para loja |

## Rota gratuita recomendada

1. Hospedar a API Java/Spring Boot no Koyeb Free Instance usando `docker/worklink-api.Dockerfile`.
2. Hospedar o PostgreSQL no Supabase Free ou Neon Free.
3. Manter `WORKLINK_FEATURE_SMS_ENABLED=false`.
4. Manter storage real desligado se nao for necessario no primeiro teste.
5. Validar `/actuator/health/readiness` pela URL HTTPS publica.
6. Migrar para DigitalOcean ou outro plano pago apenas quando houver validacao real.

## Limites aceitos no free tier

- Pode haver pausa, cold start, reinicio ou queda temporaria.
- Nao ha garantia forte de SLA.
- Banco gratuito tem limite de armazenamento e uso.
- Backups podem ser limitados ou ausentes no plano gratuito.
- Se a Play Store exigir teste fechado com usuarios reais e o free tier ficar instavel, o upgrade para plano pago volta a
  ser decisao de produto.

## Arquitetura minima

- API Java/Spring Boot containerizada.
- PostgreSQL persistente.
- HTTPS publico.
- Health readiness: `/actuator/health/readiness`.
- Health liveness: `/actuator/health/liveness`.
- Migrations via Flyway antes de apontar o app para o ambiente.
- Logs sem OTP, tokens ou secrets.

## Variaveis obrigatorias

| Nome | Tipo | Observacao |
| ---- | ---- | ---------- |
| `SPRING_PROFILES_ACTIVE` | variable | Usar `production` ou `homologation`, nao `local`. |
| `WORKLINK_DATABASE_URL` | secret | JDBC PostgreSQL da cloud. |
| `WORKLINK_DATABASE_USERNAME` | secret | Usuario do banco. |
| `WORKLINK_DATABASE_PASSWORD` | secret | Senha do banco. |
| `WORKLINK_REDIS_HOST` | variable | Redis/Valkey gerenciado ou placeholder ate remover dependencia. |
| `WORKLINK_REDIS_PORT` | variable | Porta Redis/Valkey. |
| `WORKLINK_REDIS_PASSWORD` | secret | Senha Redis/Valkey, quando usado. |
| `WORKLINK_STORAGE_ENDPOINT` | variable | Pendente se storage real ainda nao estiver ativo. |
| `WORKLINK_STORAGE_BUCKET` | variable | Bucket de storage. |
| `WORKLINK_STORAGE_ACCESS_KEY` | secret | Access key. |
| `WORKLINK_STORAGE_SECRET_KEY` | secret | Secret key. |
| `WORKLINK_JWT_SECRET` | secret | Minimo 32 caracteres fortes. |
| `WORKLINK_ACCESS_TOKEN_EXPIRATION_MINUTES` | variable | Sugestao inicial: `15`. |
| `WORKLINK_REFRESH_TOKEN_EXPIRATION_DAYS` | variable | Sugestao inicial: `30`. |
| `WORKLINK_OTP_EXPIRATION_MINUTES` | variable | Sugestao inicial: `5`. |
| `WORKLINK_PROFESSIONAL_PHONE_VERIFICATION_CODE` | secret | Desligar fixo em producao real quando houver provider. |
| `WORKLINK_PROFESSIONAL_PHONE_VERIFICATION_EXPIRATION_MINUTES` | variable | Sugestao inicial: `5`. |
| `WORKLINK_ENCRYPTION_KEY` | secret | Chave forte gerenciada fora do Git. |
| `WORKLINK_OTP_SIGNING_SECRET` | secret | Chave forte gerenciada fora do Git. |
| `WORKLINK_SENSITIVE_VALUE_PEPPER` | secret | Pepper forte gerenciado fora do Git. |
| `WORKLINK_SMS_PROVIDER_API_KEY` | secret | Placeholder ate WLT-038 fechar provedor/custo. |
| `WORKLINK_CORS_ALLOWED_ORIGINS` | variable | Restringir aos dominios reais. |
| `WORKLINK_FEATURE_SMS_ENABLED` | variable | `false` ate WLT-038 aprovar envio pago. |
| `WORKLINK_FEATURE_STORAGE_ENABLED` | variable | `false` se storage real nao estiver pronto. |
| `WORKLINK_TEST_SUPPORT_FIXED_OTP` | variable | Vazio em producao publica. |

## Deploy gratuito inicial - Koyeb + Supabase/Neon

### API no Koyeb

1. Criar conta no Koyeb.
2. Criar novo Web Service.
3. Conectar GitHub ao repositorio `EvertonFernandes/WorkLink`.
4. Selecionar branch `main`.
5. Selecionar deploy por Dockerfile.
6. Informar Dockerfile: `docker/worklink-api.Dockerfile`.
7. Informar porta HTTP: `8080`.
8. Configurar variaveis e secrets.
9. Deployar e copiar a URL HTTPS publica.
10. Validar readiness:

```bash
WORKLINK_CLOUD_API_BASE_URL=https://... \
make cloud-api-readiness-check
```

### Banco no Supabase ou Neon

1. Criar projeto gratuito.
2. Criar/usar database PostgreSQL.
3. Copiar connection string JDBC/URI.
4. Configurar `WORKLINK_DATABASE_URL`, `WORKLINK_DATABASE_USERNAME` e `WORKLINK_DATABASE_PASSWORD` no Koyeb.
5. Executar migrations com `make cloud-db-migrate`.

## Deploy pago futuro - DigitalOcean App Platform

Checklist manual complementar: `docs/operacao/checklist-digitalocean-backend-cloud.md`.

1. Criar app a partir do repositorio privado GitHub.
2. Usar `docker/worklink-api.Dockerfile`.
3. Configurar HTTP port `8080`.
4. Configurar health check em `/actuator/health/readiness`.
5. Criar PostgreSQL gerenciado ou informar banco externo.
6. Aplicar migrations com `make cloud-db-migrate`.
7. Configurar todas as variaveis/secrets.
8. Deployar API.
9. Validar `/actuator/health/readiness` via HTTPS.
10. Configurar o build mobile com `API_BASE_URL=https://...`.

## Validacao de API cloud

Depois do deploy, validar que a URL e estavel e que o readiness esta `UP`:

```bash
WORKLINK_CLOUD_API_BASE_URL=https://api.example.com \
make cloud-api-readiness-check
```

O gate rejeita HTTP, localhost, `127.0.0.1` e tunnels temporarios como `trycloudflare.com`.

## Migrations cloud

As migrations devem ser aplicadas antes de liberar o app mobile para testar a API cloud:

```bash
WORKLINK_CLOUD_DATABASE_URL=jdbc:postgresql://host:25060/database \
WORKLINK_CLOUD_DATABASE_USERNAME=usuario \
WORKLINK_CLOUD_DATABASE_PASSWORD=senha \
make cloud-db-migrate
```

Nunca commitar os valores reais.

## Teste de contrato local

Antes de fechar qualquer mudanca de deploy cloud, executar:

```bash
make cloud-deployment-contract-test
```

Esse teste valida que:

- migrations cloud falham cedo sem variaveis obrigatorias;
- URLs instaveis ou locais sao rejeitadas para loja;
- app spec usa um `instance_size_slug` atual da App Platform;
- chaves obrigatorias estao documentadas no app spec exemplo.

## Backup minimo

- Usar backup automatico do banco gerenciado quando contratado.
- Se usar Droplet, criar snapshot antes de migracoes destrutivas e backup periodico do PostgreSQL.
- Registrar data/hora do ultimo backup antes de publicar nova versao.

## Recuperacao basica

### Falha de deploy da API

1. Pausar promocao de novas versoes mobile.
2. Confirmar falha em `/actuator/health/readiness`.
3. Revisar logs do deploy no provedor sem expor secrets.
4. Reimplantar a ultima imagem/commit conhecido como saudavel.
5. Reexecutar `make cloud-api-readiness-check WORKLINK_CLOUD_API_BASE_URL=https://...`.
6. Registrar commit, horario, causa provavel e decisao de rollback/hotfix.

### Falha de migration

1. Nao apontar build mobile para a API cloud ate a migration estar concluida.
2. Confirmar que o backup/snapshot mais recente existe.
3. Revisar o erro do Flyway e identificar a migration exata.
4. Corrigir em nova migration forward-only quando possivel.
5. Evitar edicao retroativa de migration ja aplicada em ambiente compartilhado.
6. Reexecutar `make cloud-db-migrate`.

### Falha de banco

1. Validar status do banco no painel do provedor.
2. Confirmar credenciais e string JDBC fora do Git.
3. Se o banco gerenciado estiver indisponivel, abrir incidente no provedor e pausar rollout.
4. Se houver perda logica de dados, restaurar backup em ambiente separado antes de substituir producao.
5. Validar readiness, smoke test da API e app mobile antes de retomar publicacao.

### Falha do app publicado por API indisponivel

1. Pausar rollout na loja se a versao estiver em publicacao gradual.
2. Manter a API antiga online enquanto houver usuarios na versao anterior, quando possivel.
3. Publicar hotfix mobile apenas se a falha estiver no app; se a falha estiver na API, corrigir backend primeiro.
4. Comunicar canal de suporte definido na ficha da loja.

## Custo mensal inicial

Estimativa inicial para DigitalOcean App Platform, sujeita a cambio, impostos e revisao no painel antes de contratar:

| Item | Plano minimo considerado | Custo mensal documentado pela DigitalOcean |
| ---- | ------------------------ | ------------------------------------------ |
| API App Platform | `apps-s-1vcpu-0.5gb` | US$ 5,00 por mes |
| PostgreSQL development database | 512 MB | US$ 7,00 por mes |
| Total tecnico minimo | API + banco development | US$ 12,00 por mes, antes de impostos, cambio, trafego extra e servicos adicionais |

Fonte: documentacao oficial de App Platform Pricing e Managed Databases/PostgreSQL da DigitalOcean consultada em
2026-06-04.

Estimativa deve considerar:

- API/container sempre ligado.
- PostgreSQL persistente.
- Backup.
- Trafego.
- Logs/observabilidade.
- Eventual Redis/Valkey.

## Decisao de custo recomendada

- Comecar com App Platform pequena e banco development apenas se isso for suficiente para teste fechado.
- Nao ativar SMS/WhatsApp pago antes da WLT-038.
- Nao contratar Redis/Valkey, Spaces ou alta disponibilidade ate existir necessidade real.
- Se o custo ficar sensivel, considerar Droplet unica com Docker Compose como alternativa manual mais barata, aceitando
  maior carga operacional.

## Go/no-go para loja

O app nao pode ir para producao publica enquanto:

- a API nao responder via HTTPS estavel;
- o banco cloud nao estiver com migrations aplicadas;
- `WORKLINK_FEATURE_SMS_ENABLED` estiver ativo sem teto de custo da WLT-038;
- o app mobile nao tiver sido testado apontando para a URL cloud.
