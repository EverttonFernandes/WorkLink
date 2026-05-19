# WLT-028 — Promoção de release e rollback mobile

## Objetivo

Definir o fluxo oficial de promoção de builds mobile entre desenvolvimento, teste interno e publicação futura, com critérios de rollback.

## Valor técnico

Depois que a pipeline gera e valida builds, o projeto precisa de um processo explícito para decidir quando promover uma versão, quando bloquear uma publicação e como reagir a problemas após distribuição.

## RNFs relacionados

- RNF03
- RNF06
- RNF13
- RNF14

## Escopo incluído

- Definir fluxo de release candidate mobile.
- Definir critérios mínimos para promover build para teste interno.
- Registrar checklist pré-publicação para Play Store e App Store.
- Definir estratégia de rollback ou desativação de versão problemática.
- Documentar versionamento, tags e changelog.
- Preparar a separação entre CI obrigatória e CD manual/aprovado.

## Fora do escopo

- Publicação automática em produção.
- Feature flags remotas.
- Observabilidade em produção via serviços externos.
- Suporte operacional 24x7.

## Critérios de aceite

- Existe checklist de promoção de release mobile.
- A versão mobile fica rastreável por tag, commit e artifact.
- O fluxo diferencia teste interno, beta e produção.
- Há procedimento documentado de rollback ou bloqueio de rollout.
- A esteira DevOps fica definida como gate obrigatório antes de qualquer publicação.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: formaliza o processo de CD e reduz risco operacional de publicação.
