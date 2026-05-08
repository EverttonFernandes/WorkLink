# Entrega WL-007 — Badges de confiança e completude

## Resultado

Implementada a exibição de badges de perfil básico, perfil completo, telefone verificado e documento informado no perfil público mobile.

## Valor de produto

O cliente passa a enxergar sinais objetivos de completude e confiança sem interpretar os badges como garantia de qualidade do serviço.

## Mudanças principais

- Modelo mobile deriva badges visíveis a partir de completude, telefone verificado e documento informado.
- Tela de perfil público exibe os badges e mantém aviso explícito de que completude não garante qualidade do serviço.
- Resposta HTTP pública de profissionais substitui `documentNumber` por `documentProvided`.
- Testes BDD/TDD cobrem badges, ausência de documento sensível e comportamento visual da tela.

## Gates executados

- `make backend-static-analysis`: PASS
- `make backend-unit-test`: PASS, 88 testes, JaCoCo PASS
- `make backend-integration-test`: PASS, Flyway v005
- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura 100.00%
- `make mobile-screen-test`: PASS
- `make mobile-integration-test`: N/A, sem Android Emulator, iOS Simulator ou Chrome no container
- `make functional-test`: N/A, sem cenários funcionais reais
- `git diff --check`: PASS
- Varredura local de segredos: PASS, apenas `compose.yml` referencia variável de senha do Postgres

## Versão

- Tipo semântico: MINOR
- Tag planejada: `v0.17.0`
