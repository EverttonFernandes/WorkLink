# WL-016 — Administração mínima e moderação

## Resumo

Entrega do backend administrativo mínimo da V1 para acompanhamento de profissionais, bloqueio/desbloqueio, consulta de
denúncias, consulta de contestações de avaliações e métricas básicas.

## Valor entregue

- Administrador lista profissionais cadastrados, incluindo status de bloqueio.
- Administrador bloqueia e desbloqueia profissionais.
- Profissionais bloqueados deixam de aparecer na descoberta pública.
- Administrador consulta denúncias de profissionais.
- Administrador consulta solicitações de análise de avaliações.
- Administrador consulta métricas básicas de operação.
- Gestão de categorias permanece disponível pelo endpoint administrativo já existente.

## Escopo técnico

- Criada migração `V015__add_professional_blocking.sql`.
- Adicionado campo `blocked` ao domínio e persistência de profissionais.
- Criados casos de uso administrativos com portas de aplicação.
- Criado adapter JDBC administrativo.
- Criado controller administrativo em `/api/v1/admin`.
- Reforçada autorização por perfil `ADMINISTRATOR`.
- Registrada auditoria para acesso administrativo e bloqueio/desbloqueio.
- Adicionado tratamento HTTP 404 para recursos não encontrados.

## Fora do escopo

- Tela administrativa mobile/web, porque não há protótipo de tela administrativa no projeto.
- Workflow completo de decisão de denúncias e contestações.
- Moderação automatizada.

## Evidências de qualidade

- `make backend-static-analysis`: PASS.
- `make backend-unit-test`: PASS, 249 testes, cobertura mínima de 95% atendida.
- `make backend-integration-test`: PASS, Flyway até `v015`.
- `make backend-image-build`: PASS.
- `make functional-test`: N/A, ainda sem cenários reais.
- `git diff --check`: PASS.
- Varredura de segredos no diff adicionado: PASS.

## Versionamento

- Versão planejada: `v0.33.0`.
