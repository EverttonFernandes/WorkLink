# WL-020 — Profissionais salvos e preferências persistentes do cliente

## Objetivo

Persistir profissionais salvos e preferências básicas do usuário cliente, em vez de manter esses dados apenas como estado
de tela.

## Valor entregue

O cliente mantém sua lista de interesse e suas preferências entre sessões, tornando o perfil do usuário realmente útil.

## Personas

- Usuário cliente

## Requisitos relacionados

- RF55, RF57
- RF53, RF54, RF56
- RN01, RN02

## Escopo incluído

- Salvar e remover profissionais favoritos/salvos.
- Consultar profissionais salvos no perfil.
- Persistir preferências básicas de conta.
- Exibir preferências persistidas no mobile.

## Fora do escopo

- Listas compartilhadas.
- Recomendações automáticas.
- Preferências avançadas de privacidade.

## Critérios de aceite

- Usuário autenticado deve conseguir salvar profissional.
- Usuário autenticado deve conseguir remover profissional salvo.
- Perfil do usuário deve listar profissionais salvos a partir do backend.
- Preferências básicas devem ser persistidas e recarregadas entre sessões.
- Usuário não autenticado não deve alterar dados de perfil.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-perfil-do-cliente-usuario.png`
- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: fecha lacuna do perfil do usuário e melhora retenção da experiência.
