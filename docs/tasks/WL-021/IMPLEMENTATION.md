# WL-021 — Solicitação de feedback pós-contato

**Story**: [WL-021-solicitacao-pos-contato.md](../../jira-pessoal/historias/WL-021-solicitacao-pos-contato.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Criar pendências rastreáveis de feedback pós-contato e expô-las no app para que o cliente conclua ou dispense a solicitação.

## Escopo

- Backend registra e consulta pendências elegíveis de pós-contato.
- Backend evita duplicidade para contato já respondido ou dispensado.
- Mobile exibe solicitação ativa e direciona o cliente ao fluxo de feedback.
- Testes BDD/TDD no backend e no mobile.

## Fora do Escopo

- Push notification real.
- Campanhas automáticas de reengajamento.
- Motor de agendamento externo.

## Plano

### Fase 1 — Backend

- [x] Modelar pendência de solicitação de feedback.
- [x] Persistir criação/dispensa/conclusão sem duplicidade.
- [x] Expor endpoints autenticados para listar e concluir solicitações.

### Fase 2 — Mobile

- [x] Exibir pendência de feedback quando existir.
- [x] Direcionar para o fluxo de pós-contato pela solicitação.
- [x] Permitir dispensar a solicitação.

### Fase 3 — Gates

- [x] Backend unitário com cobertura 95%+.
- [x] Backend integração/verify.
- [x] Mobile unitário com cobertura 95%+.
- [x] Mobile screen tests.
- [x] Análise estática.

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

## Implementação realizada

- Migração `V020` criando `worklink.post_contact_feedback_requests` e retroalimentando pendências antigas.
- Criação automática da pendência no início do contato.
- Marcação da pendência como `ANSWERED` ao registrar pós-contato.
- Endpoint privado do cliente para listar pendências.
- Endpoint privado do cliente para dispensar pendência com auditoria.
- Prompt in-app no mobile, acima dos filtros da descoberta, reaproveitando a tela existente de pós-contato.

## Validações executadas

- `make backend-unit-test`: PASS
- `make backend-integration-test`: PASS
- `make mobile-unit-test`: PASS (`95.44%`)
- `make mobile-screen-test`: PASS
- `make mobile-static-analysis`: PASS
- `make mobile-integration-test`: PASS
