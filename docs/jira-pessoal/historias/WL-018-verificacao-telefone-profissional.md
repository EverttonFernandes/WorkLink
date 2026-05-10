# WL-018 — Verificação do telefone do profissional

## Objetivo

Permitir que o telefone/WhatsApp do profissional seja verificado antes de exibir o sinal de confiança correspondente.

## Valor entregue

O usuário cliente consegue diferenciar profissionais com contato informado de profissionais com contato realmente
verificado, fortalecendo a confiança progressiva da V1.

## Personas

- Profissional
- Usuário cliente
- Administrador

## Requisitos relacionados

- RF24
- RN15, RN16

## Escopo incluído

- Fluxo simples de verificação do telefone/WhatsApp do profissional.
- Persistência do status de telefone verificado.
- Exibição do badge/sinal de telefone verificado no perfil e na listagem.
- Auditoria mínima da verificação.

## Fora do escopo

- Verificação documental avançada.
- KYC externo.
- Garantia de qualidade do serviço.

## Critérios de aceite

- Profissional deve conseguir solicitar verificação do telefone/WhatsApp.
- Sistema deve confirmar o telefone por código ou mecanismo equivalente compatível com a V1.
- Perfil profissional deve indicar telefone verificado apenas após confirmação.
- Profissional sem confirmação não deve receber badge de telefone verificado.
- Listagem e perfil devem refletir o status de forma consistente.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: fecha lacuna de confiança progressiva da V1.
