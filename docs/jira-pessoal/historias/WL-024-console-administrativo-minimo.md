# WL-024 — Console administrativo mínimo

## Objetivo

Disponibilizar uma interface interna mínima para que administradores usem as capacidades administrativas já expostas pela
API.

## Valor entregue

Administração consegue operar profissionais, denúncias, avaliações contestadas, categorias e métricas sem depender de
chamadas manuais de API.

## Personas

- Administrador

## Requisitos relacionados

- RF62, RF63, RF64, RF65, RF66, RF67

## Escopo incluído

- Tela/console interno para listar profissionais.
- Ação de bloquear/desbloquear profissional.
- Visualização de denúncias.
- Visualização e revisão de avaliações contestadas.
- Gestão mínima de categorias.
- Visualização de métricas básicas e funcionais.

## Fora do escopo

- Backoffice completo.
- Gestão avançada de usuários.
- Workflow jurídico.
- Dashboard executivo sofisticado.

## Critérios de aceite

- Administrador autenticado deve acessar o console.
- Usuário não administrador deve ser bloqueado.
- Console deve permitir operar bloqueio/desbloqueio.
- Console deve permitir visualizar denúncias e contestações.
- Console deve permitir acessar gestão mínima de categorias.
- Console deve exibir métricas administrativas e funcionais.

## Observação de produto

Não há protótipo administrativo em `docs/prototipos-de-tela/`. A implementação deve ser simples, interna e utilitária,
sem criar uma landing page ou backoffice complexo.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: transforma capacidades administrativas em operação utilizável.
