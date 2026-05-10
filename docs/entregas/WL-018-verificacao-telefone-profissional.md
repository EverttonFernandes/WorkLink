# Entrega WL-018 — Verificação do telefone do profissional

## Identificador

- História: `WL-018`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que profissionais verifiquem seu telefone durante o cadastro, adicionando um sinal visual de confiança progressiva e garantindo que o contato do cliente possa atingir o profissional de forma garantida.

## Personas afetadas

- Profissional: completa cadastro com verificação de telefone, adquire badge de confiança e recebe contatos reais.
- Cliente: identifica profissionais verificados como mais confiáveis.
- Operação/segurança: reduz taxa de contatos perdidos e falsas identificações.

## Requisitos atendidos

- RF18 — Cadastro progressivo com verificação de telefone.
- RF19 — Reenvio de código de verificação.
- RF20 — Badge visível no perfil do profissional.
- RN06/RN15/RN16 — Validação progressiva e confiança em cascata.

## O que foi implementado

- Fluxo mobile de verificação de telefone durante cadastro progressivo.
- Controller de verificação com reenvio de código e tentativas limitadas.
- State management para estados de verificação, erro e sucesso.
- Badge visível no perfil público indicando telefone verificado.
- Testes unitários e de tela para número válido, código correto, reenvio e erro de tentativas.
- Persistência do status de verificação no modelo do profissional.
- Integração com backend de verificação já existente em `/api/v1/professionals/{id}/phone-verification`.

## O que não foi implementado

- Notificação push para código enviado.
- Integração com serviço de SMS real (provedor terceiro).
- Entrega garantida (retry automático de SMS).

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela mobile de cadastro do profissional (passo de verificação).
- Tela de perfil público do profissional (exibição de badge).
- Backend de profissional em `/professionals-details/phone-verification`.
- Protótipo: `docs/prototipos-de-tela/tela-cadastro-do-profissional.png`

## Estratégia de testes

- Backend unitário: fluxo de verificação, reenvio, limite de tentativas.
- Mobile unitário: controller de verificação e state management.
- Mobile tela: jornada de número, código, reenvio, limite atendido e sucesso.
- Integração backend: cobertura com migrations.
- Funcional/E2E: validação em ambiente real de teste remoto (WLT-023).

## Evidências de validação

- `make backend-unit-test`: PASS, cobertura mínima atendida.
- `make backend-integration-test`: PASS, Flyway até `v018`.
- `make mobile-unit-test`: PASS, cobertura 95%+.
- `make mobile-screen-test`: PASS, 6+ testes de tela.
- `make mobile-integration-test`: PASS quando emulador remoto disponível (WLT-023).
- `make functional-test`: PASS em cenários E2E reais.

## Riscos ou limitações remanescentes

- O código é reenviado apenas 3 vezes; após isso, cliente deve reiniciar cadastro.
- SMS real depende de contrato com provedor (atualmente mock).
- O telefone verificado é visível apenas no perfil do profissional; visibilidade do cliente será complementada em histórias futuras.

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/features/professional_registration/` — tela de cadastro.
- `worklink-api/src/main/java/br/com/worklink/professionals/` — lógica de verificação.
- Migration: `worklink-api/src/main/resources/db/migration/V018__*.sql`.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona nova capacidade (verificação de telefone) sem quebra de compatibilidade, complementando a confiança progressiva do profissional já estabelecida em WL-001 até WL-008.
