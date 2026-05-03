# Entrega WL-002 — Seleção de cidades e localização atual

## Resultado

Fluxo inicial de seleção regional criado para o usuário escolher uma ou mais cidades, limpar a seleção e usar localização atual opcional para receber sugestões próximas sem exigir login.

## Entregues

- Modelo de cidade de atendimento com coordenadas opcionais e validação de latitude/longitude.
- Migration `V003` adicionando coordenadas opcionais em `worklink.service_cities`.
- Portas de aplicação para carregar cidades por identificadores e sugerir cidades próximas.
- Caso de uso de prévia de seleção de cidades com localização transitória e limite de sugestões.
- Adapter JDBC com carregamento por múltiplos identificadores e ordenação por distância.
- Endpoints REST versionados para prévia e limpeza de seleção de cidades.
- Tela mobile mínima vinculada ao protótipo de seleção de cidades.
- Estado local mobile para seleção simples, seleção múltipla, limpeza e ativação de localização.
- Testes BDD/TDD de domínio, aplicação, API, infraestrutura, controller mobile, estado mobile e tela.

## Validações

- `make backend-static-analysis`
- `make backend-unit-test`
- `make backend-integration-test`
- `make mobile-static-analysis`
- `make mobile-unit-test`
- `make mobile-screen-test`
- `make mobile-integration-test`
- `make functional-test`

## Observações

- A localização atual é usada apenas como entrada transitória; não há persistência nem rastreamento contínuo.
- Georreferenciamento avançado, busca final de profissionais e integração real com GPS ficam para histórias futuras.
- `make functional-test` ainda retorna `N/A` porque os cenários funcionais reais não foram criados.
- `make mobile-integration-test` retorna `N/A` sem Android Emulator, iOS Simulator ou Chrome disponível no container.
