# WL-012 — Avaliação anônima com rastreabilidade interna

## História

Como usuário cliente, quero avaliar um profissional após serviço realizado, com opção de anonimato público, para
contribuir com reputação sem expor minha identidade em cidades pequenas.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-012-avaliacao-anonima-rastreavel.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/prototipos-de-tela/tela-avaliacao-profissional.png`
- `docs/prototipos-de-tela/tela-avaliacao-concluida.png`

## Critérios de aceite

- [x] Usuário só deve avaliar após contato registrado.
- [x] Usuário só deve avaliar se informar que serviço foi realizado.
- [x] Nota em estrelas deve ser obrigatória.
- [x] Comentário deve ser opcional.
- [x] Avaliação anônima não deve expor autoria publicamente.
- [x] Plataforma deve manter autoria interna rastreável.

## Escopo técnico

- Criar domínio e caso de uso para avaliação profissional.
- Validar contato existente, pós-contato existente e serviço realizado.
- Persistir autoria interna e projeção pública segura.
- Criar endpoint de registro da avaliação.
- Criar tela/controller mobile de avaliação.
- Cobrir backend e mobile com testes no padrão GIVEN/WHEN/THEN.

## Fora do escopo

- Moderação avançada.
- Ranking algorítmico.
- Exibição pública agregada de avaliações, que fica para `WL-013`.

## Evidências

- `make backend-unit-test`: PASS, 203 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v012`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 97,83%.
- `make mobile-screen-test`: PASS, 43 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
- `git diff --check`: PASS.
- Security diff scan: PASS.
