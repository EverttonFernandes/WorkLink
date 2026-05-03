# WL-011 — Pós-contato estruturado

## Objetivo

Coletar feedback após contato iniciado para medir resposta, tempo percebido e realização do serviço.

## Valor entregue

O WorkLink começa a medir responsividade em vez de depender apenas de nota média.

## Personas

- Usuário cliente
- Profissional

## Requisitos relacionados

- RF35, RF36, RF37, RF38, RF39, RF59
- RN18

## Escopo incluído

- Solicitação de feedback após contato iniciado.
- Registro se usuário conseguiu falar com o profissional.
- Registro se respondeu rápido, demorou ou não respondeu.
- Registro se serviço foi realizado.
- Armazenamento dos dados para indicadores futuros.

## Fora do escopo

- Ranking algorítmico sofisticado.
- Mediação de conflito.
- Garantia de execução.

## Critérios de aceite

- Feedback pós-contato só deve existir para contato previamente registrado.
- Usuário deve informar se conseguiu falar.
- Usuário deve informar responsividade percebida.
- Usuário deve informar se serviço foi realizado.
- Respostas devem ser armazenadas para sinais futuros.

## Protótipos de tela relacionados

- `docs/prototipos-de-tela/tela-falar-com-o-profissional.png`
- `docs/prototipos-de-tela/tela-avaliacao-profissional.png`

### Requisitos não funcionais por tela

- feedback só deve ser solicitado para contato rastreável;
- dados coletados devem respeitar minimização e finalidade;
- testes mobile devem cobrir pós-contato com resposta, sem resposta, serviço realizado e serviço não realizado.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona mensuração de responsividade.
