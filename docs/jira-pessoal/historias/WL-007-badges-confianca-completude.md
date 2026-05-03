# WL-007 — Badges de confiança e completude

## Objetivo

Exibir níveis de confiança progressiva com base nos dados informados pelo profissional.

## Valor entregue

O usuário recebe sinais objetivos de completude sem confundir badge com garantia de qualidade.

## Personas

- Usuário cliente
- Profissional

## Requisitos relacionados

- RF21, RF23, RF24, RF25, RF26
- RN15, RN16

## Escopo incluído

- Badge de perfil básico.
- Badge de perfil completo.
- Badge de perfil verificado quando critérios mínimos existirem.
- Indicação de telefone verificado.
- Indicação de documento informado quando aplicável.

## Fora do escopo

- Verificação documental avançada.
- Selo de qualidade garantida.
- Seguro ou garantia do serviço.

## Critérios de aceite

- Perfil com dados mínimos deve receber badge básico.
- Perfil com dados adicionais suficientes deve receber badge completo.
- Telefone validado deve ser sinalizado como verificado.
- Documento informado deve ser sinalizado sem expor dado sensível.
- Interface não deve declarar que badge garante qualidade do serviço.

## Protótipos de tela relacionados

- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`
- `docs/prototipos-de-tela/tela-cadastro-do-profissional.png`

### Requisitos não funcionais por tela

- badges não devem expor documento, telefone ou dado sensível;
- UI deve evitar qualquer texto que pareça garantia de qualidade;
- testes mobile devem cobrir exibição e ausência de badges conforme dados disponíveis.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona confiança progressiva ao produto.
