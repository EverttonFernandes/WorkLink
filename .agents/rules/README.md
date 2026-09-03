---
name: rules-index
description: Índice de roteamento das rules locais do WorkLink para leitura progressiva e baixo consumo de contexto.
document_type: rules_reference
max_lines: 300
progressive_disclosure:
  - Ler este indice antes de abrir rules individuais.
  - Escolher a menor combinacao de rules pelo cenario da demanda.
  - Abrir o corpo de cada rule somente quando conditional_details justificar.
conditional_details:
  - if: "demanda inicia ou retoma historia"
    then: "abra spec-to-execution-plan.md e as rules que ela apontar"
  - else_if: "demanda e commit, tag, push ou CI"
    then: "abra main-push-quality-and-versioning.md e post-push-ci-green.md"
  - else: "demanda pontual"
    then: "abra somente a rule diretamente aplicavel"
---

# Rules Do WorkLink

Use este índice para escolher a menor combinação de rules antes de executar uma demanda.

## Início De História

Abra:

- `spec-to-execution-plan.md`
- `tdd-bdd-before-implementation.md`, se houver comportamento testável

## Progressive Disclosure E Conditional Details

Toda rule deve ser consumida em camadas:

1. Leia o frontmatter para decidir aplicabilidade.
2. Leia `conditional_details` para escolher a rule complementar correta.
3. Abra o corpo completo somente quando a condição da demanda exigir.
4. Siga links em `complements` apenas quando o cenário cair no `if`, `else_if` ou `else` declarado.

Use conditional details assim:

- `if`: cenário principal que obriga a rule.
- `else_if`: cenários próximos que exigem complemento específico.
- `else`: cenário fora de escopo, com rule alternativa ou validação mínima.

## Testes E Evidências

Abra:

- `test-evidence-quality.md`
- `tdd-bdd-before-implementation.md`
- `main-push-quality-and-versioning.md`, antes de commit/tag/push
- `post-push-ci-green.md`, depois de push quando a demanda disparar CI

## Clean Code, Refactoring, SOLID E Design Patterns

Abra em conjunto:

- `clean-code-readable-names.md`
- `refactor-after-functional-green.md`
- `architecture-boundaries-and-solid.md`

Use esse trio quando a demanda envolver regra de negócio, arquitetura, refatoração, nomes, camadas, integração externa ou revisão final.

## Fechamento E Push

Abra:

- `main-push-quality-and-versioning.md`
- `post-push-ci-green.md`
- `test-evidence-quality.md`
- `refactor-after-functional-green.md`

## Ordem Recomendada

1. `spec-to-execution-plan.md`
2. `tdd-bdd-before-implementation.md`
3. `test-evidence-quality.md`
4. implementação
5. `refactor-after-functional-green.md`
6. `clean-code-readable-names.md`
7. `architecture-boundaries-and-solid.md`
8. `main-push-quality-and-versioning.md`
9. `post-push-ci-green.md`
