---
name: main-push-quality-and-versioning
summary: Bloqueia push na main sem gates verdes, staging seletivo, commit semantico e tag vX.Y.Z no mesmo hash.
applies_when:
  - preparar commit
  - criar tag semantica
  - fazer push para main
  - fechar historia
  - sincronizar com remoto
must_read: true
priority: critical
token_hint: Leia o frontmatter primeiro; carregue o corpo completo somente antes de commit/tag/push.
complements:
  - .agents/rules/tdd-bdd-before-implementation.md
  - .agents/rules/test-evidence-quality.md
  - .agents/rules/refactor-after-functional-green.md
---

# Rule: Push na main somente com qualidade e versionamento

## Responsabilidade unica

Impedir que desenvolvimento assistido por IA envie alteracoes para `main` com testes quebrando, CI vermelha conhecida
ou tag semantica inconsistente.

## Complementos

- Confirme que `tdd-bdd-before-implementation.md` foi respeitada quando houve código produtivo.
- Confirme que `test-evidence-quality.md` foi respeitada nos testes alterados.
- Confirme que `refactor-after-functional-green.md` foi respeitada antes do fechamento.

## Regra obrigatoria

Nenhum agente de IA pode fazer push para `main` se existir qualquer teste, analise ou gate quebrando.

Antes de fazer push para `main`, o agente deve:

1. Revisar `git status --short` e fazer staging seletivo apenas da demanda atual.
2. Executar os gates locais aplicaveis.
3. Corrigir qualquer falha antes de commitar.
4. Criar commit semantico no padrao Conventional Commits.
5. Criar a tag semantica exata `vMAJOR.MINOR.PATCH` apontando para o mesmo commit.
6. Validar programaticamente que `git rev-parse HEAD` e `git rev-parse <tag>^{}` retornam o mesmo hash.
7. Fazer push da branch e da tag correspondente.

## Gates minimos antes do push

O gate padrao para uma entrega completa e:

```sh
make test
```

Quando a demanda alterar somente governanca, README, workflow, scripts ou configuracao, o agente ainda deve executar no
minimo:

```sh
git diff --cached --check
```

e tambem qualquer comando especifico afetado pela mudanca, por exemplo:

```sh
sh -n scripts/*.sh
make -n <target-afetado>
```

Se houver duvida sobre impacto, execute `make test`.

## Proibicoes

- Nao usar `--no-verify` em commits ou pushes.
- Nao empurrar `main` com CI vermelha conhecida.
- Nao criar tag depois em outro commit para "corrigir" versionamento.
- Nao misturar arquivos de outra historia no commit atual.
- Nao versionar secrets, chaves, keystores, tokens, dumps, artefatos de build ou documentos internos ignorados.

## Mudancas locais de outra demanda

Se existirem arquivos modificados por outra historia, o agente deve preservar essas alteracoes e isolar o commit atual
com staging seletivo. Caso os testes locais sejam contaminados por mudancas nao relacionadas, isso deve ser declarado
explicitamente antes de qualquer push.
