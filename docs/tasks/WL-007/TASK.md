# WL-007 — Badges de confiança e completude

## História

Como usuário cliente, quero ver sinais objetivos de completude e confiança no perfil do profissional, para decidir melhor sem confundir badge com garantia de qualidade.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-007-badges-confianca-completude.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`
- `docs/prototipos-de-tela/tela-cadastro-do-profissional.png`

## Critérios de aceite

- [x] Perfil com dados mínimos deve receber badge básico.
- [x] Perfil com dados adicionais suficientes deve receber badge completo.
- [x] Telefone validado deve ser sinalizado como verificado.
- [x] Documento informado deve ser sinalizado sem expor dado sensível.
- [x] Interface não deve declarar que badge garante qualidade do serviço.

## Escopo técnico

- Expor documento como sinal booleano, não como valor sensível.
- Calcular badges de confiança e completude no domínio/modelo.
- Exibir badges no perfil público mobile sem prometer qualidade.
- Cobrir regras e tela com BDD/TDD.

## Fora do escopo

- Verificação documental avançada.
- Selo de qualidade garantida.
- Seguro ou garantia do serviço.
- Fluxo real de validação de telefone.
