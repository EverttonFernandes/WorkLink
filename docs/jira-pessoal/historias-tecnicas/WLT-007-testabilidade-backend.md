# WLT-007 — Testabilidade backend

## Objetivo

Criar base de testes unitários, integração e funcionais/E2E de API.

## Valor técnico

Permite validar regras de domínio, persistência real e fluxos de API como caixa-preta.

## RNFs relacionados

- RNF06, RNF13

## Escopo incluído

- Testes unitários com JUnit 5, Mockito e AssertJ.
- Testes de integração com Spring Boot Test e Testcontainers.
- Testes funcionais com Jest, Axios/Supertest, fixtures e seeders.
- Cobertura dos fluxos críticos.
- Gate de cobertura unitária backend mínima de 95%.

## Fora do escopo

- Testes mobile.
- Testes de carga avançados.

## Critérios de aceite

- Unitários devem validar domínio e casos de uso isolados.
- Unitários devem gerar relatório de cobertura e manter mínimo de 95%.
- Integração deve validar banco, migrations, constraints, transações e persistência crítica.
- Funcionais devem chamar endpoints HTTP sem importar código Java.
- Funcionais devem preparar massa, validar resposta, validar efeito e limpar massa.
- Fluxos obrigatórios do épico técnico devem ter estratégia de cobertura.
- Cobertura abaixo de 95% deve bloquear fechamento da história.

## Entrega versionável

- Tipo sugerido: `MINOR`
