# WL-014 — Denúncia de profissional

## Objetivo

Permitir que usuário denuncie profissional por fraude, assédio, ameaça, perfil falso, serviço não realizado ou outro motivo.

## Valor entregue

A plataforma cria canal mínimo de proteção, confiança e moderação.

## Personas

- Usuário cliente
- Administrador
- Profissional

## Requisitos relacionados

- RF47, RF48, RF49, RF50, RF51, RF52
- RN13, RN14, RN20

## Escopo incluído

- Seleção de motivo.
- Descrição detalhada.
- Evidência opcional.
- Registro para análise posterior.
- Orientação para autoridades em casos graves.

## Fora do escopo

- Mediação completa de conflito.
- Decisão automática de culpa.
- Processo jurídico.

## Critérios de aceite

- Usuário deve conseguir abrir denúncia a partir do perfil.
- Denúncia deve exigir motivo.
- Denúncia deve permitir descrição.
- Evidência deve ser opcional.
- Denúncia deve ser registrada para análise.
- Casos graves devem exibir orientação para buscar autoridades.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-denunciar-profissional.png`

### Requisitos não funcionais por tela

- denúncia deve respeitar privacidade, segurança, rastreabilidade e minimização de dados;
- evidência opcional deve usar storage seguro quando enviada;
- casos graves devem orientar busca por autoridades sem prometer mediação jurídica;
- testes mobile devem cobrir motivo obrigatório, descrição, evidência opcional, envio e erro de upload.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona canal de denúncia e segurança comunitária.
