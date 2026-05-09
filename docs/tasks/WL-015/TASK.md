# WL-015 — Perfil do usuário cliente

## História

Como usuário cliente, quero visualizar e gerenciar dados básicos da minha conta, cidades selecionadas, profissionais
salvos, avaliações enviadas, preferências básicas, privacidade e sair da conta.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-015-perfil-usuario.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/prototipos-de-tela/tela-perfil-do-cliente-usuario.png`

## Critérios de aceite

- [x] Usuário autenticado deve visualizar perfil.
- [x] Usuário deve visualizar cidades selecionadas.
- [x] Usuário deve visualizar profissionais salvos.
- [x] Usuário deve visualizar avaliações enviadas.
- [x] Usuário deve gerenciar preferências básicas.
- [x] Usuário deve conseguir sair da conta.

## Escopo técnico

- Criar modelo mobile do perfil mínimo do cliente com dados pessoais minimizados.
- Criar controller mobile para preferências básicas e logout.
- Criar tela mobile do perfil do cliente acessível a partir da descoberta.
- Exigir autenticação antes de abrir o perfil do cliente.
- Cobrir comportamento com testes unitários e testes de tela no padrão GIVEN/WHEN/THEN.

## Fora do escopo

- Preferências avançadas.
- Histórico financeiro.
- Integração HTTP real do perfil do cliente.
- Painel administrativo ou gestão complexa de privacidade.

## Evidências

- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, 71 testes e cobertura 96,18%.
- `make mobile-screen-test`: PASS, 53 testes.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-unit-test`: PASS, 226 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v014`.
- `make backend-image-build`: PASS.
