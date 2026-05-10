# Entrega WLT-019 — Specs funcionais E2E reais

## Identificador

- História: `WLT-019`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Implementar suite de testes E2E reais que validem jornadas críticas do usuário (descoberta, contato, avaliação) contra API backend em ambiente controlado.

## Contexto

Após todas as histórias WL-001 a WL-024 estarem implementadas, testes E2E garantem que integração entre mobile e backend funciona em cenários de negócio reais, não apenas unitários.

## Requisitos técnicos atendidos

- RF (todos os fluxos críticos) — Cobertura E2E.
- RN01/RN02 — Segurança, autenticação em fluxos.
- RN09/RN10 — Rastreabilidade de avaliação.

## O que foi implementado

- Suite de testes E2E em `functional-tests/`:
  - **Descoberta**: busca por cidade, filtro por categoria, click em profissional.
  - **Autenticação**: login por telefone, OTP, erro de código.
  - **Contato**: iniciar contato, validação de intenção de contato persistida.
  - **Avaliação**: submeter avaliação anônima, validar persistência e rastreabilidade.
  - **Admin**: revisão de denúncia, validação, marcação em auditoria.

- Cenários em Jest/Playwright:
  - Happy path por fluxo crítico.
  - Validações de erro (telefone inválido, código expirado, permissões insuficientes).
  - Rastreabilidade (verificar auditoria após ação sensível).

- Relatório de cobertura de casos de teste.
- Integração em CI/CD: `make functional-test` testa contra backend real (via Docker Compose).

## O que não foi implementado

- Testes de carga/stress.
- Casos de fluxo alternativo (ex: cliente muda de cidade durante busca).
- Mobile E2E real (Appium, Driver etc) — apenas server-side validado.

## Fluxos, telas, endpoints ou módulos envolvidos

- Testes em `functional-tests/src/`.
- Endpoints backend de descoberta, autenticação, contato, avaliação, admin.
- Database real PostgreSQL e storage MinIO em `docker-compose.yml`.

## Estratégia de testes

- Setup: Docker Compose com backend, DB, MinIO.
- Execução: Playwright/Jest contra endpoints reais.
- Validação: status HTTP, respostas esperadas, auditoria.
- Limpeza: truncate de tabelas após cada cenário.

## Evidências de validação

- `make functional-test`: Todos os cenários E2E PASS (min 45 testes).
- Relatório html com evidência: `functional-tests/coverage/e2e-report.html`.
- CI/CD executa E2E em push e pull request.

## Riscos ou limitações remanescentes

- Testes dependem de estado do banco (requer limpeza rigorosa entre cenários).
- Sem teste de concorrência (múltiplos clientes simultâneos).
- Cenários de falha de rede simulada não estão incluídos.

## Arquivos ou módulos relevantes

- `functional-tests/` — suite E2E.
- `functional-tests/src/specs/` — casos de teste por fluxo.
- `.github/workflows/ci.yml` — job de E2E no CI/CD.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona validação sem mudança de código produção. Necessária antes de qualquer publicação em lojas.
