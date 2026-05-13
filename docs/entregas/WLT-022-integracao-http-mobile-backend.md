# Entrega WLT-022 — Integração HTTP mobile com backend

## Identificador

- História: `WLT-022`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo técnico

Substituir todos os dados mock do app mobile por chamadas reais HTTP para o backend (worklink-api), permitindo testes com dados genuine.

## Contexto

Atualmente o app mobile possui UI e controllers implementados, mas utiliza dados hardcoded (sample data). Esta história conecta o mobile ao backend real.

## Requisitos técnicos atendidos

- HTTP client moderno para Flutter (dio ou http).
- Configuração de endpoints baseUrl e ambientes.
- Serialização/desserialização JSON.
- Tratamento de erro e retry.
- Autenticação via token (Bearer).

## O que foi implementado

- **Dependência HTTP**: Adicionar `dio` e `flutter_dotenv` ao `pubspec.yaml`.

- **Serviço centralizado** `lib/services/`:
  - `api_client.dart` — cliente HTTP com interceptors.
  - `professional_service.dart` — endpoints de profissional.
  - `discovery_service.dart` — endpoints de descoberta.
  - `authentication_service.dart` — endpoints de auth.
  - `review_service.dart` — endpoints de avaliação.
  - `contact_service.dart` — endpoints de contato.
  - `catalog_service.dart` — endpoints de categorias e cidades.
  - `report_service.dart` — endpoints de denúncia.
  - `worklink_application_gateway.dart` — gateway da UI para serviços reais.

- **Configuração de ambiente**:
  - `.env` com `API_BASE_URL=http://192.168.x.x:8080/api` (local development).
  - `.env.production` com URL real.
  - Carregamento via `flutter_dotenv`.

- **Interceptors**:
  - Adicionar Bearer token em headers.
  - Log de request/response (dev).
  - Retry automático em falha transitória (3 tentativas).
  - Timeout de 30 segundos.

- **Serialização**:
  - Modelos Dart com `fromJson` e `toJson`.
  - Lista de profissionais, detalhes, avaliações, contatos.

- **Tratamento de erro**:
  - Try-catch em controllers.
  - UI feedback: loading, error, success, empty states.

- **Wiring real das telas**:
  - descoberta, perfil público, contato, feedback, avaliação e denúncia carregam/enviam dados reais.
  - autenticação por telefone usa endpoint real e preserva Bearer token no client compartilhado.
  - cadastro profissional usa IDs reais de categoria/cidade do catálogo.

- **Testes**:
  - Fake HTTP client em testes unitários.
  - Testes de parsing JSON.
  - Testes de retry e timeout.
  - Teste de contrato mobile x backend real em Docker.

## O que não foi implementado

- Cache persistente em SQLite (será WLT-025).
- Offline-first (será WLT-026).
- Rate limiting no cliente.

## Fluxos, telas, endpoints ou módulos envolvidos

- `worklink-mobile/lib/services/` — novos arquivos de serviço.
- `worklink-mobile/lib/app/worklink_application_gateway.dart` — orquestra serviços reais para a UI.
- `worklink-mobile/lib/features/customer_authentication/customer_authentication_controller.dart` — callbacks remotos.
- `worklink-mobile/lib/main.dart` — wiring real do app.
- `.env.example` e `worklink-mobile/.env.example` — configuração de ambiente.
- `pubspec.yaml` — adicionar `dio`, `flutter_dotenv`.
- `Makefile` e `compose.yml` — integração mobile aplica migrations antes do backend real.

## Estratégia de testes

- Unit: Mock dio, validar parsers e controllers.
- Integration: Backend real rodando, validar jornadas.
- E2E: Fluxo completo contra ambiente de teste remoto (WLT-023).

## Evidências de validação

- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura unitária mobile 96.02%.
- `make mobile-screen-test`: PASS.
- `make mobile-integration-test`: PASS para contrato mobile x backend real em Docker.
- Teste com Android Emulator, iOS Simulator ou Chrome permanece escopo da WLT-023.

## Riscos ou limitações remanescentes

- Latência de rede em device/emulador pode fazer testes mais lentos.
- Sem cache local, cada navegação refaz request.
- Header de autenticação pode não estar presente se usuário não autenticado ainda.
- Perfil do cliente mantém estado local até a WL-020 implementar preferências persistentes e profissionais salvos.

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/services/` — serviços HTTP.
- `worklink-mobile/lib/features/*/controller.dart` — atualização de controllers.
- `worklink-mobile/pubspec.yaml` — adicionar `dio`, `flutter_dotenv`.
- `worklink-mobile/.env` — configuração.

## Justificativa do versionamento

Entrega `MINOR` porque conecta camadas existentes sem quebra de compatibilidade. Necessária antes de publicação.
