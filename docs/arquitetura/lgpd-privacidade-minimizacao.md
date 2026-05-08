# LGPD, Privacidade e Minimização

## Objetivo

A WLT-012 estabelece privacidade por padrão e minimização de dados para a V1 do WorkLink. A entrega transforma parte da
política de privacidade em código testável e documenta decisões mínimas de retenção, exclusão e resposta a incidentes.

## Política executável

O pacote `application/privacy/usecase` define o inventário de dados pessoais da V1:

- campo tratado
- finalidade
- retenção
- nível de exposição
- permissão ou bloqueio de coleta

Dados fora do escopo, como conta bancária, cartão de crédito, documento com foto, localização contínua em tempo real e
informações financeiras, são classificados como não coletáveis na V1.

## Contrato HTTP

A API rejeita propriedades JSON desconhecidas via `spring.jackson.deserialization.fail-on-unknown-properties=true`.
Isso evita coleta silenciosa de dados que não fazem parte do contrato público do endpoint.

## Anonimato público

`ReviewAuthorPrivacyProjection` prepara o comportamento de avaliação anônima futura:

- autoria interna é obrigatória e preservada para rastreabilidade;
- identidade pública é removida quando a avaliação for anônima;
- avaliação identificada exige autor público e nome público.

## Acesso restrito

Dados sensíveis ou confidenciais ficam classificados como `OWNER_ONLY`, `INTERNAL_RESTRICTED`, `CONFIDENTIAL` ou
`NOT_EXPOSED`. Documento profissional permanece como hash e não pode ter exposição pública. Evidências de denúncia
ficam confidenciais.

## Exclusão de conta

A exclusão real de conta será implementada quando os fluxos de conta estiverem completos. O desenho técnico considerado
para a V1 é:

- remover ou anonimizar dados públicos vinculados ao titular quando não houver obrigação de retenção;
- manter apenas metadados de auditoria necessários para segurança, moderação e responsabilização;
- revogar sessões ativas;
- preservar rastreabilidade interna de avaliações anônimas sem expor identidade publicamente;
- registrar a ação em auditoria quando o fluxo existir.

## Incidentes de privacidade

Fluxo mínimo para incidentes:

- registrar data, sistema afetado, tipo de dado e severidade;
- bloquear novas exposições do dado afetado;
- preservar evidências técnicas com acesso restrito;
- avaliar impacto LGPD e necessidade de comunicação;
- registrar ação corretiva e responsável;
- revisar testes, logs e contratos para impedir reincidência.

## Limites

Portal LGPD, workflow completo de solicitação de titular, retenção automatizada e exclusão física completa ficam fora
desta história. A entrega cria os guardrails mínimos para as próximas histórias não coletarem dados fora do escopo.
