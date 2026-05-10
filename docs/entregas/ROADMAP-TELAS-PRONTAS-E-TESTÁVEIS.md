# Roadmap para Telas Prontas e Testáveis — WorkLink V1

## 📋 Situação Atual (10/05/2026)

### Backend ✅

- **Status**: Production-ready
- **Código**: 8.686 linhas Java, arquitetura hexagonal
- **Features**: WL-001 até WL-017 implementadas (17 histórias)
- **Testes**: 95%+ cobertura com testes unitários e integração
- **Banco**: 16+ migrações SQL com Flyway
- **Documentação**: OpenAPI, ADRs, testes E2E

### App Mobile 🟡

- **Status**: Prototipado, UI-ready, sem integração HTTP ainda
- **Código**: 3.925 linhas Dart com estrutura MVC
- **Telas**: 11 telas funcionais implementadas
- **Dados**: 100% mock/hardcoded (sem conexão ao backend)
- **Compilação**: Android `android/` não gerada ainda
- **Testes**: 95%+ cobertura com dados mock

### Infraestrutura & Pipeline 🟡

- **Docker Compose**: Completo (backend, DB, Redis, MinIO)
- **CI/CD**: GitHub Actions validando backend e mobile
- **Emulador**: Docker Compose sem emulador remoto
- **E2E**: Testes funcionais (Jest/Playwright) prontos no código

---

## 🎯 Roadmap para Completar (12 Histórias)

### Fase 1: Integração & Builds (2-3 semanas)

#### **WLT-022 — Integração HTTP Mobile com Backend**

Transforma app de mock para real:

- Adicionar `dio: ^1.0.0` ao pubspec.yaml
- Criar camada de serviços HTTP em `lib/services/`
- Substituir dados mock por chamadas reais
- Testes unitários com mock de HTTP
- Resultado: App conectado ao backend real

#### **WLT-020 — Projeto Nativo Mobile Android/iOS**

Gera estrutura nativa para publicação:

- `flutter create . --platforms=android,ios`
- Configuração de permissões (câmera, localização)
- Assinadores para debug e release
- BUILD-GUIDE para APK e iOS archive
- Resultado: APK compilável para Xiaomi (ou qualquer Android)

#### **WLT-023 — Emulador Remoto na Pipeline**

Automatiza testes em CI/CD:

- GitHub Actions com Android Emulator
- Testes de integração rodam em cada push
- Relatório de cobertura gerado
- Resultado: `make mobile-integration-test` funciona em CI

---

### Fase 2: Features Críticas do Mobile (3-4 semanas)

#### **WL-018 — Verificação de Telefone do Profissional**

Adiciona confiança progressiva:

- Fluxo de OTP durante cadastro
- Badge visível no perfil
- Integração com backend existente
- Testes completos

#### **WL-019 — Portfólio e Fotos**

Complementa perfil do profissional:

- Upload de fotos (max 5MB, 10 fotos)
- Salvamento em MinIO
- Galeria no perfil público
- Validações de tipo/tamanho

#### **WL-020 — Profissionais Salvos**

Melhora retenção:

- Botão "Salvar" em perfil
- Tela "Salvos" com filtros
- Sincronização ao login
- Persistência local

#### **WL-021 — Feedback Pós-Contato**

Aumenta taxa de avaliações:

- Prompt após 2 horas de contato
- Ligação entre contato e avaliação
- Testes E2E para timing

---

### Fase 3: Admin & Observabilidade (2-3 semanas)

#### **WL-022 — Métricas Funcionais**

Coleta dados para ranking:

- Eventos de descoberta, contato, avaliação
- Dashboard com agregações
- TTL para limpeza de dados antigos

#### **WL-023 — Revisão Administrativa**

Moderação de denúncias:

- Fila de denúncias sem revisão
- Ações: validar, rejeitar, solicitar prova
- Auditoria completa

#### **WL-024 — Console Admin**

Ponto central de monitoramento:

- Dashboard com métricas em tempo real
- Denúncias pendentes
- Links rápidos para moderação

---

### Fase 4: Validação & Release (1-2 semanas)

#### **WLT-019 — Specs Funcionais E2E Reais**

Valida integração completa:

- 45+ casos de teste (descoberta, auth, contato, avaliação, admin)
- Contra backend real em Docker
- Relatório HTML com evidência
- CI/CD executa automaticamente

#### **WLT-021 — Análise Estática Avançada**

Hardening de qualidade:

- SpotBugs para bugs potenciais
- PMD para violações de padrão
- SonarCloud para vulnerabilidades
- Gate em CI/CD

---

## 📊 Cronograma Estimado

