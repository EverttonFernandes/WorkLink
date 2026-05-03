# WLT-007 — Testabilidade backend

## Fonte

- História: `docs/jira-pessoal/historias-tecnicas/WLT-007-testabilidade-backend.md`
- Ordem oficial: 07 em `docs/jira-pessoal/KANBAN-OFICIAL.md`
- Tipo: Técnica
- Versão sugerida: `MINOR`

## Objetivo

Criar a base de testes unitários, integração e funcionais/E2E de API para o backend.

## Escopo incluído

- Separação Maven entre testes unitários e testes de integração.
- Gate unitário com relatório JaCoCo e cobertura mínima de 95%.
- Teste de integração validando migrations em PostgreSQL real containerizado.
- Runner funcional HTTP em Node/Jest/Axios executado em container.
- Documentação dos comandos e responsabilidades de cada suíte.

## Fora do escopo

- Testes mobile.
- Testes de carga avançados.
- Cenários funcionais reais antes da existência dos endpoints de negócio.

## Critérios de aceite

- Unitários devem validar domínio e casos de uso isolados.
- Unitários devem gerar relatório de cobertura e manter mínimo de 95%.
- Integração deve validar banco, migrations, constraints, transações e persistência crítica em container Docker.
- Funcionais devem chamar endpoints HTTP sem importar código Java quando endpoints reais existirem.
- Funcionais devem preparar massa, validar resposta, validar efeito e limpar massa quando houver fluxos reais.
- Cobertura abaixo de 95% deve bloquear fechamento da história.
