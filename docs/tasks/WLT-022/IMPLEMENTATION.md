# WLT-022 — Integração HTTP Mobile com Backend

**Story**: [WLT-022-integracao-http-mobile-backend.md](../../entregas/WLT-022-integracao-http-mobile-backend.md)

**Versão**: MINOR

**Cronograma**: Semana 1 do Roadmap (Fase 1 — Integração & Builds)

---

## 🎯 Objetivo

Substituir **100% dos dados mock/hardcoded** do app mobile por **chamadas reais HTTP** para o backend (worklink-api), permitindo que o app mobile funcione com dados genuínos.

**Resultado esperado**: App conectado ao backend real, navegando entre telas com dados dinâmicos.

---

## 📋 Plano de Execução

### Fase 1: Setup (Fresh Context)
- [ ] 1.1 Criar estrutura de serviços HTTP em `lib/services/`
- [ ] 1.2 Adicionar dependência `dio: ^1.0.0`
- [ ] 1.3 Criar configuração de ambiente (`.env`, `.env.production`)
- [ ] 1.4 Implementar API client centralizado

### Fase 2: Serviços (TDD First)
- [ ] 2.1 `authentication_service.dart` com testes
- [ ] 2.2 `professional_service.dart` com testes
- [ ] 2.3 `discovery_service.dart` com testes
- [ ] 2.4 `contact_service.dart` com testes
- [ ] 2.5 `review_service.dart` com testes

### Fase 3: Controllers (Refactor Mock → Real)
- [ ] 3.1 `customer_authentication_controller.dart` → chamar `authentication_service`
- [ ] 3.2 `discovery_controller.dart` → chamar `discovery_service`
- [ ] 3.3 `professional_profile_controller.dart` → chamar `professional_service`
- [ ] 3.4 `professional_contact_controller.dart` → chamar `contact_service`
- [ ] 3.5 `professional_review_controller.dart` → chamar `review_service`

### Fase 4: Validação
- [ ] 4.1 Testes unitários (mock HTTP) — 95%+ cobertura
- [ ] 4.2 Testes de integração (backend real em Docker)
- [ ] 4.3 Testes de tela (validar dados reais em UI)
- [ ] 4.4 Lint e code quality
- [ ] 4.5 SRE: Docker Compose + backend rodando
- [ ] 4.6 Security: Headers, autenticação Bearer, HTTPS
- [ ] 4.7 Arquitetura: Padrão de serviço, injeção de dependência
- [ ] 4.8 Final Review: Código completo pronto para produção

---

## 📐 Arquitetura de Serviços

```
lib/services/
├── api_client.dart              # Client HTTP centralizado com interceptors
├── authentication_service.dart   # Endpoints de autenticação
├── professional_service.dart     # Endpoints de profissional
├── discovery_service.dart        # Endpoints de descoberta/busca
├── contact_service.dart          # Endpoints de contato/intenção
├── review_service.dart           # Endpoints de avaliação
└── models/                       # Modelos de serialização JSON
    ├── authentication_model.dart
    ├── professional_model.dart
    ├── discovery_model.dart
    ├── contact_model.dart
    └── review_model.dart
```

---

## 🧪 Estratégia de Testes (BDD + TDD)

### BDD Scenarios (Gherkin)

```gherkin
# features/http_integration.feature

Feature: Integração HTTP Mobile com Backend
  
  Scenario: Autenticar cliente com telefone
    Given o cliente acessa tela de autenticação
    When digita número de telefone válido
    And confirma código de OTP recebido
    Then chamada HTTP POST /api/v1/authentication/phone-verify é feita
    And token Bearer é armazenado localmente
    And cliente fica autenticado
  
  Scenario: Descobrir profissionais em cidade
    Given cliente autenticado navega para descoberta
    When seleciona cidade "Canoas"
    And aplica filtro de categoria "Eletricista"
    Then chamada HTTP GET /api/v1/discovery?city=Canoas&category=Eletricista é feita
    And lista de profissionais é exibida com dados reais

  Scenario: Iniciar contato com profissional
    Given cliente visualiza perfil do profissional "Maria Eletricista"
    When clica botão "Chamar no WhatsApp"
    Then chamada HTTP POST /api/v1/contacts com intenção é feita
    And número do WhatsApp é recuperado do backend
    And link do WhatsApp é aberto

  Scenario: Submeter avaliação após contato
    Given cliente contato profissional e retornou
    And recebeu prompt de feedback
    When preenche formulário com nota 5 e comentário
    And clica "Enviar"
    Then chamada HTTP POST /api/v1/reviews é feita
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

## 🔐 Security Checklist

- [ ] Bearer token adicionado em todos os requests autenticados
- [ ] HTTPS em produção (http em dev apenas)
- [ ] Sanitização de URLs e parameters
- [ ] Timeout de 30 segundos em requests
- [ ] Retry automático (3 tentativas) em falha transitória
- [ ] Erro genérico na UI (não expor stack trace)
- [ ] Token removido ao logout
- [ ] Validação de resposta JSON

---

## 📋 Exit Bar (Ralph Loop)

```yaml
exit_bar:
  lint:              PENDING  # Flutter analyze, dart format
  unit_tests:        PENDING  # 95%+ cobertura
  integration_tests: PENDING  # Contra backend real
  mobile_tests:      PENDING  # Testes de tela
  coverage:          PENDING  # Min 95%
  security:          PENDING  # Bearer, timeout, sanitização
  sre:               PENDING  # Docker Compose, env vars
  arch_review:       PENDING  # Padrão de serviço, DI
  final_review:      PENDING  # Código pronto para produção
```

---

## 📁 Arquivos a Criar/Modificar

### Criar (Novos)
- `worklink-mobile/lib/services/api_client.dart`
- `worklink-mobile/lib/services/authentication_service.dart`
- `worklink-mobile/lib/services/professional_service.dart`
- `worklink-mobile/lib/services/discovery_service.dart`
- `worklink-mobile/lib/services/contact_service.dart`
- `worklink-mobile/lib/services/review_service.dart`
- `worklink-mobile/lib/services/models/*`
- `worklink-mobile/test/unit/services/*_test.dart`
- `worklink-mobile/test/integration/http_integration_test.dart`
- `worklink-mobile/.env`
- `worklink-mobile/.env.production`

### Modificar (Deps + Controllers)
- `worklink-mobile/pubspec.yaml` — adicionar `dio`, `flutter_dotenv`
- `worklink-mobile/lib/features/*/controller.dart` — substituir mock por serviços
- `.github/workflows/ci.yml` — adicionar backend em CI para testes

###Referências Normativas
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

**Horário de início**: [To be filled by Executor]
**Status**: [To be filled by Executor]
