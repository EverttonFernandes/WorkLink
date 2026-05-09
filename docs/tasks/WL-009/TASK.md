# WL-009 — Autenticação simplificada do cliente por telefone

## História

Como usuário cliente, quero navegar sem login e autenticar por telefone somente antes de contato ou ação sensível, para
descobrir profissionais sem fricção e gerar rastreabilidade quando necessário.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-009-autenticacao-cliente-telefone.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/prototipos-de-tela/tela-login-autenticacao.png`
- `docs/prototipos-de-tela/tela-verificao-usuario-cliente-profissional.png`

## Critérios de aceite

- [x] Usuário deve navegar e buscar sem login.
- [x] Ao tentar contato, usuário não autenticado deve ser direcionado para autenticação.
- [x] Telefone verificado existente deve realizar login.
- [x] Telefone verificado novo deve criar conta automaticamente.
- [x] Usuário deve conseguir reenviar código e alterar telefone informado.

## Escopo técnico

- Adicionar fluxo mobile de autenticação por telefone e verificação de código.
- Bloquear contato sensível quando não houver sessão autenticada.
- Preservar navegação e descoberta pública sem login.
- Reutilizar endpoints e use cases backend de autenticação já existentes.
- Cobrir fluxo com testes unitários e de tela no padrão GIVEN/WHEN/THEN.

## Fora do escopo

- Login social.
- Cadastro complexo de usuário cliente.
- WhatsApp real ou criação de intenção de contato.
- Integração real com provedor SMS/OTP.

## Evidências

- `make backend-unit-test`: PASS, 173 testes e coverage aprovado.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 99,26%.
- `make mobile-screen-test`: PASS.
- `make mobile-integration-test`: N/A por ausência de device/browser.
- `make functional-test`: N/A por ausência de cenários reais.
