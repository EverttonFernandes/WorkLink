# Entrega WLT-019 — Specs funcionais E2E reais

## Identificador

- História: `WLT-019`
- Data: `2026-05-15`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Implementar suite funcional HTTP real que valide jornadas criticas do WorkLink V1 contra a API backend em ambiente Docker reproduzivel.

## Contexto

O projeto ja possuia infraestrutura para testes funcionais, mas sem specs reais. A entrega fecha esse gap com cenarios caixa-preta que exercitam autenticacao, descoberta, contato, pos-contato, avaliacao, denuncia e bloqueios de autorizacao sem depender de detalhes internos do backend.

## Requisitos técnicos atendidos

- RF dos fluxos criticos da V1 com validacao funcional de ponta a ponta por HTTP.
- RN de ambiente reproduzivel e automacao em container.
- RN de autenticacao, autorizacao, rastreabilidade e isolamento de dados entre clientes.

## O que foi implementado

- Suite funcional real em `functional-tests/src/specs/`:
  - `autenticacao-e-catalogo.spec.js`
  - `contato-e-pos-contato.spec.js`
  - `avaliacao-e-denuncia.spec.js`
  - `autorizacao-e-bloqueios.spec.js`
- Helpers de suporte em `functional-tests/src/support/` para:
  - bootstrap de sessao autenticada
  - criacao de massa deterministica
  - reset de estado entre cenarios
- Endpoint local de suporte funcional para reset deterministico do banco.
- OTP previsivel por configuracao de ambiente apenas para o profile local de testes.
- Ajuste do `make functional-test` para subir dependencias, aplicar migracoes, construir a API e executar a suite dentro do container `functional-tests`.
- Correcoes em adaptadores JDBC que persistiam `Instant` sem `Timestamp`, quebrando cenarios reais.
- Correcao arquitetural para manter o suporte funcional aderente a Ports and Adapters.

## O que não foi implementado

- Testes de carga, resiliencia e concorrencia.
- E2E de interface mobile nativa.
- Casos de rede degradada e falhas externas simuladas.

## Fluxos, telas, endpoints ou módulos envolvidos

- `functional-tests/src/specs/`
- `functional-tests/src/support/`
- `worklink-api` com endpoints de autenticacao, catalogo, contato, avaliacao, denuncia e perfil privado
- `compose.yml`, `.env.example` e `Makefile`

## Estratégia de testes

- Setup: Docker Compose com PostgreSQL, Redis, MinIO e API.
- Execucao: Jest contra endpoints HTTP reais do backend.
- Validacao: status HTTP, contratos JSON, efeitos persistidos e regras de autorizacao.
- Limpeza: reset deterministico via endpoint local de suporte funcional.

## Evidências de validação

- `make backend-static-analysis`: PASS
- `make backend-unit-test`: PASS, `313` testes, cobertura minima `95%` atendida
- `make backend-integration-test`: PASS, Flyway ate `v021`
- `make functional-test`: PASS, `4` suites e `10` cenarios

## Riscos ou limitações remanescentes

- A suite depende de infraestrutura Docker funcional.
- Ainda nao cobre concorrencia ou caos de rede.
- O endpoint de reset existe apenas para ambiente local e deve permanecer fora de ambientes nao locais.

## Arquivos ou módulos relevantes

- `functional-tests/` — suite E2E.
- `functional-tests/src/specs/` — casos de teste por fluxo.
- `functional-tests/src/support/` — helpers e lifecycle deterministico.
- `worklink-api/src/main/java/br/com/worklink/api/testsupport/` — endpoint local de reset.
- `worklink-api/src/main/java/br/com/worklink/application/testsupport/` — use case e port do suporte funcional.
- `worklink-api/src/main/java/br/com/worklink/infrastructure/testsupport/` — adapter JDBC de reset.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona uma capacidade tecnica nova e obrigatoria ao projeto: validacao funcional real, reproduzivel e executavel na pipeline sem instalacao local.
