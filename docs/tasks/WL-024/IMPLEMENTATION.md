# WL-024 — Console administrativo mínimo

**Story**: [WL-024-console-administrativo-minimo.md](../../jira-pessoal/historias/WL-024-console-administrativo-minimo.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Disponibilizar uma interface interna mínima para administradores usarem as capacidades administrativas já expostas pela API, sem criar um backoffice complexo fora do escopo da V1.

## Escopo

- Definir a experiência administrativa mínima no app atual.
- Integrar acesso administrativo real por configuração e token interno.
- Expor listagens e ações centrais de moderação, categorias e métricas.
- Validar o fluxo com testes unitários, widget e integração aplicáveis.

## Fora do Escopo

- Backoffice completo.
- Gestão avançada de usuários.
- Workflow jurídico.
- Dashboard executivo sofisticado.

## Plano

### Fase 1 — Descoberta e desenho

- [x] Mapear endpoints administrativos já disponíveis e gaps reais para a UI.
- [x] Definir navegação e composição mínima do console administrativo.
- [x] Confirmar como o perfil administrador será identificado no cliente.

### Fase 2 — Implementação

- [x] Implementar acesso restrito ao console administrativo.
- [x] Implementar operação mínima de profissionais, denúncias e avaliações contestadas.
- [x] Implementar gestão mínima de categorias e visualização de métricas.

### Fase 3 — Gates

- [x] Validar testes backend/mobile aplicáveis.
- [x] Validar autorização administrativa ponta a ponta.
- [x] Atualizar documentação da entrega.

## Decisões técnicas

- O console administrativo da V1 foi incorporado ao cliente existente como ferramenta interna, sem criar fluxo de autenticação administrativo novo nesta história.
- O `WorkLinkBackendGateway` passou a aceitar injeção opcional do cliente administrativo para preservar testabilidade e reduzir acoplamento direto com dependências externas.
- A autorização operacional ficou condicionada à habilitação por configuração e à presença de token administrativo interno.

## Validações executadas

- `make mobile-static-analysis`
- `make mobile-unit-test`
- `make mobile-screen-test`
- `make mobile-integration-test`
- `git diff --check`

## Exit Bar

```yaml
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  mobile_tests: PASS
  coverage: PASS
  security: PENDING
  sre: PENDING
  arch_review: PENDING
  final_review: PENDING
```
