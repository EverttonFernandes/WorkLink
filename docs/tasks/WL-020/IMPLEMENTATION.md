# WL-020 — Profissionais salvos e preferências persistentes do cliente

**Story**: [WL-020-profissionais-salvos-preferencias-persistentes.md](../../jira-pessoal/historias/WL-020-profissionais-salvos-preferencias-persistentes.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Persistir profissionais salvos e preferências básicas do cliente no backend, consumindo esses dados no perfil mobile.

## Escopo

- Backend salva/remove/lista profissionais salvos por cliente autenticado.
- Backend persiste preferências básicas do cliente.
- Mobile lê dados persistidos no perfil do cliente.
- Testes BDD/TDD para domínio/aplicação/API/persistência/mobile.

## Fora do Escopo

- Recomendações automáticas.
- Listas compartilhadas.
- Preferências avançadas de privacidade.
- Cache offline/sincronização complexa.

## Plano

### Fase 1 — Backend

- [x] Migration para salvos e preferências do cliente.
- [x] Domínio/use cases/ports para salvar, remover, listar e atualizar preferências.
- [x] Repository JDBC.
- [x] Endpoints autenticados com ownership de cliente.

### Fase 2 — Mobile

- [x] Models/services para perfil persistido.
- [x] Gateway usando backend em vez de dados fixos.
- [x] Perfil cliente renderizando salvos e preferências vindos da API.
- [x] Testes unitários/widget.

### Fase 3 — Gates

- [x] Backend unitário com cobertura 95%+.
- [x] Backend integração/verify.
- [x] Mobile unitário com cobertura 95%+.
- [x] Mobile screen tests.
- [x] Análise estática.
- [ ] Integração mobile x backend quando aplicável.

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

- `make backend-static-analysis`: PASS
- `make backend-unit-test`: PASS
- `make backend-integration-test`: PASS, Flyway até `v019`
- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura `95.49%`
- `make mobile-screen-test`: PASS
