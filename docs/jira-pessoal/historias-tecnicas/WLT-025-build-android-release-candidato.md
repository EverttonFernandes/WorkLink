# WLT-025 — Build Android e release candidate instalável

## Objetivo

Gerar artefatos Android instaláveis pela pipeline para permitir testes manuais e internos antes da publicação na Google Play Store.

## Valor técnico

O projeto precisa provar que o app não apenas passa em testes, mas também gera um pacote Android consumível fora do ambiente de desenvolvimento. Esta história cria o primeiro fluxo de release candidate Android.

## RNFs relacionados

- RNF01
- RNF06
- RNF13
- RNF14

## Escopo incluído

- Criar job ou etapa dedicada para gerar APK debug/release candidate.
- Publicar APK como artifact do GitHub Actions.
- Registrar versão, commit e ambiente do build.
- Validar que o artifact pode ser instalado em emulador ou device de teste.
- Preparar base para build `aab` futuro da Play Store.
- Documentar como baixar e testar o artifact.

## Fora do escopo

- Upload automático para Google Play Console.
- Signing de produção definitivo.
- Distribuição pública.
- Build iOS.

## Critérios de aceite

- A pipeline gera artifact Android baixável.
- O artifact possui rastreabilidade para commit, branch e versão.
- Existe validação mínima de instalação ou execução em ambiente Android.
- O README ou guia de release explica o fluxo de teste antes da loja.
- O build não depende de ferramentas instaladas manualmente no notebook do usuário.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona capacidade nova de empacotamento e validação pré-publicação Android.
