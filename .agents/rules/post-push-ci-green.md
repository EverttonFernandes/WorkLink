---
name: post-push-ci-green
summary: Exige monitoramento da CI apos push e bloqueia fechamento com run vermelho, pendente ou nao verificado.
applies_when:
  - fazer push para main
  - fechar historia
  - validar pipeline
  - publicar tag semantica
  - alterar mobile, CI, Docker, backend ou testes
must_read: true
priority: critical
token_hint: Leia antes de declarar entrega concluida apos push.
complements:
  - .agents/rules/main-push-quality-and-versioning.md
  - .agents/rules/test-evidence-quality.md
---

# Rule: CI Pos-Push Verde

## Responsabilidade unica

Impedir que uma historia seja declarada entregue enquanto a CI disparada pelo push ainda nao foi verificada como verde.

## Regra obrigatoria

Depois de fazer push para `main`, o agente deve:

1. Identificar o workflow disparado para o commit enviado.
2. Monitorar o run ate `completed`.
3. Confirmar `conclusion=success` no run completo, nao apenas em jobs parciais.
4. Validar que a tag semantica esperada aponta para o mesmo hash publicado.
5. Registrar run id, conclusao e evidencias nos artefatos da historia quando aplicavel.

## Se a CI falhar

Uma falha de CI reabre a demanda automaticamente.

O agente deve:

1. Identificar workflow, run id, job e step falho.
2. Classificar a falha como codigo/teste, coverage, build, infraestrutura, credencial, action terceirizada ou rede.
3. Corrigir quando estiver dentro do repositorio.
4. Reexecutar gates locais afetados.
5. Criar novo commit semantico e nova tag semantica apontando para o novo HEAD.
6. Fazer novo push e monitorar a CI novamente.

## Smoke Mobile

Quando existir job de emulador Android ou simulador iOS na CI, `N/A` local por ausencia de device nao equivale a PASS.

Para historias que alterem Flutter, rotas, autenticacao, discovery, perfil profissional, release mobile ou testes mobile:

- o smoke mobile da CI precisa passar antes do fechamento;
- falha de finder, navegacao, contrato HTTP ou widget ausente e falha funcional;
- falha de AVD, `adb`, boot, runner ou timeout de device e falha de infraestrutura.

## Proibicoes

- Declarar historia concluida com run pendente, vermelho, cancelado ou nao consultado.
- Ignorar falha de job opcional quando ele executou e encontrou erro funcional.
- Tratar artefato local, APK gerado ou testes unitarios verdes como substituto da CI pos-push.
