# Governanca de homologacao de produto mobile

## Objetivo

Separar validacao tecnica de validacao de produto para APK, IPA e artifacts mobile.

## Classes oficiais

| Classe | Significado | Pode ir para teste humano de produto? | Pode ser release candidate? |
| ------ | ----------- | -------------------------------------- | --------------------------- |
| `technical-build` | Build para provar compilacao, assinatura, instalacao ou CI | Nao | Nao |
| `preview` | Build para explorar UI com dados locais/mockados | Apenas revisao exploratoria | Nao |
| `functional-homologation` | Build com backend/massa de homologacao e gate visual aprovado | Sim | Nao automaticamente |
| `release-candidate` | Candidato versionado para loja/teste controlado | Sim | Sim |
| `stable-homologation` | Versao semantica promovida e rastreavel para homologacao recorrente | Sim | Pode originar release candidate |

## Regras de bloqueio

- `technical-build` e `preview` nunca podem ser chamados de release candidate.
- `functional-homologation` precisa declarar backend, massa, limitações conhecidas e evidencias visuais.
- `release-candidate` precisa ter tag semantica, CI verde, artifact assinado conforme estrategia, checksums e gate visual
  aprovado.
- `stable-homologation` precisa estar ligado a uma versao semantica e a um pacote promovido/rastreavel.

## Campos obrigatorios no pacote

`BUILD-METADATA.txt` deve conter:

- `artifact_class`;
- `artifact`;
- `git_commit`;
- `git_tags`;
- `app_data_mode`;
- `api_base_url`;
- `known_limitations`.

`INSTALL-ANDROID.md` ou documento equivalente deve conter:

- classe do artifact;
- o que pode ser validado;
- limitacoes conhecidas;
- aviso quando nao for release candidate.

## Gate oficial

```bash
make mobile-product-homologation-gate ARTIFACT_DIR=artifacts/android-homologation-candidate
```

Esse gate valida metadados e instrucao de instalacao. Ele complementa, mas nao substitui, o gate visual da WLT-034.

## Papel do Product Manager e Final Reviewer

O Product Manager bloqueia qualquer pacote cuja classe nao permita o tipo de validacao solicitada.

O Final Reviewer bloqueia a historia quando `mobile_tests`, evidencia visual, metadados de artifact ou limitacoes
conhecidas estiverem ausentes ou incoerentes.
