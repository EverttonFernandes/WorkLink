# Entrega WL-008 — Disponibilidade do profissional

## Resultado

Implementada a disponibilidade do profissional como status fechado da V1, com persistência, API pública e exibição no mobile.

## Valor de produto

O cliente passa a ver sinais objetivos de chance de atendimento na listagem e no perfil, sem tratar disponibilidade como garantia de atendimento.

## Mudanças principais

- Domínio backend recebeu `ProfessionalAvailabilityStatus` com os valores permitidos da V1.
- Migração `V006__add_professional_availability.sql` adiciona `availability_status`, valor padrão e restrição de integridade.
- Cadastro e resposta pública de profissional passam a aceitar e expor status, label e indicação de redução de destaque.
- Listagem backend e filtro mobile reduzem destaque de profissionais temporariamente indisponíveis.
- Cadastro, descoberta e perfil mobile exibem o badge de disponibilidade a partir de enum compartilhado no app.
- Testes BDD/TDD cobrem valores permitidos, badge público, ordenação de indisponíveis e ausência de promessa de garantia.

## Gates executados

- `make backend-static-analysis`: PASS
- `make backend-integration-test`: PASS, 91 testes unitários, 1 teste de integração, Flyway v006 e JaCoCo PASS
- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura 99.51%
- `make mobile-screen-test`: PASS
- `make mobile-integration-test`: N/A, sem Android Emulator, iOS Simulator ou Chrome no container
- `make functional-test`: N/A, sem cenários funcionais reais
- `git diff --check`: PASS
- Varredura local de segredos: PASS, apenas `compose.yml` referencia variável de senha do Postgres

## Versão

- Tipo semântico: MINOR
- Tag planejada: `v0.18.0`
