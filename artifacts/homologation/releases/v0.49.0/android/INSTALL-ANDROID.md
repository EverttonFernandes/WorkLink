# WorkLink Android Test Candidate

Este pacote contem um APK release assinado para validacao manual interna antes da publicacao em loja.

## Arquivos

- `worklink-android-homologation.apk`: APK para instalar no Android.
- `BUILD-METADATA.txt`: commit, branch, versao e run da pipeline.
- `SHA256SUMS`: checksum do APK.

## Como testar no Android

1. Baixe o artifact `worklink-android-homologation-<commit>` no run verde do GitHub Actions.
2. Extraia o arquivo zip.
3. Transfira `worklink-android-homologation.apk` para o aparelho Android.
4. No Android, permita instalacao de apps desconhecidos para o app usado para abrir o APK.
5. Abra `worklink-android-homologation.apk` e confirme a instalacao.
6. Abra o WorkLink e valide abertura, descoberta de profissionais, perfil e fluxos principais.

## Observacoes

- Classe do artifact: `functional-homologation`.
- Limitacoes conhecidas: depende do backend e da massa de homologacao informados; envios externos podem estar simulados.
- Este APK usa chave de homologacao Android e e somente para teste interno controlado.
- Tipo de build: `release`.
- Assinatura declarada: `android_homologation_key`.
- Modo de dados deste APK: `homologation-fullstack`.
- Backend configurado no build: `https://particular-deborah-vhs-emission.trycloudflare.com`.
- Este artifact prova empacotamento e instalacao. Para ser homologavel como produto, precisa passar pelo gate visual em `docs/qa/mobile-visual-homologation-gate.md`.
- Quando a historia possuir UI mobile, registre matriz, screenshots e veredito do especialista em `docs/tasks/<KEY>/visual-qa/` e valide com `make mobile-visual-qa-gate TASK_KEY=<KEY>`.
- Quando o modo for `preview`, o app navega sem backend publicado.
- Quando o modo for `homologation-fullstack`, backend, banco e massa de homologacao devem estar disponiveis no ambiente informado.
- Nao publique este APK na Google Play.
- Builds assinados para loja entram na etapa de governanca de secrets e assinatura mobile.
