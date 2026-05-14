# WL-023 — Revisão administrativa efetiva de denúncias e avaliações

**Story**: [WL-023-revisao-administrativa-moderacao.md](../../jira-pessoal/historias/WL-023-revisao-administrativa-moderacao.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Adicionar fluxo administrativo mínimo de moderação para denúncias e contestações de avaliações, com persistência de status, decisão, auditoria e reflexo na exibição pública das avaliações.

## Escopo

- Backend administrativo ganha endpoints de moderação para denúncias e contestações.
- Denúncias e contestações passam a armazenar status, decisão, notas e data da decisão.
- Avaliações contestadas podem ser ocultadas da listagem pública.
- Auditoria sensível registra cada decisão administrativa.

## Fora do Escopo

- Interface administrativa dedicada.
- Mediação humana completa.
- Automação por IA.

## Plano

### Fase 1 — Modelo e persistência

- [x] Criar migração para status e decisão de moderação.
- [x] Atualizar domínio e adaptadores JDBC.
- [x] Garantir filtro de avaliações ocultadas na vitrine pública.

### Fase 2 — Casos de uso e API

- [x] Implementar casos de uso de moderação.
- [x] Expor endpoints administrativos de decisão.
- [x] Auditar decisões sensíveis.

### Fase 3 — Gates

- [x] Atualizar testes unitários e web.
- [x] Executar backend unitário com cobertura mínima.
- [x] Executar backend integração/verify.

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
