# WLT-022 — Integração HTTP Mobile com Backend

**Story**: [WLT-022-integracao-http-mobile-backend.md](../../entregas/WLT-022-integracao-http-mobile-backend.md)

**Versão**: MINOR

**Cronograma**: Semana 1 do Roadmap (Fase 1 — Integração & Builds)

---

## Objetivo

Substituir **100% dos dados mock/hardcoded** do app mobile por **chamadas reais HTTP** para o backend (worklink-api), permitindo que o app mobile funcione com dados genuínos.

**Resultado esperado**: App conectado ao backend real, navegando entre telas com dados dinâmicos.

---

## Plano de Execução

### Fase 1: Setup (Fresh Context)

- [x] 1.1 Criar estrutura de serviços HTTP em `lib/services/`
- [x] 1.2 Adicionar dependências `dio` e `flutter_dotenv`
- [x] 1.3 Criar configuração de ambiente versionável (`.env.example`)
- [x] 1.4 Implementar API client centralizado

### Fase 2: Serviços (TDD First)

- [x] 2.1 `authentication_service.dart` com testes
- [x] 2.2 `professional_service.dart` com testes
- [x] 2.3 `discovery_service.dart` com testes
- [x] 2.4 `contact_service.dart` com testes
- [x] 2.5 `review_service.dart` com testes
- [x] 2.6 `catalog_service.dart` e `report_service.dart` com testes

### Fase 3: Controllers (Refactor Mock → Real)

- [x] 3.1 `customer_authentication_controller.dart` → autenticação real via gateway
- [x] 3.2 `discovery_controller.dart` → dados reais carregados pelo gateway
- [x] 3.3 `professional_profile_controller.dart` → perfil real mapeado pelo gateway
- [x] 3.4 `professional_contact_controller.dart` → chamar `contact_service`
- [x] 3.5 `professional_review_controller.dart` → chamar `review_service`
- [x] 3.6 `professional_report_controller.dart` → chamar `report_service`
- [x] 3.7 `professional_registration_screen.dart` → cadastro real via `professional_service`

### Fase 4: Validação

- [x] 4.1 Testes unitários (fake HTTP) — 95%+ cobertura
- [x] 4.2 Testes de integração (backend real em Docker)
- [x] 4.3 Testes de tela atuais preservados
- [x] 4.4 Lint e code quality
- [x] 4.5 SRE: Docker Compose + backend rodando
- [x] 4.6 Security: Headers, autenticação Bearer, HTTPS em produção por configuração
- [x] 4.7 Arquitetura: Padrão de serviço, injeção de dependência
- [x] 4.8 Final Review: Código completo pronto para continuidade

---

## Arquitetura de Serviços

```
lib/services/
├── api_client.dart              # Client HTTP centralizado com interceptors
├── authentication_service.dart   # Endpoints de autenticação
├── professional_service.dart     # Endpoints de profissional
├── discovery_service.dart        # Endpoints de descoberta/busca
├── contact_service.dart          # Endpoints de contato/intenção
├── review_service.dart           # Endpoints de avaliação
├── report_service.dart           # Endpoints de denúncia/moderação
├── catalog_service.dart          # Endpoints de categorias/cidades
└── models/                       # Modelos de serialização JSON
    ├── authentication_model.dart
    ├── professional_model.dart
    ├── discovery_model.dart
    ├── contact_model.dart
    └── review_model.dart
```

---

## Estratégia de Testes (BDD + TDD)

### BDD Scenarios (Gherkin)

```gherkin
# features/http_integration.feature

Feature: Integração HTTP Mobile com Backend

  Scenario: Autenticar cliente com telefone
    Given o cliente acessa tela de autenticação
    When digita número de telefone válido
    And confirma código de OTP recebido
    Then chamada HTTP POST /api/v1/authentication/otp/verify é feita
    And token Bearer é armazenado localmente
    And cliente fica autenticado

  Scenario: Descobrir profissionais em cidade
    Given cliente autenticado navega para descoberta
    When seleciona cidade "Canoas"
    And aplica filtro de categoria "Eletricista"
    Then chamada HTTP GET /api/v1/professionals é feita com filtros reais
    And lista de profissionais é exibida com dados reais

  Scenario: Iniciar contato com profissional
    Given cliente visualiza perfil do profissional "Maria Eletricista"
    When clica botão "Chamar no WhatsApp"
    Then chamada HTTP POST /api/v1/contact-intentions é feita
    And número do WhatsApp é recuperado do backend
    And link do WhatsApp é aberto

  Scenario: Submeter avaliação após contato
    Given cliente contato profissional e retornou
    And recebeu prompt de feedback
    When preenche formulário com nota 5 e comentário
    And clica "Enviar"
    Then chamada HTTP POST /api/v1/professional-reviews é feita
    And avaliação é persistida no backend
    And feedback é exibido na UI
```

### TDD: Unit Tests com Mock

Cada controller/service terá testes com `mocktail`:

