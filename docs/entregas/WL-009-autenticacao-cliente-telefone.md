# Entrega WL-009 — Autenticação simplificada do cliente por telefone

## Identificador

- História: `WL-009`
- Data: `2026-05-09`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que o cliente descubra profissionais sem login inicial e só seja direcionado para autenticação quando tentar
contato ou outra ação sensível.

## Personas afetadas

- Usuário cliente: navega sem fricção e autentica por telefone no momento de contato.
- Profissional: passa a receber contato apenas após identificação mínima do cliente.
- Operação/segurança: mantém base de rastreabilidade para ações sensíveis futuras.

## Requisitos atendidos

- RF14 — Navegação sem autenticação inicial.
- RF15 — Autenticação somente antes de contato ou ação sensível.
- RF16 — Autenticação por telefone com código.
- RF17 — Criação automática de conta para telefone verificado ainda não cadastrado.
- RN01/RN02 — Segurança, autenticação e proteção contra enumeração.

## O que foi implementado

- Fluxo mobile de autenticação por telefone com entrada de número, verificação por código, reenvio e edição do telefone.
- Bloqueio de contato no perfil público quando o cliente ainda não está autenticado.
- Navegação e descoberta públicas preservadas sem login obrigatório.
- Feedback genérico para falha de código, sem enumeração de telefone.
- Teste backend garantindo que telefone verificado existente autentica sem duplicar conta.
- Testes mobile unitários e de tela para telefone válido, telefone inválido, código correto, código incorreto, reenvio e troca de telefone.

## O que não foi implementado

- Login social.
- Provedor real de SMS/OTP.
- WhatsApp real e intenção de contato persistida.
- Cadastro complexo de usuário cliente.

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela mobile de autenticação do cliente.
- Perfil público do profissional, ação `Chamar no WhatsApp`.
- Backend de autenticação já existente em `/api/v1/authentication`.
- Protótipos:
  - `docs/prototipos-de-tela/tela-login-autenticacao.png`
  - `docs/prototipos-de-tela/tela-verificao-usuario-cliente-profissional.png`

## Estratégia de testes

- Backend unitário: verificação de OTP para telefone existente sem duplicar conta.
- Mobile unitário: estado e controller da autenticação.
- Mobile tela: jornada de telefone, código, erro genérico, edição de telefone e bloqueio de contato sem sessão.
- Integração backend: suite completa com migrations.
- Funcional/E2E: N/A enquanto não houver cenários reais em `functional-tests`.

## Evidências de validação

- `make backend-unit-test`: PASS, 173 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v009`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 99,26%.
- `make mobile-screen-test`: PASS, 29 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.

## Riscos ou limitações remanescentes

- A tela ainda usa confirmação local simulada para a jornada; o adapter HTTP real deve ser conectado quando o app passar a consumir a API.
- A intenção de contato real será responsabilidade da WL-010.
- Auditoria do evento de contato será conectada nas histórias de contato/rastreabilidade funcional.

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/features/customer_authentication`
- `worklink-mobile/lib/main.dart`
- `worklink-api/src/test/java/br/com/worklink/application/authentication/usecase/AuthenticationUseCaseTest.java`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma capacidade funcional nova de autenticação do cliente no fluxo mobile, preservando
compatibilidade com os contratos existentes.
