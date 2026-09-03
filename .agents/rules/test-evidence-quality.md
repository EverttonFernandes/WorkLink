---
name: test-evidence-quality
description: Garantir que testes sejam evidência real de regra de negócio, com TDD, BDD e validação funcional suficiente.
applies_when:
  - criar testes
  - revisar testes
  - validar uma história
  - fechar versionamento semântico
source_docs:
  - docs/spec-driven-development/padroes-de-testes.md
complements:
  - .agents/rules/tdd-bdd-before-implementation.md
  - .agents/rules/refactor-after-functional-green.md
  - .agents/rules/main-push-quality-and-versioning.md
  - .agents/rules/post-push-ci-green.md
progressive_disclosure:
  - Ler este frontmatter quando criar, revisar ou executar testes.
  - Abrir corpo completo antes de alterar teste ou declarar evidencia.
  - Abrir source_docs somente para aprofundar padroes de teste.
conditional_details:
  - if: "demanda tem comportamento testavel"
    then: "use TDD/BDD, evidencie falha correta e depois sucesso"
  - else_if: "demanda depende de emulador/simulador/CI que nao roda localmente"
    then: "registre N/A local e exija post-push-ci-green.md"
  - else: "demanda sem teste automatizado aplicavel"
    then: "declare justificativa e rode gate minimo verificavel"
priority: critical
---

# Regra: Testes Como Evidência

Testes existem para provar comportamento de negócio, não para decorar pipeline.

## Complementos

- Use junto de `tdd-bdd-before-implementation.md` antes de alterar código produtivo.
- Use junto de `refactor-after-functional-green.md` depois dos funcionais verdes.
- Use junto de `main-push-quality-and-versioning.md` antes de commit, tag ou push.
- Use junto de `post-push-ci-green.md` depois do push quando a CI executar testes nao reproduzidos localmente.

## Roteamento Condicional

- Se o comportamento é testável, carregue esta rule por completo.
- Se a evidência local for `N/A`, carregue `post-push-ci-green.md` antes do fechamento.
- Se a mudança for documental, use gate mínimo e registre a justificativa.

## Ordem Obrigatória

1. Criar cenário funcional BDD antes da implementação quando houver comportamento testável.
2. Fazer o cenário falhar pelo motivo certo.
3. Implementar o mínimo necessário para passar.
4. Rodar testes funcionais aplicáveis.
5. Refatorar com segurança.
6. Criar ou ajustar unitários para maximizar cobertura e proteger regras internas.

## Padrão De Escrita

Todo teste deve ser legível, determinístico, isolado, didático, sem estado residual e estruturado em `GIVEN`, `WHEN`, `THEN`.

Em Java:

- usar `@DisplayName` em português;
- usar `BDDMockito.given(...)` para mocks;
- manter assertions explícitas, preferencialmente uma por linha.

Em testes funcionais:

- usar `describe` e `it` em português quando o stack permitir;
- usar fixtures e seeders explícitos;
- limpar dados automaticamente;
- validar efeito persistido, não apenas status HTTP ou texto na tela.

Em mobile:

- cobrir estados de sucesso, vazio, carregamento e erro quando aplicáveis;
- validar widget ou fluxo conforme risco da tela;
- usar emulador/simulador quando a história exigir integração mobile.
- quando o device nao existir localmente, registrar `N/A` apenas como evidencia local e exigir PASS do smoke mobile na CI.

## Cobertura

- A meta de cobertura unitária é 95% onde houver suíte aplicável.
- Cobertura não substitui cenário funcional.
- Cenário funcional não substitui unitário de regra crítica.

## Proibido

- apagar teste para passar;
- usar `skip`, `xdescribe`, `@Disabled` ou equivalente sem decisão explícita;
- enfraquecer assertion existente;
- testar só status code quando há regra de negócio;
- mockar integração e chamar isso de teste integrado;
- declarar história pronta sem evidência executada.
