# WL-015 — Perfil do usuário cliente

## Objetivo

Permitir que o usuário visualize e gerencie informações básicas da conta, cidades selecionadas, profissionais salvos e avaliações enviadas.

## Valor entregue

O cliente ganha controle mínimo sobre sua experiência e histórico.

## Personas

- Usuário cliente

## Requisitos relacionados

- RF53, RF54, RF55, RF56, RF57
- RN01, RN02

## Escopo incluído

- Dados básicos: nome, telefone e cidade principal.
- Cidades selecionadas.
- Profissionais salvos.
- Avaliações enviadas.
- Preferências básicas.
- Privacidade e sair da conta.

## Fora do escopo

- Preferências avançadas.
- Gestão complexa de privacidade.
- Histórico financeiro.

## Critérios de aceite

- Usuário autenticado deve visualizar perfil.
- Usuário deve visualizar cidades selecionadas.
- Usuário deve visualizar profissionais salvos.
- Usuário deve visualizar avaliações enviadas.
- Usuário deve gerenciar preferências básicas.
- Usuário deve conseguir sair da conta.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-perfil-do-cliente-usuario.png`

### Requisitos não funcionais por tela

- tela deve exigir usuário autenticado;
- dados pessoais devem respeitar LGPD, minimização e proteção contra exposição indevida;
- avaliações anônimas enviadas devem preservar anonimato público;
- testes mobile devem cobrir visualização de dados, cidades, profissionais salvos, avaliações, preferências e logout.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona área mínima do cliente.
