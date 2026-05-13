# WL-019 — Portfólio e fotos de trabalhos do profissional

**Story**: [WL-019-portfolio-fotos-profissional.md](../../jira-pessoal/historias/WL-019-portfolio-fotos-profissional.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Adicionar portfólio estruturado ao perfil profissional, reutilizando o storage seguro existente e mantendo a exibição
pública limitada a metadados não sensíveis.

## Escopo

- Backend cria vínculo entre profissional e arquivo `PROFESSIONAL_PORTFOLIO`.
- Backend lista itens ativos no contrato público do profissional.
- Backend valida existência do profissional, finalidade pública do arquivo e limite simples de itens.
- Mobile consome a lista de itens de portfólio e exibe no perfil.
- Testes BDD/TDD para domínio/aplicação/API/persistência/mobile.

## Fora do Escopo

- Upload binário real no app.
- CDN produtiva.
- Edição/crop/reordenação avançada.
- Curadoria administrativa complexa.

## Plano

### Fase 1 — Backend

- [x] Migration para tabela de itens de portfólio.
- [x] Domínio `ProfessionalPortfolioItem`.
- [x] Ports e use cases para adicionar/listar portfólio.
- [x] Repository JDBC.
- [x] Endpoints autenticados com ownership para adicionar item.
- [x] Contrato público do profissional com itens ativos.

### Fase 2 — Mobile

- [x] Modelo `ProfessionalPortfolioItem`.
- [x] Service/gateway para adicionar item.
- [x] Perfil público renderizando portfólio estruturado.
- [x] Testes unitários e de tela.

### Fase 3 — Gates

- [x] Backend unitário com cobertura 95%+.
- [x] Backend integração/verify.
- [x] Mobile unitário com cobertura 95%+.
- [x] Mobile screen tests.
- [x] Análise estática.
- [x] Integração mobile x backend quando aplicável.
- [x] Segurança/arquitetura/final review.

## Estratégia de Código Limpo

- Manter regras de negócio em domínio/use cases, não em controller.
- Reutilizar `StoredFilePurpose.PROFESSIONAL_PORTFOLIO` para validação de tipo/tamanho.
- Não expor `storageObjectKey` em contratos públicos.
- Usar nomes explícitos e testes no padrão `GIVEN`, `WHEN`, `THEN`.

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
