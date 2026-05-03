# WLT-002 — Arquitetura modular hexagonal

## Objetivo

Definir e aplicar a arquitetura de monólito modular com DDD tático e arquitetura hexagonal.

## Valor técnico

Garante separação clara entre domínio, aplicação, infraestrutura e API, reduzindo acoplamento e facilitando evolução.

## RNFs relacionados

- RNF02, RNF15

## Escopo incluído

- Bounded contexts iniciais.
- Camadas `api`, `application`, `domain` e `infrastructure`.
- Portas e adaptadores para dependências externas.
- Diretriz de domínio sem dependência direta de banco, cache, storage, SMS/OTP ou framework web.

## Fora do escopo

- Microserviços.
- CQRS completo.
- Event Sourcing.
- Extração de serviços.

## Critérios de aceite

- Cada módulo deve ter responsabilidade clara.
- Domínio não deve depender de infraestrutura.
- Dependências externas devem ser acessadas por portas/adaptadores.
- Estrutura deve suportar os bounded contexts do épico técnico.
- Não deve haver abstração distribuída prematura.

## Entrega versionável

- Tipo sugerido: `MINOR`
