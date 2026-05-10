# WL-019 — Portfólio e fotos de trabalhos do profissional

## Objetivo

Permitir que o profissional associe evidências visuais ou arquivos de portfólio ao perfil público.

## Valor entregue

O cliente avalia melhor a experiência e o tipo de trabalho do profissional, aumentando confiança sem criar verificação
documental complexa.

## Personas

- Profissional
- Usuário cliente

## Requisitos relacionados

- RF13, RF20
- RN15, RN16

## Escopo incluído

- Associação de arquivos de portfólio ao perfil do profissional.
- Exibição de portfólio/fotos no perfil público.
- Reuso do storage seguro já existente.
- Limite simples de quantidade/tamanho/tipo de arquivo.

## Fora do escopo

- Galeria avançada.
- Edição de imagem.
- CDN produtiva.
- Curadoria manual complexa.

## Critérios de aceite

- Profissional deve conseguir adicionar item de portfólio ou foto de trabalho.
- Sistema deve validar tipo e tamanho do arquivo conforme política de storage.
- Perfil público deve exibir itens de portfólio aprovados/ativos.
- Dados sensíveis não devem ser expostos nos metadados dos arquivos.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: completa o perfil profissional com evidências visuais previstas no épico.
