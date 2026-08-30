---
name: refactor-after-functional-green
summary: Exige refatoracao e limpeza tecnica apos funcionais verdes para evitar codigo sujo, acoplado ou mal nomeado.
applies_when:
  - testes funcionais verdes
  - finalizar implementacao
  - revisar codigo antes de unitarios finais
  - preparar entrega
  - fechar historia
must_read: true
priority: critical
token_hint: Leia o frontmatter primeiro; carregue o corpo completo quando os funcionais passarem e antes dos unitarios finais.
complements:
  - .agents/rules/clean-code-readable-names.md
  - .agents/rules/architecture-boundaries-and-solid.md
  - .agents/rules/test-evidence-quality.md
---

# Rule: Refatorar apos funcionais verdes

## Responsabilidade unica

Garantir capricho tecnico ao final da implementacao, limpando o codigo assim que a regra de negocio estiver funcionando
nos testes funcionais.

## Complementos

- Use `clean-code-readable-names.md` para nomenclatura, clareza e limpeza de UI/scripts/testes.
- Use `architecture-boundaries-and-solid.md` para reduzir acoplamento e proteger camadas.
- Use `test-evidence-quality.md` para reexecutar evidências após a refatoração.

## Regra obrigatoria

Depois que os cenarios funcionais/BDD passarem, o agente deve executar uma etapa explicita de refatoracao antes de
considerar a demanda pronta.

Essa etapa deve procurar e corrigir:

1. Nomes ruins, genericos, ambigos ou desalinhados com a linguagem do dominio.
2. Duplicacoes desnecessarias.
3. Acoplamento excessivo entre camadas, features, componentes ou casos de uso.
4. Metodos, widgets, classes ou funcoes grandes demais.
5. Regras de negocio vazando para controller, tela, adapter ou infraestrutura.
6. Condicionais confusas que possam virar objetos de valor, metodos nomeados ou pequenas abstractions locais.
7. Comentarios que explicam codigo ruim em vez de melhorar o proprio codigo.
8. Inconsistencias com padroes ja existentes no repositorio.
9. Mas praticas de design, arquitetura, testes ou desenvolvimento de software.

## Ordem correta

1. Funcionais/BDD verdes.
2. Refatoracao com capricho.
3. Funcionais/BDD verdes novamente.
4. Testes unitarios ajustados ou criados para maximizar cobertura.
5. Analise estatica e gates finais.
6. Commit semantico e tag, quando aplicavel.

## Limite da refatoracao

A limpeza deve ficar dentro do escopo da demanda atual. O agente nao deve abrir refatoracoes amplas ou oportunistas que
misturem historias diferentes, alterem comportamento nao coberto ou criem risco desnecessario.

## Criterio de saida

Uma demanda so pode ser considerada bem finalizada quando o codigo entregue estiver legivel, coeso, testado, com bons
nomes, baixo acoplamento e sem atalhos tecnicos evitaveis.
