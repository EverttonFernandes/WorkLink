# WLT-019 — Specs funcionais E2E reais

**Story**: [WLT-019-specs-funcionais-e2e-reais.md](../../jira-pessoal/historias-tecnicas/WLT-019-specs-funcionais-e2e-reais.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Implementar a suíte funcional/E2E real da API do WorkLink, executada em container Docker, cobrindo fluxos críticos e bloqueios de autorização.

## Escopo

- Suporte mínimo de ambiente para reset determinístico e OTP previsível em testes funcionais.
- Specs reais em `functional-tests/src/specs/`.
- Lifecycle e helpers para massa determinística e isolamento entre cenários.
- Ajuste do alvo `make functional-test` para subir migrações e API antes da suíte.

## Fora do Escopo

- Testes de UI mobile.
- Testes de performance.
- Testes acoplados a código Java.

## Plano

### Fase 1 — Suporte de execução

- [x] Garantir ambiente funcional reproduzível via Docker Compose.
- [x] Viabilizar autenticação E2E previsível sem instalação local.
- [x] Viabilizar reset/cleanup determinístico entre cenários.

### Fase 2 — Specs críticos

- [x] Cobrir autenticação, catálogo, profissional e busca.
- [x] Cobrir contato, pós-contato, avaliação e denúncia.
- [x] Cobrir bloqueios de autorização e profissional bloqueado fora da busca.

### Fase 3 — Gates

- [x] `make functional-test` deve executar specs reais.
- [x] Validar que a suite falha quando um fluxo quebra.
- [x] Atualizar documentação da entrega.

## Exit Bar

```yaml
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  mobile_tests: N/A
  coverage: PASS
  security: PASS
  sre: PASS
  arch_review: PASS
  final_review: PASS
```

## Evidencias finais

- `make backend-static-analysis`: PASS
- `make backend-unit-test`: PASS, `313` testes, coverage minima de `95%` atendida
- `make backend-integration-test`: PASS, Flyway ate `v021`
- `make functional-test`: PASS, `4` suites e `10` cenarios BDD

## Fechamento dos gates especializados

- `security`: endpoint de suporte funcional restrito ao profile `local`, sem exposicao para ambientes nao locais
- `sre`: execucao totalmente containerizada, com reset deterministico, OTP previsivel por env var e bootstrap reproduzivel via `make functional-test`
- `arch_review`: suporte funcional mantido em Ports and Adapters com controller -> use case -> port -> adapter
- `final_review`: criterios de aceite atendidos, documentacao sincronizada e validacoes finais executadas
