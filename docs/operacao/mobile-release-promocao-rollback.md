# Promocao de release e rollback mobile

## Objetivo

Este procedimento define como o WorkLink promove builds mobile entre desenvolvimento, teste interno, beta e producao
futura, mantendo rastreabilidade por tag, commit, artifact e gates DevOps.

## Fluxo oficial

| Estagio | Entrada | Gate obrigatorio | Saida |
| ------- | ------- | ---------------- | ----- |
| Desenvolvimento | Commit em `main` ou branch de PR | CI obrigatoria verde | APK tecnico ou build local para validacao inicial |
| Teste interno | Tag semantica e run verde em `main` | QA visual, produto mobile e assinatura/homologacao aprovados | APK Android em GitHub Release ou TestFlight interno |
| Beta | Versao aprovada em teste interno | Smoke test manual, checklist de privacidade e validacao do dono do produto | Closed/Open testing no Google Play ou TestFlight ampliado |
| Producao | Versao beta sem bloqueios | Aprovação explicita de release, changelog e plano de rollback | Publicacao gradual nas lojas |

## Checklist de promocao

- Tag semantica criada no mesmo commit da entrega.
- Workflow `WorkLink CI` concluido com sucesso no commit da tag.
- Artifact mobile rastreavel por nome, run id e checksum.
- `BUILD-METADATA.txt`, `SHA256SUMS` e guia de instalacao presentes.
- Classe do artifact compativel com o objetivo: `functional-homologation`, `release-candidate` ou `stable-homologation`.
- APK/IPA nao usa backend `not_configured`.
- Assinatura Android/iOS corresponde ao ambiente pretendido.
- QA visual e Product Manager aprovaram as telas quando houver mudanca de UI.
- Dono do produto aprovou promocao para teste interno, beta ou producao.
- Changelog da versao descreve mudancas, riscos e limitacoes conhecidas.

## Rastreabilidade minima

Toda promocao mobile precisa registrar:

- versao semantica;
- commit SHA;
- tag;
- GitHub Actions run id;
- nome do artifact de origem;
- checksum SHA-256;
- classe do artifact;
- backend usado em homologacao;
- decisao de aprovacao ou bloqueio.

## Separacao entre CI e CD manual

- CI obrigatoria roda automaticamente em `main` e PRs para provar qualidade, testes, build e seguranca.
- CD para teste interno, beta e producao e manual/aprovado ate existir conta de loja, secrets reais e governanca de
  custo.
- Publicacao automatica em producao permanece bloqueada por decisao operacional.

## Rollback e bloqueio de rollout

Android:

- Pausar rollout no Play Console se a versao apresentar falha critica.
- Rebaixar o percentual de distribuicao quando a loja permitir.
- Promover versao anterior conhecida como estavel se ela ainda estiver elegivel.
- Publicar hotfix com nova tag semantica quando rollback direto nao for suficiente.

iOS:

- Pausar distribuicao externa quando possivel.
- Remover build problematico do TestFlight quando o problema estiver em homologacao.
- Submeter hotfix acelerado quando a versao ja tiver passado por App Review.
- Manter release anterior disponivel para instalacoes que ainda nao atualizaram, sem prometer rollback instantaneo.

## Bloqueadores de publicacao

- CI vermelha ou incompleta.
- Artifact sem checksum ou sem metadados.
- Artifact tecnico descrito como release candidate.
- Backend de homologacao ausente.
- Assinatura debug em build promovido.
- Evidencia visual obrigatoria ausente em mudanca de tela.
- Secret, certificado ou provisioning profile versionado.
- Changelog ausente para versao candidata.

## Registro de decisao

Use o diretorio `artifacts/homologation/releases/<versao>/` para metadados promovidos e o GitHub Release para o binario
Android homologavel. O repositorio Git deve armazenar metadados e documentos, nao binarios sensiveis ou APKs gerados.
