# Entrega WLT-028 — Promoção de release e rollback mobile

## Resumo

A WLT-028 formaliza o fluxo de promoção, bloqueio e rollback mobile, mantendo publicação em loja como CD manual e
aprovado.

## Escopo entregue

- Procedimento `docs/operacao/mobile-release-promocao-rollback.md`.
- Guia `docs/release/release-mobile.md` atualizado.
- Gate local `make mobile-release-promotion-governance`.
- Script `scripts/check_mobile_release_promotion_governance.sh`.
- Teste sintético `scripts/test_mobile_release_promotion_governance.sh`.
- CI atualizada para validar governança de promoção/rollback no `Dependency scan`.

## Evidências

- `make mobile-release-promotion-governance`: PASS.
- `sh -n scripts/check_mobile_release_promotion_governance.sh`: PASS.
- `sh -n scripts/test_mobile_release_promotion_governance.sh`: PASS.
- `./scripts/test_mobile_release_promotion_governance.sh`: PASS.
- `git diff --check`: PASS.

## Limitações assumidas

- Publicação automática em produção permanece fora do escopo.
- Play Console, App Store Connect e TestFlight real dependem de contas, secrets e aprovações futuras.
