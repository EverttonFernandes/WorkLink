# WL-001 — Fundação de categorias, cidades e profissionais mínimos

## Objetivo

Criar a base mínima para o WorkLink reconhecer categorias de serviço, cidades da região inicial e profissionais cadastrados com dados suficientes para aparecerem futuramente na descoberta.

## Valor entregue

A plataforma passa a ter dados estruturados para sustentar busca local, listagem e perfil profissional.

## Personas

- Profissional
- Usuário cliente
- Administrador

## Requisitos relacionados

- RF01, RF03, RF09, RF18, RF19, RF62, RF66
- RN15, RN16

## Escopo incluído

- Cadastro/estrutura de categorias de serviço.
- Cadastro/estrutura das cidades iniciais.
- Cadastro mínimo de profissional com nome, WhatsApp, cidade, categoria e descrição curta.
- Identificação de perfil básico.

## Fora do escopo

- Busca avançada.
- Perfil completo.
- Verificação documental.
- Ranking.
- Pagamento ou garantia do serviço.

## Critérios de aceite

- Deve existir forma de registrar categorias de serviço.
- Deve existir forma de registrar cidades da região inicial.
- Deve existir forma de registrar profissional com os campos mínimos.
- Profissional sem dados mínimos obrigatórios deve ser rejeitado.
- Profissional com dados mínimos deve ser classificado como perfil básico.
- Perfil básico não deve ser apresentado como garantia de qualidade.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona a fundação funcional do domínio.
