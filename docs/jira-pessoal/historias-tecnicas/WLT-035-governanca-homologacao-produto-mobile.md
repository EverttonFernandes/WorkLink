# WLT-035 — Governança de homologação de produto mobile

## Objetivo

Corrigir o débito `DTM-006`, impedindo que homologação técnica seja tratada como validação de produto.

## Valor técnico e de produto

Um artifact pode ser instalável e ainda assim não estar pronto para validação humana de produto. Esta história define a governança para classificar corretamente cada APK/IPA entregue.

## Débito relacionado

- `DTM-006 — Guardião de produto aprovou homologação técnica como se fosse validação de produto`

## Escopo incluído

- Definir classificação oficial de artifacts mobile: técnico, preview, homologação funcional, release candidate e versão estável de homologação.
- Atualizar documentação de entrega para explicitar o que pode ou não ser validado pelo dono do produto.
- Garantir que Product Manager e Final Reviewer bloqueiem artifacts que não representem os requisitos e protótipos.
- Registrar limitações conhecidas no pacote de homologação manual.

## Fora do escopo

- Corrigir visual, massa regional ou autenticação, cobertos por WLT-030 a WLT-034.
- Publicação em lojas.

## Critérios de aceite

- Toda entrega mobile manual declara sua classificação de artifact.
- Nenhum artifact técnico/preview pode ser chamado de release candidate.
- O pacote de homologação informa limitações conhecidas antes do teste manual.
- Product Manager e Final Reviewer possuem critério objetivo para bloquear homologação indevida.

## Entrega versionável

- Tipo sugerido: `PATCH`
- Motivo: corrige governança e classificação de artifacts sem adicionar nova funcionalidade.
