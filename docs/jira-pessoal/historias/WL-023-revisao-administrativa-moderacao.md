# WL-023 — Revisão administrativa efetiva de denúncias e avaliações

## Objetivo

Permitir que administradores revisem denúncias e avaliações contestadas, registrando decisão mínima e status de
moderação.

## Valor entregue

A plataforma deixa de apenas listar casos de moderação e passa a ter um fluxo mínimo para tratar denúncias graves e
avaliações suspeitas.

## Personas

- Administrador
- Usuário cliente
- Profissional

## Requisitos relacionados

- RF64, RF65
- RN13, RN14, RN19, RN20

## Escopo incluído

- Status de denúncia.
- Status de contestação/análise de avaliação.
- Decisão administrativa mínima: manter, ocultar, resolver ou exigir ação adicional.
- Registro de auditoria da decisão.
- Priorização visual/lógica de denúncias graves.

## Fora do escopo

- Mediação completa de conflito.
- Jurídico interno.
- Atendimento humano complexo.
- Automação por IA.

## Critérios de aceite

- Administrador deve conseguir marcar denúncia como em análise, resolvida ou exigindo ação.
- Administrador deve conseguir registrar decisão sobre avaliação contestada.
- Avaliação considerada abusiva/suspeita deve poder ser ocultada da exibição pública.
- Toda decisão administrativa deve ser auditada.
- Denúncias graves devem permanecer identificáveis como prioritárias.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: fecha lacuna de moderação real prevista no épico.
