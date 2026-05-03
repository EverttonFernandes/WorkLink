# WL-005 — Perfil público detalhado do profissional

## Objetivo

Permitir que o usuário veja informações detalhadas do profissional antes de iniciar contato.

## Valor entregue

O usuário tem mais contexto para decidir se vale chamar o profissional.

## Personas

- Usuário cliente
- Profissional

## Requisitos relacionados

- RF11, RF12, RF13, RF29, RF45, RF47
- RN15, RN16

## Escopo incluído

- Perfil com foto, nome, categoria, cidade base e cidades atendidas.
- Descrição, serviços prestados, links úteis e portfólio quando disponíveis.
- WhatsApp como canal principal.
- Disponibilidade e badges quando disponíveis.
- Espaço para avaliações quando já existirem.
- Ação de denúncia.

## Fora do escopo

- Chat interno.
- Contrato ou pagamento.
- Verificação documental avançada.

## Critérios de aceite

- Usuário deve conseguir abrir perfil a partir da listagem.
- Perfil deve mostrar dados principais do profissional.
- Perfil deve mostrar serviços, cidades atendidas e disponibilidade quando cadastrados.
- Perfil deve deixar claro que completude não garante qualidade.
- Perfil deve oferecer acesso ao contato e à denúncia.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`

### Requisitos não funcionais por tela

- perfil não deve expor dados sensíveis internos do profissional;
- tela deve separar claramente sinais de completude de garantia de qualidade;
- chamadas para contato, denúncia e avaliações devem respeitar autenticação, autorização e rastreabilidade quando aplicável;
- testes mobile devem cobrir renderização do perfil, dados ausentes, ação de contato e ação de denúncia.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona a principal tela de decisão antes do contato.
