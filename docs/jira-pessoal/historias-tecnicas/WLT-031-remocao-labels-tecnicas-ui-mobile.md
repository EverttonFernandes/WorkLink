# WLT-031 — Remoção de labels técnicas da UI mobile

## Objetivo

Corrigir o débito `DTM-002`, removendo enums, chaves internas, códigos técnicos e mensagens de debug da interface do usuário.

## Valor técnico e de produto

O usuário final não pode ver labels como `BASIC_PROFILE`. A UI precisa apresentar linguagem de produto clara, em português, coerente com a proposta do WorkLink.

## Débito relacionado

- `DTM-002 — Textos técnicos expostos ao usuário final`

## Escopo incluído

- Auditar telas mobile em busca de enums, códigos internos, chaves técnicas e textos em inglês indevidos.
- Criar mapeamentos explícitos de labels de produto.
- Corrigir listagem, perfil, cadastro, badges e estados visuais afetados.
- Cobrir labels com testes unitários/widget tests quando aplicável.
- Adicionar checklist anti-vazamento técnico no QA mobile.

## Fora do escopo

- Alterar a semântica de domínio dos enums internos.
- Mudar regras de confiança/completude fora do escopo da label exibida.

## Critérios de aceite

- Nenhuma tela mobile revisada exibe enum, chave interna, código técnico ou mensagem de debug.
- Labels de confiança/completude aparecem em português e coerentes com o produto.
- Testes protegem pelo menos os mapeamentos de labels críticos.
- QA registra verificação anti-label técnica como `PASS`.

## Entrega versionável

- Tipo sugerido: `PATCH`
- Motivo: corrige apresentação e copy sem adicionar nova funcionalidade.
