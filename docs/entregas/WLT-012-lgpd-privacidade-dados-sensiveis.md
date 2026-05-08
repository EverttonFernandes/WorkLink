# Entrega WLT-012 — LGPD, privacidade e minimização de dados

## Identificador

- História: `WLT-012`
- Data: `2026-05-08`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Reduzir risco regulatório e proteger clientes, profissionais e denunciantes por meio de minimização de dados,
finalidade clara, exposição controlada e preparação para anonimato público.

## Personas afetadas

- Usuário cliente: dados de autenticação e avaliações futuras passam a ter finalidade e exposição controladas.
- Profissional: dados públicos e dados restritos do perfil ficam classificados por finalidade e retenção.
- Administrador: passa a ter base técnica para tratar dados sensíveis com acesso restrito.

## Requisitos atendidos

- RNF04 — Privacidade e LGPD.
- RNF05 — Criptografia e proteção de dados sensíveis.

## O que foi implementado

- Inventário executável de dados pessoais, finalidade, retenção e exposição.
- Bloqueio de coleta fora do escopo da V1 na política de privacidade.
- Rejeição de campos JSON desconhecidos nos contratos HTTP.
- Projeção de autoria pública para avaliação anônima futura, preservando autoria interna.
- Documentação de exclusão de conta e resposta mínima a incidentes de privacidade.

## O que não foi implementado

- Fluxo funcional de avaliação.
- Exclusão real de conta.
- Portal LGPD.
- Workflow administrativo completo de privacidade.

## Fluxos, telas, endpoints ou módulos envolvidos

- Configuração HTTP global de JSON.
- `POST /api/v1/categories` como contrato testado contra campo fora de escopo.
- Módulo backend de privacidade.

## Estratégia de testes

- Unitários: inventário de privacidade, regras de finalidade/retenção/exposição e projeção de anonimato público.
- API: rejeição de campo desconhecido antes de chamar caso de uso.
- Integração: suite backend completa e migrations.
- Mobile: gates existentes executados para garantir ausência de regressão.

## Evidências de validação

- `rm -rf worklink-api/target && make backend-unit-test`: PASS, 159 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v009`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, 33 testes e cobertura 99,51%.
- `make mobile-screen-test`: PASS, 22 testes.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `git diff --check`: PASS.
- Varredura de segredos: PASS com apenas o placeholder esperado em `compose.yml`.

## Riscos ou limitações remanescentes

- Fluxos futuros de avaliação, denúncia, exclusão de conta e admin ainda devem conectar seus próprios contratos de privacidade.
- Retenção automatizada e portal LGPD ficam para entregas posteriores.

## Arquivos ou módulos relevantes

- `worklink-api/src/main/java/br/com/worklink/application/privacy`
- `worklink-api/src/main/resources/application.yml`
- `docs/arquitetura/lgpd-privacidade-minimizacao.md`

## Justificativa do versionamento

`MINOR`, porque a entrega adiciona uma capacidade técnica nova de privacidade por padrão e minimização, sem quebrar
contratos funcionais existentes.
