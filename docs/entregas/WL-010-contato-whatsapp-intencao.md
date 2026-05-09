# Entrega WL-010 — Contato via WhatsApp e intenção de contato

## Identificador

- História: `WL-010`
- Data: `2026-05-09`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que cliente autenticado chame o profissional via WhatsApp, registrando antes a intenção de contato e deixando
claro que a negociação acontece fora do WorkLink.

## Personas afetadas

- Usuário cliente: inicia contato com o profissional após autenticação.
- Profissional: recebe contato por WhatsApp a partir de cliente identificado.
- Produto/operação: passa a ter base rastreável para pós-contato, reputação e auditoria.

## Requisitos atendidos

- RF31 — Ação de chamar profissional via WhatsApp.
- RF32 — Registro de intenção de contato.
- RF33 — Aviso de redirecionamento externo.
- RF34 — Informação de negociação fora do app.
- RF35 — Informação de que o WorkLink não garante execução do serviço.
- RN02/RN03/RN04/RN05 — Autenticação, autorização, auditoria e rastreabilidade.

## O que foi implementado

- Backend de intenção de contato com domínio, caso de uso, portas e adapters.
- Endpoint `POST /api/v1/contact-intentions` exigindo principal autenticado.
- Persistência de intenção em `worklink.contact_intentions` antes da geração do link WhatsApp.
- Adapter dedicado para criação de link WhatsApp, sem regra de negócio acoplada à chamada externa.
- Auditoria sensível para `REGISTER_CONTACT_INTENTION`.
- Tela mobile `Falar com o profissional` com avisos obrigatórios de negociação externa e ausência de garantia.
- Controller mobile testável que registra intenção antes de tentar abrir o WhatsApp e trata falha de redirecionamento.

## O que não foi implementado

- Chat interno.
- Pagamento.
- Contrato.
- Garantia de execução do serviço.
- Adapter HTTP real do app mobile para o endpoint, que fica para a integração mobile/API futura.

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela mobile de contato com o profissional.
- Perfil público do profissional, ação `Chamar no WhatsApp`.
- Endpoint `POST /api/v1/contact-intentions`.
- Migração `V010__create_contact_intentions.sql`.
- Protótipo: `docs/prototipos-de-tela/tela-falar-com-o-profissional.png`.

## Estratégia de testes

- Backend domínio: criação e validação da intenção de contato.
- Backend aplicação: cliente autenticado, profissional inexistente, perfil não cliente e ordem intenção antes do link.
- Backend API: autenticação obrigatória, contrato HTTP, payload de resposta e auditoria.
- Backend infraestrutura: persistência JDBC e adapter WhatsApp.
- Mobile unitário: estado/controller do contato, sucesso, falha no redirecionamento e falha no registro.
- Mobile tela: avisos obrigatórios, intenção registrada e erro de redirecionamento.

## Evidências de validação

- `make backend-unit-test`: PASS, 182 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v010`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 98,01%.
- `make mobile-screen-test`: PASS, 32 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.

## Riscos ou limitações remanescentes

- O app mobile ainda usa callbacks locais para registrar e abrir o contato; a chamada HTTP real será conectada quando a
  camada de comunicação mobile/API for introduzida.
- O link WhatsApp é retornado como URL web (`https://wa.me/...`); deep link nativo pode ser refinado em uma entrega
  específica de integração mobile.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/domain/contact`
- `worklink-api/src/main/java/br/com/worklink/application/contact`
- `worklink-api/src/main/java/br/com/worklink/api/contact`
- `worklink-api/src/main/java/br/com/worklink/infrastructure/contact`
- `worklink-mobile/lib/features/professional_contact`
- `worklink-mobile/lib/main.dart`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma nova capacidade funcional de contato via WhatsApp com rastreabilidade, mantendo
compatibilidade com as funcionalidades existentes.
