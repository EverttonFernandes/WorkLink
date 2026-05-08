# WL-005 — Perfil público detalhado do profissional

## Resultado

Entrega do perfil público mobile do profissional, acessível a partir da listagem. A tela apresenta dados principais, cidade base, cidades atendidas, descrição, serviços, links úteis, portfólio textual, badges, disponibilidade, resumo de avaliações quando existente, aviso de que completude não garante qualidade, contato e denúncia por callbacks.

## Escopo entregue

- Modelo `ProfessionalProfile` com campos opcionais e regras de visibilidade.
- Tela `ProfessionalProfileScreen` com renderização condicional de seções vazias.
- Navegação da listagem para o perfil público no `WorkLinkApp`.
- Testes unitários BDD/TDD para campos derivados e seções opcionais.
- Testes de tela BDD/TDD para perfil completo, perfil mínimo, contato e denúncia.
- Teste de navegação do app da listagem para o perfil.
- Normalização de formatação/lint mobile exigida pelo gate estático.

## Fora do escopo mantido

- Storage real de fotos e portfólio.
- WhatsApp real, autenticação e rastreabilidade de contato.
- Denúncia persistida e auditoria.
- Avaliações reais persistidas.

## Validações

- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura 100.00%
- `make mobile-screen-test`: PASS
- `make backend-static-analysis`: PASS
- `make backend-unit-test`: PASS, 71 testes, JaCoCo PASS
- `make backend-integration-test`: PASS
- `make mobile-integration-test`: N/A sem Android Emulator, iOS Simulator ou Chrome
- `make functional-test`: N/A sem cenários funcionais reais

## Versionamento

- Tipo semântico: MINOR
- Tag planejada: `v0.14.0`
