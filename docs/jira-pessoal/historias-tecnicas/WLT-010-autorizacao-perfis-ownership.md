# WLT-010 — Autorização por perfil e ownership

## Objetivo

Garantir controle de acesso por perfil e validação de ownership nos endpoints sensíveis.

## Valor técnico

Evita acesso indevido a dados administrativos, dados privados e autoria interna.

## RNFs relacionados

- RNF03, RNF17

## Escopo incluído

- Perfis cliente, profissional e administrador.
- Menor privilégio.
- Validação de ownership.
- Proteção contra IDOR.
- Restrição de dados administrativos.
- Restrição da autoria interna de avaliações anônimas.

## Fora do escopo

- RBAC corporativo complexo.
- IAM externo.

## Critérios de aceite

- Cliente não deve acessar dados administrativos.
- Cliente não deve acessar dados privados de outros usuários.
- Profissional não deve acessar denúncias internas contra terceiros.
- Profissional não deve acessar autoria interna de avaliação anônima.
- Endpoints sensíveis devem validar ownership e permissão.
- Ações administrativas devem exigir perfil adequado.

## Entrega versionável

- Tipo sugerido: `MINOR`
