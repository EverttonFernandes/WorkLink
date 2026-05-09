# WL-010 — Contato via WhatsApp e intenção de contato

## História

Como usuário cliente autenticado, quero chamar o profissional via WhatsApp com aviso claro sobre negociação externa, para
iniciar contato sem que o WorkLink prometa execução ou garantia do serviço.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-010-contato-whatsapp-intencao.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/prototipos-de-tela/tela-falar-com-o-profissional.png`

## Critérios de aceite

- [ ] Usuário não autenticado não deve iniciar contato.
- [ ] Usuário autenticado deve conseguir iniciar contato via WhatsApp.
- [ ] Sistema deve registrar intenção de contato antes do redirecionamento.
- [ ] Tela de contato deve informar que a negociação ocorre fora do app.
- [ ] Tela de contato deve informar que o WorkLink não garante execução do serviço.

## Escopo técnico

- Criar intenção de contato no backend com cliente autenticado, profissional, WhatsApp e data de criação.
- Isolar a montagem do link WhatsApp em adapter, fora da regra de negócio.
- Persistir intenção antes de retornar o link de redirecionamento.
- Criar tela mobile de contato com avisos obrigatórios e tratamento de erro no redirecionamento.
- Cobrir backend e mobile com testes no padrão GIVEN/WHEN/THEN.

## Fora do escopo

- Chat interno.
- Pagamento.
- Contrato.
- Garantia de execução do serviço.

## Evidências

- `make backend-unit-test`: PASS, 182 testes e coverage aprovado.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v010`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 98,01%.
- `make mobile-screen-test`: PASS.
- `make mobile-integration-test`: N/A por ausência de device/browser.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
