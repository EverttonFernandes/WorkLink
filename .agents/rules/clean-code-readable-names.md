---
name: clean-code-readable-names
description: Impor nomes explícitos, código limpo e limpeza final em produção, testes, scripts, mobile e CI.
applies_when:
  - escrever código
  - escrever testes
  - criar scripts ou pipelines
  - refatorar depois dos funcionais passarem
source_docs:
  - docs/spec-driven-development/codigo-limpo.md
complements:
  - .agents/rules/refactor-after-functional-green.md
  - .agents/rules/architecture-boundaries-and-solid.md
  - .agents/rules/test-evidence-quality.md
progressive_disclosure:
  - Ler este frontmatter quando a demanda criar ou revisar nomes.
  - Abrir o corpo completo durante implementacao ou limpeza final.
  - Abrir source_docs apenas para duvida conceitual de clean code.
conditional_details:
  - if: "codigo, teste, script, workflow ou UI recebeu novos nomes"
    then: "valide intencao, linguagem de dominio e ausencia de labels tecnicas"
  - else_if: "nome ruim revela acoplamento ou regra na camada errada"
    then: "use architecture-boundaries-and-solid.md"
  - else: "sem nomes novos ou alterados"
    then: "mantenha apenas frontmatter em contexto"
priority: high
---

# Regra: Código Limpo E Nomes Claros

Código deve ser lido como documentação executável do negócio.

## Complementos

- Use junto de `refactor-after-functional-green.md` quando os funcionais já estiverem verdes.
- Use junto de `architecture-boundaries-and-solid.md` quando nomes revelarem vazamento de camada.
- Use junto de `test-evidence-quality.md` para nomes didáticos em testes, fixtures e cenários.

## Roteamento Condicional

- Se a mudança cria nomes públicos, privados, técnicos ou de teste, aplique esta rule.
- Se o problema for fronteira de arquitetura, carregue `architecture-boundaries-and-solid.md`.
- Se for só consulta rápida sem alteração, use o frontmatter e evite carregar detalhes.

## Nomes

Use nomes explícitos, sem economia artificial de palavras.

Os nomes devem revelar intenção, regra de negócio, estado, papel no fluxo e consequência esperada.

Evite abreviações, exceto quando forem padrão universal do stack ou domínio.

## Onde A Regra Vale

Esta regra vale para backend, mobile Flutter, testes, fixtures, seeders, payloads, responses, scripts, workflows, variáveis de ambiente e documentação operacional.

## Mobile

Screens, widgets, controllers, providers e estados devem deixar claro:

- tela atendida;
- fluxo de usuário;
- estado visual;
- ação principal.

UI não deve expor labels técnicas, enums, chaves internas ou mensagens de debug.

## Scripts E CI

Jobs, steps, targets e variáveis devem explicar objetivo operacional.

Comandos longos devem ser separados por responsabilidade quando isso melhorar manutenção.

## Limpeza Final

Depois dos funcionais passarem:

- remova duplicação sem criar abstração prematura;
- simplifique nomes vagos;
- reduza acoplamento;
- elimine código morto;
- preserve comportamento coberto por testes.

Comentários só devem explicar contexto, risco ou decisão que o código não consegue expressar sozinho.
