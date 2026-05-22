# WLT-032 — Massa regional de homologação mobile

## Objetivo

Corrigir o débito `DTM-003`, garantindo que a massa de homologação permita testar a região inicial do WorkLink V1.

## Valor técnico e de produto

O dono do produto precisa simular uso real na região carbonífera. A ausência de cidades previstas impede validar seleção de cidades, descoberta, filtros e listagem.

## Débito relacionado

- `DTM-003 — Massa de cidades incompleta para a região inicial`

## Escopo incluído

- Garantir massa de homologação para Charqueadas, São Jerônimo, Triunfo, Arroio dos Ratos, Eldorado do Sul, General Câmara e Butiá.
- Criar profissionais fictícios suficientes por cidade/categoria para testar descoberta e listagem.
- Validar que telas de seleção, busca e perfil exibem a região corretamente.
- Atualizar scripts/seeders de homologação e documentação do APK manual.

## Fora do escopo

- Expandir para cidades fora da região inicial sem decisão de produto.
- Criar ranking sofisticado ou recomendação automática.

## Critérios de aceite

- Todas as cidades da região inicial aparecem na massa de homologação.
- Há profissionais fictícios suficientes para testar busca com e sem resultado.
- O APK de homologação permite validar seleção de cidade e descoberta regional.
- Testes funcionais ou seed checks validam a presença da massa mínima.

## Entrega versionável

- Tipo sugerido: `PATCH`
- Motivo: corrige massa de homologação para tornar teste manual representativo.
