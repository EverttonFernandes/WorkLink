# Checklist DigitalOcean - backend cloud WorkLink

## Objetivo

Checklist manual para provisionar o backend cloud minimo da WLT-037 sem expor secrets no repositorio.

## Antes de criar recursos

- [ ] Confirmar que o custo minimo de aproximadamente US$ 12/mes, antes de impostos/cambio/adicionais, e aceitavel.
- [ ] Confirmar que SMS/WhatsApp pago segue desligado ate WLT-038.
- [ ] Confirmar que a conta DigitalOcean tem billing ativo.
- [ ] Confirmar que o GitHub esta conectado ao repositorio `EvertonFernandes/WorkLink`.

## Banco PostgreSQL

- [ ] Criar PostgreSQL persistente.
- [ ] Definir database do WorkLink.
- [ ] Criar usuario especifico para a API.
- [ ] Copiar connection string JDBC fora do Git.
- [ ] Confirmar SSL exigido quando disponivel.
- [ ] Confirmar backup automatico ou snapshot equivalente.

## App/API

- [ ] Criar App Platform app ou alternativa equivalente.
- [ ] Usar `docker/worklink-api.Dockerfile`.
- [ ] Definir porta HTTP `8080`.
- [ ] Definir health check `/actuator/health/readiness`.
- [ ] Manter auto-deploy desligado ate o primeiro ambiente estar validado.
- [ ] Configurar tamanho inicial `apps-s-1vcpu-0.5gb` se usar App Platform.

## Secrets e variaveis

- [ ] Configurar `WORKLINK_DATABASE_URL`.
- [ ] Configurar `WORKLINK_DATABASE_USERNAME`.
- [ ] Configurar `WORKLINK_DATABASE_PASSWORD`.
- [ ] Configurar `WORKLINK_JWT_SECRET`.
- [ ] Configurar `WORKLINK_ENCRYPTION_KEY`.
- [ ] Configurar `WORKLINK_OTP_SIGNING_SECRET`.
- [ ] Configurar `WORKLINK_SENSITIVE_VALUE_PEPPER`.
- [ ] Configurar `WORKLINK_FEATURE_SMS_ENABLED=false`.
- [ ] Configurar `WORKLINK_TEST_SUPPORT_FIXED_OTP` vazio para producao publica.
- [ ] Configurar demais variaveis documentadas em `docs/operacao/backend-cloud-lojas.md`.

## Migrations

- [ ] Exportar `WORKLINK_CLOUD_DATABASE_URL`.
- [ ] Exportar `WORKLINK_CLOUD_DATABASE_USERNAME`.
- [ ] Exportar `WORKLINK_CLOUD_DATABASE_PASSWORD`.
- [ ] Executar `make cloud-db-migrate`.
- [ ] Guardar apenas o resultado da execucao, nunca os valores.

## Validacao

- [ ] Confirmar URL HTTPS estavel da API.
- [ ] Executar `make cloud-api-readiness-check WORKLINK_CLOUD_API_BASE_URL=https://...`.
- [ ] Confirmar resposta `UP`.
- [ ] Registrar URL HTTPS aprovada em canal seguro de configuracao, nao no Git.
- [ ] Configurar build mobile futuro com `API_BASE_URL=https://...`.

## Bloqueio

Nao seguir para WLT-038/WLT-039 como publicacao de loja enquanto algum item acima estiver pendente.
