# WL-009 — Autenticação simplificada do cliente por telefone

## Objetivo

Permitir navegação sem login e exigir autenticação por telefone apenas antes de contato ou ação sensível.

## Valor entregue

O usuário descobre profissionais sem fricção e se identifica apenas quando precisa gerar rastreabilidade.

## Personas

- Usuário cliente

## Requisitos relacionados

- RF14, RF15, RF16, RF17
- RN01, RN02

## Escopo incluído

- Entrada por telefone.
- Verificação por código.
- Login de conta existente.
- Criação automática de conta para telefone novo.
- Bloqueio de contato/ação sensível sem autenticação.

## Fora do escopo

- Login social.
- Cadastro complexo.
- Autenticação obrigatória para navegação.

## Critérios de aceite

- Usuário deve navegar e buscar sem login.
- Ao tentar contato, usuário não autenticado deve ser direcionado para autenticação.
- Telefone verificado existente deve realizar login.
- Telefone verificado novo deve criar conta automaticamente.
- Usuário deve conseguir reenviar código e alterar telefone informado.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-verificao-usuario-cliente-profissional.png`
- `docs/prototipos-de-tela/tela-login-autenticacao.png`

### Requisitos não funcionais por tela

- autenticação deve proteger telefone, OTP, sessão e tentativas de abuso;
- mensagens de erro não devem permitir enumeração de telefone;
- tela deve manter navegação sem login para descoberta e exigir autenticação apenas em ação sensível;
- testes mobile devem cobrir telefone válido, telefone inválido, código incorreto, reenvio e troca de telefone.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona identidade mínima com baixa fricção.