```dart
// test/unit/services/authentication_service_test.dart

void main() {
  group('AuthenticationService', () {

    late AuthenticationService service;
    late MockHttpClient mockClient;

    setUp(() {
      mockClient = MockHttpClient();
      service = AuthenticationService(httpClient: mockClient);
    });

    test('GIVEN valid phone WHEN verify called THEN POST to /phone-verify', () async {
      // GIVEN
      final phone = "+5551999999999";
      when(() => mockClient.post(...))
        .thenAnswer((_) async => Response(
          statusCode: 200,
          body: jsonEncode({'token': 'xyz', 'customerId': '123'}),
        ));

      // WHEN
      final result = await service.verifyPhoneOtp(phone, '123456');

      // THEN
      expect(result.token, 'xyz');
      verify(() => mockClient.post('/api/v1/authentication/phone-verify')).called(1);
    });

    test('GIVEN invalid code WHEN verify called THEN throw AuthenticationException', () async {
      // GIVEN
      when(() => mockClient.post(...))
        .thenAnswer((_) async => Response(statusCode: 401, body: jsonEncode({'error': 'Invalid'})));

      // WHEN + THEN
      expect(() => service.verifyPhoneOtp("+5551999999999", "000000"),
        throwsA(isA<AuthenticationException>()));
    });
  });
}
```

### Integration Tests com Backend Real

```dart
// test/integration/http_integration_test.dart

void main() {
  group('HTTP Integration — Real Backend', () {

    late HttpClient client;
    late DiscoveryService service;

    setUpAll(() {
      // Backend rodando em http://localhost:8080
      client = HttpClient(baseUrl: 'http://localhost:8080');
      service = DiscoveryService(client);
    });

    test('GIVEN backend running WHEN getProfessionals called THEN returns real data', () async {
      // WHEN
      final professionals = await service.getProfessionals(
        city: 'Canoas',
        category: 'Eletricista',
      );

      // THEN
      expect(professionals, isNotEmpty);
      expect(professionals.first.name, isNotEmpty);
      expect(professionals.first.phone, isNotEmpty);
    });
  });
}
```

---

## Security Checklist

- [x] Bearer token adicionado em todos os requests autenticados
- [ ] HTTPS em produção (http em dev apenas)
- [x] Sanitização de URLs e parameters
- [x] Timeout de 30 segundos em requests
- [x] Retry automático (3 tentativas) em falha transitória
- [ ] Erro genérico na UI (não expor stack trace)
- [x] Token removido ao logout
- [x] Validação de resposta JSON

---

## Exit Bar (Ralph Loop)

```yaml
exit_bar:
  lint: PASS # Flutter analyze, dart format
  unit_tests: PASS # 96.02% cobertura unitária mobile
  integration_tests: PASS # Contrato mobile x backend real em Docker
  mobile_tests: PASS # Testes de tela atuais preservados
  coverage: PASS # Min 95%
  security: PASS # Bearer, timeout, sanitização, retry e erros genéricos
  sre: PASS # Compose aplica migrations antes da integração mobile
  arch_review: PASS # Gateway isola UI dos serviços HTTP e Dio fica atrás de porta
  final_review: PASS # Pronto para próxima história
```

---

## Arquivos a Criar/Modificar

### Criar (Novos)

- `worklink-mobile/lib/services/api_client.dart`
- `worklink-mobile/lib/services/authentication_service.dart`
- `worklink-mobile/lib/services/professional_service.dart`
- `worklink-mobile/lib/services/discovery_service.dart`
- `worklink-mobile/lib/services/contact_service.dart`
- `worklink-mobile/lib/services/review_service.dart`
- `worklink-mobile/lib/services/models/*`
- `worklink-mobile/test/unit/services/*_test.dart`
- `worklink-mobile/test/integration/services/worklink_backend_contract_test.dart`
- `worklink-mobile/lib/app/worklink_application_gateway.dart`

### Modificar (Deps + Controllers)

- `worklink-mobile/pubspec.yaml` — adicionar `dio`, `flutter_dotenv`
- `worklink-mobile/lib/features/customer_authentication/customer_authentication_controller.dart` — callbacks remotos
- `worklink-mobile/lib/main.dart` — wiring real via `WorkLinkBackendGateway`
- `Makefile` e `compose.yml` — migrations antes da integração mobile

### Referências Normativas

- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md` — RN01/RN02, RN08, RN15

---

## 🚀 Próximos Passos

1. **Fresh Context**: Executor inicia com versionamento de artefatos
2. **TDD First**: Escrever testes antes do código
3. **BDD Scenarios**: Validar cada feature com dado real
4. **Incremental**: Serviço por serviço, controller por controller
5. **QA Gates**: Cada gate (lint, unit, integration, arch, security) aprovado
6. **Merge**: Commit com tag semântica após todos os gates PASS

---

**Horário de início**: 2026-05-10
**Status**: CONCLUIDO
