# Entrega WLT-027 — Governança de secrets e assinatura mobile

## Resumo

A WLT-027 estabelece o contrato operacional de secrets e assinatura mobile para Android e iOS sem versionar credenciais
reais.

## Escopo entregue

- Inventário de secrets por ambiente em `docs/operacao/mobile-secrets-assinatura.md`.
- Política de assinatura para debug, homologação/internal testing e produção.
- Orientação de rotação, revogação, ownership e recuperação.
- Gate local `make mobile-signing-governance`.
- Script `scripts/check_mobile_signing_governance.sh`.
- Teste sintético `scripts/test_mobile_signing_governance.sh`.
- CI atualizada para executar o gate no job `Dependency scan`.
- `.env.example` e `worklink-mobile/.env.example` atualizados com contrato sem valores reais.

## Evidências

- `make mobile-signing-governance`: PASS.
- `sh -n scripts/check_mobile_signing_governance.sh`: PASS.
- `sh -n scripts/test_mobile_signing_governance.sh`: PASS.
- `sh -n scripts/check_no_mobile_signing_secrets.sh`: PASS.
- `./scripts/test_mobile_signing_governance.sh`: PASS.
- `git diff --check`: PASS.
- Auditoria local com `rg` confirmou ausência de chaves privadas, tokens e blobs base64 reais no diff.

## Limitações assumidas

- A história não cria contas comerciais nem certificados reais.
- Upload automático para lojas permanece fora do escopo.
- Secrets reais devem ser configurados somente no GitHub, preferencialmente por environment protegido.