```
Semana 1-3:  WLT-022, WLT-020, WLT-023 (Integração & Builds)
             ↓ App conectado ao backend, compilável, CI/CD com emulador

Semana 4-7:  WL-018, WL-019, WL-020, WL-021 (Features Críticas)
             ↓ Todas as telas mobile implementadas com dados reais

Semana 8-10: WL-022, WL-023, WL-024 (Admin & Observabilidade)
             ↓ Plataforma tem observabilidade, moderação, admin

Semana 11-12: WLT-019, WLT-021 (Validação & Release)
             ↓ Tudo testado, pronto para publicação
```

**Total**: ~12 semanas de desenvolvimento para completar MVP V1

---

## ✅ Critério de "Telas Prontas e Testáveis"

Uma tela é considerada **pronta e testável** quando:

1. ✅ **Implementada** — UI, controladore state management, navegação funcional
2. ✅ **Integrada** — Chamadas reais ao backend (não mock)
3. ✅ **Testada** — Testes unitários + tela + integração cobrindo 95%+
4. ✅ **Confiável** — Tratamento de erro, estados loading/empty/error
5. ✅ **Compilável** — APK gerado e testável em device real
6. ✅ **Validada** — Cenários E2E não floppy em emulador remoto
7. ✅ **Documentada** — Documentação de build, deploy, troubleshooting

---

## 🚀 Como Ativar as Histórias

### 1. **Mover para In Progress**

Cada história segue a ordem do `KANBAN-OFICIAL.md` (ordem 36-47).

### 2. **Branching**

```bash
# Por exemplo, para WLT-022
git checkout -b wlt-022/integracao-http-mobile
```

### 3. **Desenvolvimento**

- Implementar com TDD (testes primeiro)
- Cobertura mínima 95%
- Seguir padrões em `docs/spec-driven-development/`

### 4. **Validação**

```bash
# Local
make mobile-unit-test
make mobile-integration-test
make functional-test

# CI/CD (automático ao push)
# Verifica todos os gates
```

### 5. **Documentação**

Criar `docs/entregas/WL-XXX-*.md` ou `docs/entregas/WLT-XXX-*.md` com evidências de validação.

### 6. **Merge & Tag**

```bash
git tag v0.36.0  # semântico: MAJOR.MINOR.PATCH
git push origin main --tags
```

---

## 🎁 Arquivos Criados (10/05/2026)

| Arquivo                                                                  | Propósito                         |
| ------------------------------------------------------------------------ | --------------------------------- |
| `docs/entregas/WL-018-verificacao-telefone-profissional.md`              | História de negócio               |
| `docs/entregas/WL-019-portfolio-fotos-profissional.md`                   | História de negócio               |
| `docs/entregas/WL-020-profissionais-salvos-preferencias-persistentes.md` | História de negócio               |
| `docs/entregas/WL-021-solicitacao-pos-contato.md`                        | História de negócio               |
| `docs/entregas/WL-022-metricas-funcionais-detalhadas.md`                 | História de negócio               |
| `docs/entregas/WL-023-revisao-administrativa-moderacao.md`               | História de negócio               |
| `docs/entregas/WL-024-console-administrativo-minimo.md`                  | História de negócio               |
| `docs/entregas/WLT-019-specs-funcionais-e2e-reais.md`                    | História técnica                  |
| `docs/entregas/WLT-020-projeto-nativo-mobile-android-ios.md`             | História técnica                  |
| `docs/entregas/WLT-021-analise-estatica-avancada-backend.md`             | História técnica                  |
| `docs/entregas/WLT-022-integracao-http-mobile-backend.md`                | História técnica                  |
| `docs/entregas/WLT-023-emulador-remoto-ambiente-teste-online.md`         | História técnica                  |
| `docs/jira-pessoal/KANBAN-OFICIAL.md`                                    | Atualizado com 12 novas histórias |

---

## 📝 Próximos Passos

1. ✅ Revisar documentação de histórias
2. ✅ Validar dependências e compatibilidades
3. ➡️ **Iniciar WLT-022** (Integração HTTP) — torna app funcional
4. ➡️ **Iniciar WLT-020** (Projeto nativo) — torna app compilável
5. ➡️ **Iniciar WLT-023** (Emulador remoto) — torna testes automáticos

Após essas 3, o app estará **pronto para teste em device real com dados verdadeiros**.

---

## 🔗 Referências

- **Hashes base**: `edf13cfa...` e `8a24677f...`
- **Protótipos**: [MAPA-PROTOTIPOS-TELAS.md](MAPA-PROTOTIPOS-TELAS.md)
- **Arquitetura**: [docs/arquitetura/](../arquitetura/)
- **Padrões**: [docs/spec-driven-development/](../spec-driven-development/)
