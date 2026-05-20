# WLT-029 — Homologação mobile full-stack e artifacts estáveis

## Objetivo

Permitir que o dono do produto valide manualmente uma versão semântica fechada do WorkLink em Android e iOS usando um ambiente de homologação completo, com aplicativo mobile, backend, banco de dados e massa funcional de profissionais fictícios da região carbonífera.

## Valor técnico

O APK de preview ajuda a abrir o aplicativo, mas não prova que a jornada real funciona. Esta história cria a esteira de homologação manual controlada, separando candidatos offline de candidatos full-stack e registrando artifacts estáveis para versões internas aprovadas.

## RNFs relacionados

- RNF01
- RNF06
- RNF13
- RNF14

## Escopo incluído

- Criar massa de homologação com cidades, categorias e profissionais fictícios de Charqueadas e região carbonífera.
- Criar comando reproduzível para subir backend, banco e dependências locais com massa de homologação.
- Criar build Android de homologação apontando para backend real configurável.
- Publicar artifact Android de homologação na pipeline quando a URL de homologação estiver configurada.
- Criar contrato da pasta `artifacts/homologation` para versões estáveis de homologação.
- Registrar metadados mínimos de versão, commit, URL de backend, checksum e modo de dados.
- Definir que o fluxo iOS deve ter paridade funcional antes de submissão à Apple Store.

## Fora do escopo

- Publicação automática em Google Play ou Apple App Store.
- Assinatura final de produção.
- Provisionamento definitivo de infraestrutura cloud de homologação.
- TestFlight completo, coberto pela WLT-026.

## Critérios de aceite

- Existe uma história oficial rastreável para homologação mobile full-stack.
- O projeto possui comando para preparar ambiente local de homologação com backend, banco e massa fake.
- O Android possui build candidate full-stack com `API_BASE_URL` configurável em tempo de build.
- A pipeline publica artifact Android de homologação quando `WORKLINK_HOMOLOGATION_API_BASE_URL` estiver configurada.
- A pasta `artifacts/homologation` documenta como versões estáveis devem ser guardadas no repositório.
- Nenhum APK preview/offline pode ser registrado como versão estável de homologação full-stack.
- O plano deixa explícito que iOS precisa validar o mesmo backend e a mesma massa antes de App Store.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona uma nova capacidade de homologação manual full-stack e governança de artifacts internos.
