# Entrega WLT-031 — Remoção de labels técnicas da UI mobile

## Resumo

A WLT-031 corrige o débito `DTM-002`, impedindo que códigos técnicos do backend apareçam como texto público na UI mobile.

Foram criados mapeamentos explícitos para:

- classificações de perfil (`COMPLETE`, `BASIC_PROFILE`, `INCOMPLETE`);
- categorias, cidades e profissionais sem mapa;
- status, decisões, motivos e sinais administrativos desconhecidos;
- cidade de descoberta sem UF, evitando exibição incompleta como `Cidade - `.

## Arquivos principais

- `worklink-mobile/lib/app/worklink_application_gateway.dart`
- `worklink-mobile/lib/features/discovery/discovery_professional.dart`
- `worklink-mobile/test/unit/app/worklink_application_gateway_test.dart`

## Evidências de QA

- `flutter analyze`: aprovado em `/tmp/worklink-mobile-wlt031-validate`
- `flutter test test/unit`: 153 testes aprovados
- `flutter test test/widget`: 74 testes aprovados
- `flutter test --coverage test/unit test/widget`: 227 testes aprovados, 95.89% de cobertura
- `make functional-test`: 4 suítes E2E aprovadas, 10 testes aprovados via Docker

## Gate anti-label técnica

Foi adicionado teste unitário que injeta códigos como `BASIC_PROFILE`, `UNKNOWN_SIGNAL`, `category-sem-mapa`, `city-sem-mapa` e `professional-sem-mapa`, garantindo que eles sejam convertidos para labels públicas antes de chegar à UI.

Durante o ciclo Ralph Loop, esse teste encontrou um vazamento real em denúncias/análises administrativas e a correção foi aplicada antes do fechamento.

## Resultado

Critérios de aceite atendidos:

- nenhuma tela mobile revisada expõe enum, chave interna, código técnico ou mensagem de debug;
- labels de confiança/completude aparecem em português;
- mapeamentos críticos estão protegidos por testes;
- QA anti-label técnica registrado como `PASS`.
