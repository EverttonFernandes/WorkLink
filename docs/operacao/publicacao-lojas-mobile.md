# Publicacao mobile em lojas - Profissional Perto

## Objetivo

Este runbook orienta a preparacao do Profissional Perto para publicacao loja-first: Google Play Store primeiro, Apple App
Store em seguida.

## Links oficiais

| Tema | Link |
| ---- | ---- |
| Cadastro Play Console | `https://play.google.com/console/signup` |
| Play Console | `https://play.google.com/console` |
| Ajuda Google - comecar na Play Console | `https://support.google.com/googleplay/android-developer/answer/6112435` |
| Ajuda Google - criar e configurar app | `https://support.google.com/googleplay/android-developer/answer/9859152` |
| Ajuda Google - dashboard do app | `https://support.google.com/googleplay/android-developer/answer/9859454` |
| Ajuda Google - Data Safety | `https://support.google.com/googleplay/android-developer/answer/10787469` |
| Politica Google - User Data | `https://support.google.com/googleplay/android-developer/answer/9888076` |
| Apple Developer Program | `https://developer.apple.com/programs/` |
| Cadastro Apple Developer | `https://developer.apple.com/programs/enroll/` |

## Ordem cronologica oficial

1. Criar conta pessoal na Google Play Console.
2. Criar app `Profissional Perto` em modo rascunho.
3. Preencher metadados publicos iniciais.
4. Preencher declaracoes obrigatorias de conteudo e privacidade.
5. Preparar politica de privacidade publica em URL ativa.
6. Fechar backend cloud minimo e autenticacao real.
7. Gerar AAB release para teste interno.
8. Subir AAB na trilha Internal Testing.
9. Validar instalacao real via Play Store em aparelho Android.
10. Preparar Closed Testing com pelo menos 12 testers opt-in por 14 dias continuos se a conta pessoal for nova.
11. Solicitar acesso a producao na Play Console somente depois do teste fechado.
12. Repetir o caminho em Apple Developer/App Store Connect quando a etapa iOS iniciar.

## Acoes manuais do Everton

- Criar conta pessoal Google Play Console.
- Pagar a taxa unica de cadastro da Google, quando solicitada.
- Guardar acesso da conta Google com 2FA ativo.
- Informar ao projeto o email publico de suporte que sera exibido na loja.
- Reunir pelo menos 12 pessoas com conta Google para o teste fechado obrigatorio de conta pessoal nova.
- Decidir se o nome do publicador sera pessoa fisica inicialmente ou futura empresa.
- Nao criar app publico em producao antes de backend cloud, mensageria e politica de privacidade estarem aprovados.

## Acoes tecnicas do projeto

- Gerar AAB assinado e rastreavel.
- Gerar artifact `worklink-android-play-internal-<commit>` pela CI quando backend/store secrets estiverem presentes.
- Configurar `applicationId` definitivo Android: `br.com.worklink.mobile`.
- Controlar `versionName` e `versionCode`.
- Garantir que app de loja use API HTTPS estavel.
- Preparar Data Safety e politica de privacidade de acordo com dados realmente coletados.
- Criar evidencias visuais por tela antes do upload de screenshots.

## Bloqueadores de publicacao

- App abre sem backend ou sem massa minima real.
- Autenticacao real por SMS, WhatsApp ou email nao definida.
- Politica de privacidade ausente em URL publica.
- Data Safety divergente do comportamento real do app.
- Build assinado com chave de homologacao indevida para producao.
- Screenshots mostram tela fora dos prototipos aprovados.
- Suporte ao usuario inexistente.
- Conta de loja sem 2FA ou com titularidade incerta.

## Observacoes importantes

- Google Play distribui AAB; APK fica para instalacao manual/homologacao fora da loja.
- Play Store e App Store nao hospedam API, banco ou mensageria.
- Conta Apple individual exibe o nome legal como vendedor na App Store.
- Publicacao publica deve ser gradual e sempre precedida por teste interno.
- Contas pessoais novas da Google Play podem exigir Closed Testing com pelo menos 12 testers opt-in por 14 dias continuos
  antes de liberar producao.
