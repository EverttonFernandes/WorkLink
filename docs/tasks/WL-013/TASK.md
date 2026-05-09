# WL-013 — Exibição de avaliações no perfil

## História

Como usuário cliente, quero consultar avaliações no perfil do profissional para decidir com mais confiança antes de
chamar pelo WhatsApp, sem que avaliações anônimas exponham identidade pública.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-013-exibicao-avaliacoes-perfil.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`
- `docs/prototipos-de-tela/tela-avaliacao-concluida.png`

## Critérios de aceite

- [x] Perfil deve exibir avaliações existentes.
- [x] Perfil deve exibir nota média quando houver dados.
- [x] Avaliação anônima deve aparecer sem identidade pública.
- [x] Comentários devem ser opcionais.
- [x] Profissional deve conseguir solicitar análise de avaliação indevida.

## Escopo técnico

- Criar projeção pública de avaliações do profissional.
- Calcular nota média e quantidade de avaliações sem ranking algorítmico.
- Expor comentários públicos sem autoria interna.
- Registrar solicitação de análise de avaliação pelo profissional.
- Evoluir tela mobile de perfil para resumo, lista de comentários e ação de análise.
- Cobrir backend e mobile com testes no padrão GIVEN/WHEN/THEN.

## Fora do escopo

- Moderação completa.
- Ranking sofisticado de reputação.
- Exposição de autoria interna.

## Evidências

- `make backend-unit-test`: PASS, 215 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v013`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 97,60%.
- `make mobile-screen-test`: PASS, 44 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
- `git diff --check`: PASS.
- Security diff scan: PASS.
