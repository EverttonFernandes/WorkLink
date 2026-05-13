# Entrega WL-018 — Verificação do telefone do profissional

## Identificador

- História: `WL-018`
- Data: `2026-05-13`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que o telefone/WhatsApp do profissional seja confirmado antes de exibir o sinal de confiança correspondente
na listagem e no perfil público.

## Requisitos atendidos

- RF24 — confiança progressiva do profissional.
- RN15/RN16 — autenticidade, rastreabilidade e proteção contra sinal falso de confiança.

## O que foi implementado

- Coluna `phone_number_verified` em `worklink.professionals`.
- Contrato público de profissional com `phoneNumberVerified`.
- Use case para solicitar verificação de telefone com prazo de expiração.
- Use case para confirmar telefone por código configurado por ambiente.
- Endpoints autenticados:
  - `POST /api/v1/professionals/{professionalIdentifier}/phone-verification/request`
  - `POST /api/v1/professionals/{professionalIdentifier}/phone-verification/confirm`
- Ownership obrigatório para ação sensível de verificação do telefone profissional.
- Auditoria para solicitação e confirmação da verificação.
- Mobile lendo `phoneNumberVerified`, exibindo `Telefone verificado` na descoberta e badge no perfil.
- Service e gateway mobile para solicitar e confirmar verificação.

## O que não foi implementado

- Envio real de SMS/WhatsApp por provedor externo.
- KYC/documentoscopia.
- Tela dedicada de digitação de código para profissional autenticado.
- Garantia de qualidade do serviço prestado.

## Configuração operacional

- `WORKLINK_PROFESSIONAL_PHONE_VERIFICATION_CODE`
- `WORKLINK_PROFESSIONAL_PHONE_VERIFICATION_EXPIRATION_MINUTES`

## Evidências de validação

- `make backend-unit-test`: PASS, 261 testes, Jacoco 95%+ atendido.
- `make backend-integration-test`: PASS, Flyway até `v017`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura `95.77%`.
- `make mobile-screen-test`: PASS.
- `make mobile-integration-test`: PASS para contrato HTTP; device N/A por ausência de emulador/simulador.
- `make functional-test`: N/A, suíte funcional ainda sem cenários reais.
- `git diff --check`: PASS.

## Riscos ou limitações remanescentes

- O código de verificação V1 é configurado por ambiente, sem integração com provedor real.
- A experiência visual de solicitação/confirmação ainda depende de tela profissional autenticada futura; o contrato e o
  gateway já estão prontos para esse fluxo.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona uma nova capacidade de confiança progressiva sem quebrar compatibilidade dos contratos
existentes.
