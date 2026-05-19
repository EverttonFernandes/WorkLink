# Entrega WLT-027 — Governança de secrets e assinatura mobile

## Identificador

- História: `WLT-027`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Definir a governança de secrets, chaves e assinatura mobile para Android e iOS.

## Estado planejado

Esta entrega deve registrar inventário de secrets, política de rotação, arquivos ignorados e checks contra vazamento.

## Implementação inicial

- Adicionado `scripts/check_no_mobile_signing_secrets.sh` para bloquear versionamento acidental de arquivos sensíveis.
- Atualizado `.gitignore` com padrões de keystore, provisioning profile, certificados e configs mobile sensíveis.
- Adicionado gate `Mobile signing secrets guard` no job `dependency-scan`.

## Próximo endurecimento

- Documentar inventário completo de secrets por ambiente.
- Separar secrets opcionais de CI dos secrets obrigatórios para CD em lojas.
- Definir política de rotação e revogação para chaves Android e Apple.
