# WL-018 — Verificação do telefone do profissional

**Story**: [WL-018-verificacao-telefone-profissional.md](../../jira-pessoal/historias/WL-018-verificacao-telefone-profissional.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Adicionar verificação de telefone/WhatsApp do profissional como sinal de confiança progressiva na V1, persistindo o status e expondo o badge nas telas de listagem e perfil.

## Escopo

- Backend persiste `phone_number_verified`.
- Backend expõe `phoneNumberVerified` no contrato público de profissionais.
- Backend oferece endpoints autenticados para solicitar e confirmar verificação.
- Mobile consome o novo campo e envia solicitação/confirmação pelo gateway/service.
- Testes BDD/TDD para domínio, aplicação, API, persistência e mobile.

## Fora do Escopo

- SMS real com provedor externo.
- KYC/documentoscopia.
- Garantia de qualidade do serviço.

## Plano

### Fase 1 — Backend

- [x] Migration para `phone_number_verified`.
- [x] Campo no domínio `Professional`.
- [x] Use cases para solicitar e confirmar verificação.
- [x] Endpoints autenticados com ownership e auditoria.
- [x] Contrato HTTP expondo `phoneNumberVerified`.

### Fase 2 — Mobile

- [x] Modelo `Professional` ler `phoneNumberVerified`.
- [x] Gateway mapear campo real para perfil/listagem.
- [x] Serviço mobile para solicitar e confirmar verificação.
- [x] Interface do gateway expor solicitação e confirmação para fluxo profissional autenticado.

### Fase 3 — Gates

- [x] Backend unitário com cobertura 95%+.
- [x] Backend integração/verify.
- [x] Mobile unitário com cobertura 95%+.
- [x] Mobile screen tests.
- [x] Análise estática.
- [x] Integração mobile x backend.
- [x] Segurança/arquitetura/final review.

## Estratégia de Código Limpo

- Nomes explícitos em domínio, use cases, DTOs e testes.
- Testes com nomes `GIVEN`, `WHEN`, `THEN`.
- Sem acoplar regra de negócio ao framework; controller apenas traduz HTTP.
- Portas e adaptadores mantêm isolamento de persistência e chamadas externas.

## Exit Bar

```yaml
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  mobile_tests: PASS
  coverage: PASS
  security: PASS
  sre: PASS
  arch_review: PASS
  final_review: PASS
```

## Evidências

- `make backend-unit-test`: PASS, 261 testes, Jacoco 95%+ atendido.
- `make backend-integration-test`: PASS, Flyway validado até `v017`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura unitária mobile `95.77%`.
- `make mobile-screen-test`: PASS.
- `make mobile-integration-test`: PASS para contrato HTTP; testes de device retornaram `N/A` por ausência de emulador/simulador.
- `make functional-test`: N/A, suíte funcional ainda sem cenários reais.
- `git diff --check`: PASS.
