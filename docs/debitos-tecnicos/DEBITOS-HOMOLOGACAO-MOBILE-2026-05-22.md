# Débitos de Homologação Mobile — 2026-05-22

## Contexto

O APK Android de homologação full-stack foi gerado e instalado com sucesso para teste manual, mas a validação humana revelou que a experiência entregue não representa adequadamente os requisitos funcionais e os protótipos de tela do WorkLink V1.

Este documento registra os débitos descobertos para que sejam atacados um a um, sem misturar infraestrutura com correção de produto.

## Decisão de governança

Antes de avançar em novas etapas de infraestrutura de publicação, TestFlight, Play Store, rollback ou release estável, o projeto deve tratar a divergência de produto/UX detectada no APK de homologação.

CI verde e APK instalável não são suficientes para considerar uma entrega mobile pronta para homologação manual.

## Débitos críticos

### DTM-001 — Aderência visual aos protótipos oficiais

- Severidade: `CRITICAL`
- Origem: homologação manual no POCO F5.
- Evidência: prints em `docs/prototipos-de-tela/print-das-telas-para-melhorar/`.
- Problema: telas reais usam aparência Material padrão/roxa e não seguem a identidade visual verde, hierarquia, cards e composição dos protótipos.
- Bloqueio: nenhum novo APK deve ser tratado como homologável sem checklist visual por tela.

### DTM-002 — Textos técnicos expostos ao usuário final

- Severidade: `CRITICAL`
- Evidência: listagem exibindo `BASIC_PROFILE`.
- Problema: enums e códigos internos estão vazando para a interface.
- Resultado esperado: labels de produto em português, por exemplo `Perfil básico`, `Perfil completo`, `Verificado`, conforme regra de negócio.

### DTM-003 — Massa de cidades incompleta para a região inicial

- Severidade: `HIGH`
- Evidência: seed de homologação cobre Charqueadas, São Jerônimo, Butiá e Arroio dos Ratos.
- Requisito esperado: incluir também Triunfo, Eldorado do Sul e General Câmara, conforme épico de negócio e protótipo de seleção de cidades.
- Resultado esperado: massa de homologação deve permitir validar descoberta regional real.

### DTM-004 — Canal de confirmação de código ambíguo

- Severidade: `HIGH`
- Evidência: tela informa que o código foi enviado para o telefone, sem deixar claro se é SMS, WhatsApp, email ou outro canal.
- Problema: a experiência promete uma confirmação sem explicitar o canal real suportado.
- Resultado esperado: decisão de produto e implementação coerente para o canal da V1: SMS, WhatsApp, email ou combinação aprovada.

### DTM-005 — Gate de QA visual inexistente ou insuficiente

- Severidade: `CRITICAL`
- Problema: a pipeline validou build, testes e artifact, mas não barrou divergência visual/funcional dos protótipos.
- Resultado esperado: QA deve exigir screenshots reais, matriz de protótipos e checklist de aderência antes de aprovar APK manual.

### DTM-006 — Guardião de produto aprovou homologação técnica como se fosse validação de produto

- Severidade: `CRITICAL`
- Problema: o Product Manager deveria ter bloqueado a entrega como "tecnicamente instalável, mas não homologável como produto".
- Resultado esperado: toda história mobile com APK deve declarar se o artifact é técnico, preview, homologação funcional ou release candidate.

## Ajustes de agentes realizados

- `ralph-loop/product-manager`: reforçado para bloquear APK manual sem aderência a protótipos, região e massa de dados.
- `ralph-loop/qa-agent`: reforçado com gate de aderência visual/produto para APK manual.
- `ralph-loop/mobile-frontend-specialist-agent`: criado como especialista dedicado em Flutter/UX mobile para validar
  protótipos, screenshots reais, identidade visual, microcopy, massa visual e evidências antes de QA e revisão final.
- `ralph-loop/final-reviewer-agent`: reforçado com lente de produto/protótipo e bloqueio de artifact instalável que não representa o produto.
- `ralph-loop/orquestrator`: reforçado para tratar APK manual como homologação de produto, não só infraestrutura.

## Próxima ação recomendada

Criar uma história específica antes de continuar novas etapas de infraestrutura:

`WLT-030 — Auditoria e correção de aderência funcional/visual do APK de homologação mobile`

Objetivo sugerido:

- mapear tela real versus protótipo;
- corrigir identidade visual base;
- remover labels técnicas;
- completar massa de homologação regional;
- decidir canal de OTP/verificação;
- gerar novo APK de homologação para validação manual no Android físico.
