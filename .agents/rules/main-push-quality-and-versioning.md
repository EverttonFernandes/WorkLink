---
name: main-push-quality-and-versioning
summary: Bloqueia push na main sem gates verdes, staging seletivo, commit semantico, coauthor IA e tag vX.Y.Z no mesmo hash.
applies_when:
  - preparar commit
  - criar tag semantica
  - fazer push para main
  - fechar historia
  - sincronizar com remoto
must_read: true
priority: critical
token_hint: Leia o frontmatter primeiro; carregue o corpo completo somente antes de commit/tag/push.
progressive_disclosure:
  - Ler este frontmatter quando houver commit, tag, push ou fechamento.
  - Abrir o corpo completo antes de executar git commit, git tag ou git push.
  - Abrir post-push-ci-green.md somente depois de publicar o commit.
conditional_details:
  - if: "push para main, tag semantica ou fechamento de historia"
    then: "execute gates locais, valide tag no mesmo hash e monitore CI pos-push"
  - else_if: "mudanca somente documental, script ou workflow"
    then: "rode git diff --cached --check e o gate especifico do arquivo afetado"
  - else: "nao ha operacao de versionamento"
    then: "nao carregue corpo completo; consulte apenas quando preparar commit"
complements:
  - .agents/rules/tdd-bdd-before-implementation.md
  - .agents/rules/test-evidence-quality.md
  - .agents/rules/refactor-after-functional-green.md
  - .agents/rules/post-push-ci-green.md
---

# Rule: Push na main somente com qualidade e versionamento

## Responsabilidade unica

Impedir que desenvolvimento assistido por IA envie alteracoes para `main` com testes quebrando, CI vermelha conhecida
ou tag semantica inconsistente.

## Complementos

- Confirme que `tdd-bdd-before-implementation.md` foi respeitada quando houve código produtivo.
- Confirme que `test-evidence-quality.md` foi respeitada nos testes alterados.
- Confirme que `refactor-after-functional-green.md` foi respeitada antes do fechamento.
- Confirme que `post-push-ci-green.md` foi respeitada antes de declarar a historia concluida.

## Roteamento Condicional

- Se houver push para `main`, carregue esta rule por completo antes do push.
- Se a demanda alterou testes, mobile, backend, CI ou Docker, combine com `post-push-ci-green.md`.
- Se a mudança não será versionada agora, mantenha apenas o frontmatter em contexto.

## Regra obrigatoria

Nenhum agente de IA pode fazer push para `main` se existir qualquer teste, analise ou gate quebrando.

Antes de fazer push para `main`, o agente deve:

1. Revisar `git status --short` e fazer staging seletivo apenas da demanda atual.
2. Executar os gates locais aplicaveis.
3. Corrigir qualquer falha antes de commitar.
4. Criar commit semantico no padrao Conventional Commits com trailer `Co-authored-by` da LLM colaboradora.
5. Criar a tag semantica exata `vMAJOR.MINOR.PATCH` apontando para o mesmo commit.
6. Validar programaticamente que `git rev-parse HEAD` e `git rev-parse <tag>^{}` retornam o mesmo hash.
7. Fazer push da branch e da tag correspondente.
8. Monitorar a CI do commit publicado ate conclusao verde antes de declarar entrega fechada.

## Coautoria IA

Todo commit assistido por IA deve terminar com trailer de coautoria no formato:

```text
Co-authored-by: <LLM usada>
```

Se o usuário informar explicitamente o modelo, preserve esse nome. Exemplo:

```text
Co-authored-by: Claude Opus 4.6
```

Não invente endereço de email para LLM. Se fizer sentido, cite apenas o provedor junto ao nome do modelo.

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
- Nao commitar trabalho assistido por IA sem trailer `Co-authored-by`.
- Nao declarar entrega concluida sem verificar a CI pos-push do commit publicado.
- Nao criar tag depois em outro commit para "corrigir" versionamento.
- Nao misturar arquivos de outra historia no commit atual.
- Nao versionar secrets, chaves, keystores, tokens, dumps, artefatos de build ou documentos internos ignorados.

## Mudancas locais de outra demanda

Se existirem arquivos modificados por outra historia, o agente deve preservar essas alteracoes e isolar o commit atual
com staging seletivo. Caso os testes locais sejam contaminados por mudancas nao relacionadas, isso deve ser declarado
explicitamente antes de qualquer push.
