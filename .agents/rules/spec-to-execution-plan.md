---
name: spec-to-execution-plan
description: Registrar que o spec-driven-development já foi quebrado em épico, histórias e kanban; a execução deve seguir o KANBAN-OFICIAL.
applies_when:
  - iniciar uma história
  - criar ou revisar IMPLEMENTATION.md
  - preparar execução com Ralph Loop
official_execution_source:
  - docs/jira-pessoal/KANBAN-OFICIAL.md
story_sources:
  - docs/jira-pessoal/historias/
  - docs/jira-pessoal/historias-tecnicas/
delivery_sources:
  - docs/entregas/
source_docs:
  - docs/spec-driven-development/spec-driven-development.md
  - docs/spec-driven-development/codigo-limpo.md
  - docs/spec-driven-development/padroes-de-testes.md
  - docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md
complements:
  - .agents/rules/tdd-bdd-before-implementation.md
  - .agents/rules/test-evidence-quality.md
  - .agents/rules/refactor-after-functional-green.md
  - .agents/rules/clean-code-readable-names.md
  - .agents/rules/architecture-boundaries-and-solid.md
priority: high
---

# Regra: Spec Para Plano Executável

O `spec-driven-development` inicial já virou épico, histórias de negócio, histórias técnicas e entregas documentadas.

A fonte oficial para decidir a próxima demanda é sempre `docs/jira-pessoal/KANBAN-OFICIAL.md`.

Esta rule não manda replanejar o projeto a partir dos documentos de SDD. Ela registra como os padrões de SDD complementam uma história que já existe no kanban.

## Fonte De Verdade Da Execução

Antes de implementar:

1. Leia `docs/jira-pessoal/KANBAN-OFICIAL.md`.
2. Selecione a primeira história elegível na ordem cronológica oficial.
3. Leia a história em `docs/jira-pessoal/historias/` ou `docs/jira-pessoal/historias-tecnicas/`.
4. Preserve os critérios de aceite, dependências, versão esperada e relação com entregas já registradas.
5. Crie ou revise `docs/tasks/<KEY>/IMPLEMENTATION.md` sem mudar a ordem do kanban.

## Papel Do Spec-Driven-Development

Os documentos em `docs/spec-driven-development/` são padrões normativos de qualidade. Eles entram como complemento da história oficial, não como fila paralela.

Use:

- `codigo-limpo.md` para nomes, clareza, scripts, fixtures, CI, mobile e limpeza final.
- `padroes-de-testes.md` para TDD, BDD, testes funcionais, unitários, integração, widget, mobile e coverage.
- `padrões-de-projeto-e-design-de-codigo.md` para arquitetura, domínio, aplicação, portas, adapters, SOLID e integração externa.

## Complementos

- Abra `tdd-bdd-before-implementation.md` e `test-evidence-quality.md` antes de comportamento testável.
- Abra `clean-code-readable-names.md` e `refactor-after-functional-green.md` antes da limpeza final.
- Abra `architecture-boundaries-and-solid.md` quando houver regra de negócio, integração externa ou fronteira de camada.

## Critérios Obrigatórios No Plano

O `IMPLEMENTATION.md` deve registrar:

- história oficial escolhida no kanban;
- caminho da história de negócio ou técnica;
- ordem cronológica preservada;
- critérios de aceite originais;
- entregas anteriores relacionadas, quando existirem;
- regras de código limpo aplicáveis;
- estratégia de testes e cenários BDD iniciais;
- critérios de arquitetura e fronteiras afetadas;
- riscos de acoplamento;
- gates de QA, SRE, segurança, arquitetura e revisão final;
- itens manuais que dependem do usuário, quando existirem.

## Bloqueios

A implementação não deve começar quando:

- a história não é a primeira elegível no `KANBAN-OFICIAL.md`;
- o plano tenta criar uma fila paralela fora do kanban;
- a história individual não foi lida;
- os critérios de aceite originais foram alterados sem decisão explícita;
- o plano não cita os padrões de SDD aplicáveis;
- há tela mobile sem referência a protótipo quando existir protótipo mapeado;
- há gate marcado como `SKIP`.

## Entregas

Ao fechar uma história, registre a entrega em `docs/entregas/` e atualize o `KANBAN-OFICIAL.md`.

Histórias de negócio vivem em `docs/jira-pessoal/historias/`.

Histórias técnicas vivem em `docs/jira-pessoal/historias-tecnicas/`.
