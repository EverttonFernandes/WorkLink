# WLT-042 — Operação manual da Play Console para testes internos e fechados

## Objetivo

Executar e registrar a etapa manual da Google Play Console para o Profissional Perto, usando o `AAB` já preparado pela
WLT-039, até obter instalação real via `Internal testing` e trilha clara para `Closed testing` quando a conta pessoal nova
exigir.

## Valor técnico

A WLT-039 fecha o lado automatizável do projeto, mas a Google Play ainda exige ações humanas fora do repositório:
configuração de testers, upload do bundle, publicação da trilha, aceite de políticas e eventual teste fechado. Esta
história evita que esse trabalho fique implícito ou perdido.

## Decisão fechada

- A etapa manual da Play Console é rastreada como história própria.
- O artifact oficial de entrada é `worklink-android-play-internal-<commit>`.
- Nenhum avanço para publicação pública acontece sem evidência de instalação real pela Play Store.

## Escopo incluído

- Configurar `Testing > Internal testing` na Play Console.
- Baixar e conferir o artifact gerado pela CI.
- Subir o `.aab` correto na trilha interna.
- Configurar lista de testers internos.
- Publicar a release interna e validar instalação real em aparelho Android.
- Registrar resultado do smoke test manual do dono do produto.
- Preparar e executar `Closed testing` quando a conta pessoal nova exigir.
- Registrar bloqueios operacionais, reprovações e evidências.

## Como fazer

1. Garantir que a `WLT-037` tenha fornecido backend HTTPS estável.
2. Garantir que a `WLT-039` tenha gerado um run verde com artifact `worklink-android-play-internal-<commit>`.
3. Baixar o artifact da CI e conferir `BUILD-METADATA.txt` e `SHA256SUMS`.
4. Abrir a Play Console no app `Profissional Perto`.
5. Entrar em `Testing > Internal testing`.
6. Criar ou selecionar a release interna.
7. Enviar o `.aab` do artifact.
8. Configurar os testers internos.
9. Publicar a trilha.
10. Instalar o app pela Play Store no aparelho real.
11. Executar smoke test manual.
12. Se a Google exigir, configurar `Closed testing` com pelo menos 12 testers por 14 dias contínuos.
13. Registrar evidências, feedbacks e bloqueios.

## Dependências

- WLT-037 com backend cloud mínimo pronto.
- WLT-039 com artifact AAB rastreável pronto.
- Conta Google Play Console criada e apta.
- Metadados e políticas mínimas da WLT-036 já preenchidos.

## Fora do escopo

- Automação de upload em produção.
- Publicação pública imediata.
- TestFlight/App Store.
- Marketing ou aquisição de usuários.

## Critérios de aceite

- Checklist manual da Play Console preenchido.
- Artifact correto da CI conferido antes do upload.
- Instalação via Play Store Internal Testing comprovada em Android real.
- Smoke test manual com veredito registrado.
- Closed Testing planejado ou iniciado quando exigido pela Google.
- Bloqueios finais documentados com clareza se a trilha não puder avançar.

## Evidências esperadas

- Run da CI usado como origem do `.aab`.
- `BUILD-METADATA.txt` e `SHA256SUMS` conferidos.
- Capturas ou registro textual do upload/publicação da trilha.
- Registro do smoke test manual.
- Lista de pendências para seguir à produção.

## Entrega versionável

- Tipo sugerido: `PATCH`
- Motivo: história operacional/manual que valida e destrava a sequência de loja sem introduzir nova capacidade de código.
