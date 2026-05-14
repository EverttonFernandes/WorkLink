# WL-022 — Métricas funcionais detalhadas da V1

**Story**: [WL-022-metricas-funcionais-detalhadas.md](../../jira-pessoal/historias/WL-022-metricas-funcionais-detalhadas.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Expandir os agregados analíticos já existentes para cobrir descoberta, responsividade, reputação e saúde do catálogo com granularidade suficiente para operação e produto.

## Escopo

- Backend amplia consultas agregadas de métricas funcionais.
- Administração passa a receber novos indicadores sem habilitar ranking.
- Testes cobrem agregações, percentuais e contratos do endpoint administrativo.

## Fora do Escopo

- Ranking algorítmico.
- Dashboards externos.
- Recomendação baseada em IA.

## Plano

### Fase 1 — Backend

- [x] Identificar lacunas nas métricas atuais.
- [x] Expandir consultas/agregados de descoberta, responsividade e reputação.
- [x] Ajustar contrato administrativo das métricas.

### Fase 2 — Testes e contrato

- [x] Atualizar testes unitários e de infraestrutura.
- [x] Atualizar testes do endpoint administrativo.
- [x] Validar migrações e compatibilidade com dados existentes.

### Fase 3 — Gates

- [x] Backend unitário com cobertura 95%+.
- [x] Backend integração/verify.
- [x] Análise estática.

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
