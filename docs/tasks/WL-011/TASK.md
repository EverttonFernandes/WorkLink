# WL-011 — Pós-contato estruturado

## História

Como usuário cliente, quero registrar o que aconteceu após iniciar contato com um profissional, para que o WorkLink
comece a medir responsividade e realização de serviço.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-011-pos-contato-estruturado.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/prototipos-de-tela/tela-falar-com-o-profissional.png`
- `docs/prototipos-de-tela/tela-avaliacao-profissional.png`

## Critérios de aceite

- [x] Feedback pós-contato só deve existir para contato previamente registrado.
- [x] Usuário deve informar se conseguiu falar.
- [x] Usuário deve informar responsividade percebida.
- [x] Usuário deve informar se serviço foi realizado.
- [x] Respostas devem ser armazenadas para sinais futuros.

## Escopo técnico

- Criar feedback pós-contato associado a uma intenção de contato existente.
- Garantir ownership: apenas o cliente da intenção pode registrar feedback.
- Armazenar contato realizado, responsividade percebida, serviço realizado e data.
- Criar tela/controller mobile para coletar as respostas estruturadas.
- Cobrir backend e mobile com testes no padrão GIVEN/WHEN/THEN.

## Fora do escopo

- Ranking algorítmico sofisticado.
- Mediação de conflito.
- Garantia de execução.

## Evidências

- `make backend-unit-test`: PASS, 192 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v011`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 97,91%.
- `make mobile-screen-test`: PASS, 37 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
