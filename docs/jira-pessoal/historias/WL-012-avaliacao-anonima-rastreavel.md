# WL-012 — Avaliação anônima com rastreabilidade interna

## Objetivo

Permitir avaliação do profissional após serviço realizado, com opção de anonimato público e autoria interna preservada.

## Valor entregue

A plataforma cria reputação pública respeitando privacidade em cidades pequenas.

## Personas

- Usuário cliente
- Profissional
- Administrador

## Requisitos relacionados

- RF40, RF41, RF42, RF43, RF44
- RN09, RN10, RN11, RN12

## Escopo incluído

- Avaliação somente após contato registrado e serviço realizado.
- Nota em estrelas.
- Comentário opcional.
- Opção de avaliação anônima publicamente.
- Rastreabilidade interna da autoria.

## Fora do escopo

- Avaliação sem contato.
- Avaliação sem serviço realizado.
- Exposição pública da identidade em avaliação anônima.
- Moderação avançada.

## Critérios de aceite

- Usuário só deve avaliar após contato registrado.
- Usuário só deve avaliar se informar que serviço foi realizado.
- Nota em estrelas deve ser obrigatória.
- Comentário deve ser opcional.
- Avaliação anônima não deve expor autoria publicamente.
- Plataforma deve manter autoria interna rastreável.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-avaliacao-profissional.png`
- `docs/prototipos-de-tela/tela-avaliacao-concluida.png`

### Requisitos não funcionais por tela

- anonimato público deve ser preservado sem perder autoria interna rastreável;
- avaliação deve exigir contato registrado e serviço realizado;
- comentário opcional não deve expor dados sensíveis sem necessidade;
- testes mobile devem cobrir nota obrigatória, comentário opcional, anonimato, bloqueio sem contato elegível e confirmação de envio.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona reputação com privacidade e rastreabilidade.
