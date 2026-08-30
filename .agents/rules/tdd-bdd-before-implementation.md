---
name: tdd-bdd-before-implementation
summary: Exige cenario funcional/BDD antes de alterar codigo produtivo e unitarios apenas apos funcionais verdes.
applies_when:
  - iniciar demanda funcional
  - alterar regra de negocio
  - alterar codigo produtivo
  - implementar historia WL ou WLT com comportamento verificavel
must_read: true
priority: critical
token_hint: Leia o frontmatter primeiro; carregue o corpo completo somente antes de implementar codigo produtivo.
complements:
  - .agents/rules/test-evidence-quality.md
  - .agents/rules/refactor-after-functional-green.md
  - .agents/rules/main-push-quality-and-versioning.md
---

# Rule: TDD e BDD antes da implementacao

## Responsabilidade unica

Garantir que toda demanda comece pelo comportamento esperado e pela regra de negocio antes de qualquer alteracao de
codigo produtivo.

## Complementos

- Use `test-evidence-quality.md` para detalhes de qualidade, isolamento, BDD e coverage.
- Use `refactor-after-functional-green.md` depois que os funcionais passarem.
- Use `main-push-quality-and-versioning.md` antes de commit, tag e push.

## Regra obrigatoria

Toda demanda deve comecar por comportamento esperado antes de implementacao.

Antes de alterar codigo produtivo, o agente deve:

1. Escrever ou atualizar o cenario funcional/BDD que descreve a regra de negocio esperada.
2. Executar esse cenario e confirmar que ele falha pelo motivo correto quando a funcionalidade ainda nao existe ou esta
   incorreta.
3. Implementar a menor mudanca necessaria para fazer o cenario funcional passar obedecendo a regra de negocio.
4. Reexecutar o cenario funcional e os testes funcionais relacionados ate ficarem verdes.
5. Somente depois dos testes funcionais verdes, escrever ou ajustar testes unitarios para maximizar cobertura do codigo
   alterado.
6. Reexecutar os testes unitarios, analises e gates aplicaveis antes do commit.

## Excecao

Se a demanda for exclusivamente documental, operacional ou de governanca, o agente deve declarar que TDD/BDD nao se
aplica diretamente e validar a mudanca com o gate mais proximo, como `git diff --cached --check`, `sh -n` ou `make -n`.
