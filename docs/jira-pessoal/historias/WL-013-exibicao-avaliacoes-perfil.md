# WL-013 — Exibição de avaliações no perfil

## Objetivo

Exibir avaliações e comentários no perfil profissional sem expor autoria quando a avaliação for anônima.

## Valor entregue

Usuários conseguem consultar reputação antes de chamar um profissional.

## Personas

- Usuário cliente
- Profissional

## Requisitos relacionados

- RF40, RF41, RF42, RF43, RF45, RF46
- RN09, RN10, RN12, RN19, RN20

## Escopo incluído

- Exibição de nota média quando houver avaliações.
- Exibição de quantidade de avaliações.
- Exibição de comentários públicos.
- Respeito ao anonimato público.
- Solicitação de análise de avaliação considerada indevida pelo profissional.

## Fora do escopo

- Moderação completa de conflito.
- Exposição da autoria interna ao público.
- Algoritmo sofisticado de reputação.

## Critérios de aceite

- Perfil deve exibir avaliações existentes.
- Perfil deve exibir nota média quando houver dados.
- Avaliação anônima deve aparecer sem identidade pública.
- Comentários devem ser opcionais.
- Profissional deve conseguir solicitar análise de avaliação indevida.

## Protótipos de tela relacionados

- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`
- `docs/prototipos-de-tela/tela-avaliacao-concluida.png`

### Requisitos não funcionais por tela

- avaliação anônima nunca deve expor autoria pública;
- perfil deve lidar com ausência de avaliações sem quebrar layout;
- solicitação de análise deve ser rastreável quando aplicável;
- testes mobile devem cobrir nota média, comentários, anonimato e estado sem avaliações.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona reputação visível no perfil.
