# WLT-024 — Confiabilidade da CI mobile Android

## Objetivo

Transformar a execução mobile Android em uma validação confiável, repetível e diagnóstica na pipeline, garantindo que falhas de emulador, backend, rede ou Flutter sejam distinguíveis.

## Valor técnico

A `WLT-023` cria o caminho de execução com Android Emulator. Esta história endurece esse caminho para que a etapa DevOps seja tratada como gate real de produto, não como validação eventual ou instável.

## RNFs relacionados

- RNF03
- RNF06
- RNF13
- RNF14

## Escopo incluído

- Padronizar logs e evidências do job `mobile-emulator`.
- Publicar artifacts de diagnóstico quando o job falhar.
- Coletar logs de `adb`, emulador, Flutter, backend e Docker Compose.
- Separar claramente falhas de infraestrutura, build, teste e comunicação HTTP.
- Definir timeout, retries controlados e cleanup robusto.
- Documentar critérios objetivos para considerar a CI mobile Android confiável.

## Fora do escopo

- Publicação na Google Play Store.
- Assinatura de release Android.
- Execução em device farm externa.
- iOS Simulator em CI.

## Critérios de aceite

- Falhas no `mobile-emulator` deixam artifacts úteis para diagnóstico.
- O job diferencia erro de boot do emulador, erro de backend, erro de teste Flutter e erro de rede.
- O cleanup executa mesmo em falha parcial.
- A documentação explica como interpretar uma falha da CI mobile.
- A história `WLT-023` pode ser fechada com evidência remota ou esta história registra o motivo técnico remanescente.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: aumenta a confiabilidade operacional da validação mobile antes de publicação.
