# Épico Técnico — WorkLink V1

## Nome do épico

WorkLink V1 — Requisitos não funcionais, arquitetura técnica e fundação evolutiva

---

## Objetivo do épico

Definir e implementar a fundação técnica da V1 do WorkLink, garantindo que a plataforma nasça simples o suficiente para validar o produto, mas com bases sólidas de segurança, qualidade, testabilidade, escalabilidade, observabilidade, manutenibilidade, privacidade e evolução arquitetural.

A V1 não deve ser um “tanque de guerra”, mas também não deve nascer com decisões frágeis que comprometam segurança, LGPD, manutenção futura ou crescimento horizontal.

---

## Visão técnica da V1

O WorkLink deve ser construído como uma plataforma mobile-first, com aplicativo Android/iOS, backend seguro, arquitetura modular, banco relacional consistente, ambiente local reproduzível, testes automatizados e práticas de engenharia preparadas para evolução.

A arquitetura inicial deve priorizar:

- simplicidade operacional;
- segurança desde o início;
- boa organização de domínio;
- fácil manutenção;
- testes automatizados;
- deploy previsível;
- escalabilidade horizontal futura;
- separação clara entre responsabilidades;
- proteção de dados pessoais e confidenciais;
- rastreabilidade de ações sensíveis;
- base evolutiva para crescimento regional e futuro crescimento nacional.

---

# Stack tecnológica definida

## Mobile

```text
Flutter + Dart
```

### Justificativa

Flutter e Dart serão utilizados para construção do aplicativo mobile multiplataforma, permitindo manter uma única base de código para Android e iOS.

### Objetivos

- evitar duplicação entre Android e iOS;
- reduzir esforço de manutenção;
- acelerar desenvolvimento da V1;
- permitir UI consistente entre plataformas;
- viabilizar publicação futura na Google Play Store e Apple App Store;
- facilitar testes automatizados de tela e comportamento;
- permitir evolução do app com menor custo de manutenção.

### Observação importante

Para builds iOS será necessário ambiente macOS com Xcode, que poderá ser:

- Mac físico;
- GitHub Actions com runner macOS;
- Codemagic;
- Bitrise;
- outro serviço de build em nuvem compatível.

---

## Backend

```text
Java 21 + Spring Boot
```

### Justificativa

O backend principal será desenvolvido em Java 21 com Spring Boot por ser uma stack robusta, segura, madura e adequada para sistemas com regras de negócio, consistência transacional, segurança, auditoria, moderação, reputação e evolução arquitetural.

### O backend deverá suportar

- autenticação;
- autorização;
- autenticidade e rastreabilidade de ações sensíveis;
- cadastro de usuários;
- cadastro de profissionais;
- busca;
- disponibilidade;
- contato via WhatsApp;
- pós-contato;
- avaliação anônima;
- denúncia;
- moderação;
- administração;
- métricas;
- base para ranking futuro.

---

## Banco de dados principal

```text
PostgreSQL
```

### Justificativa

PostgreSQL será a fonte da verdade da aplicação, pois o WorkLink possui domínio relacional e transacional.

O banco deverá armazenar dados como:

- usuários;
- profissionais;
- categorias;
- cidades;
- cidades atendidas;
- contatos iniciados;
- feedback pós-contato;
- avaliações;
- denúncias;
- moderação;
- disponibilidade;
- auditoria;
- administração;
- dados necessários para ranking futuro.

---

## Cache

```text
Redis
```

### Uso inicial

Redis não precisa ser obrigatório em todos os fluxos da V1, mas a aplicação deve estar preparada para usá-lo quando fizer sentido.

### Possíveis usos

- cache de categorias;
- cache de cidades;
- cache da home;
- cache de profissionais em destaque;
- cache de perfil público;
- rate limiting;
- armazenamento temporário de OTP, se fizer sentido;
- controle temporário de tentativas de autenticação;
- controle temporário de abuso em endpoints sensíveis.

---

## Storage de arquivos

```text
S3-compatible storage
```

### Produção

Utilizar serviço compatível com S3 para arquivos.

### Desenvolvimento local

Utilizar MinIO para simular storage S3 localmente.

### Tipos de arquivos

- foto de perfil profissional;
- fotos de portfólio;
- anexos de denúncia;
- evidências sensíveis;
- imagens relacionadas a moderação.

---

# Arquitetura da aplicação

## Padrão arquitetural

```text
Monólito Modular + DDD tático + Arquitetura Hexagonal
```

---

## Justificativa

A V1 do WorkLink ainda está em fase de validação, portanto não deve iniciar com microserviços.

Porém, o domínio possui regras relevantes e tendência de crescimento, então o backend deve nascer modular, organizado e preparado para separação futura de módulos, caso a escala, autonomia ou isolamento justifiquem essa evolução.

---

## Estrutura macro sugerida

```text
worklink-api
 ├── identity-access
 ├── customer
 ├── professional
 ├── discovery
 ├── contact
 ├── post-contact-feedback
 ├── review-reputation
 ├── report-moderation
 ├── location
 ├── notification
 └── admin
```

---

## Estrutura interna por módulo

```text
module/
 ├── domain/
 ├── application/
 ├── infrastructure/
 └── api/
```

---

## Camadas

```text
API / Controller
 ↓
Application / Use Cases
 ↓
Domain / Entities, Value Objects, Domain Services
 ↓
Ports
 ↓
Infrastructure / Adapters
 ↓
Database, Cache, Storage, External Services
```

---

## Diretriz arquitetural

O domínio não deve depender diretamente de:

- banco de dados;
- cache;
- storage;
- SMS/OTP provider;
- serviços externos;
- framework web;
- detalhes de infraestrutura.

Dependências externas devem ser acessadas por portas e adaptadores.

---

# Modularização e domínio

## Bounded contexts iniciais

### Identity & Access

Responsável por autenticação, autorização, sessão, tokens, OTP, controle de acesso e rastreabilidade de identidade.

### Customer

Responsável pelo usuário cliente.

### Professional

Responsável pelo profissional, perfil, dados profissionais, portfólio e completude.

### Discovery

Responsável por busca, filtros, listagem, ranking simples e descoberta.

### Contact

Responsável por intenção de contato e redirecionamento para WhatsApp.

### Post-Contact Feedback

Responsável por feedback após contato, resposta do profissional e confirmação de serviço realizado.

### Review & Reputation

Responsável por avaliações, comentários, avaliação anônima, reputação e sinais de qualidade.

### Report & Moderation

Responsável por denúncias, moderação, bloqueios, revisão e contestação.

### Location

Responsável por cidades, cidades próximas, localização e regiões atendidas.

### Notification

Responsável por notificações futuras.

### Admin

Responsável por funcionalidades administrativas mínimas.

---

# Banco de dados e consistência

## Banco fonte da verdade

PostgreSQL será a fonte principal de dados transacionais.

## Dados que exigem consistência forte

- cadastro de usuário;
- cadastro de profissional;
- autenticação;
- permissões;
- denúncias;
- avaliações;
- avaliação anônima com rastreabilidade;
- bloqueio de profissional;
- dados administrativos;
- contato iniciado;
- feedback pós-contato;
- status de disponibilidade;
- vínculos entre usuário, contato, avaliação e denúncia.

## Dados que podem ser eventualmente consistentes

- métricas agregadas;
- ranking calculado;
- profissionais em destaque;
- contadores de visualização;
- estatísticas públicas;
- taxa de resposta;
- indicadores derivados;
- cache da home;
- cache de perfis públicos.

## Diretriz CAP/PACELC

Para a V1, o sistema deve priorizar consistência em dados críticos e aceitar consistência eventual apenas em dados derivados, métricas, cache e rankings futuros.

---

# Cache

## Estratégia inicial

Adotar cache apenas onde houver ganho claro, evitando complexidade desnecessária.

## Padrão sugerido

```text
Cache-aside pattern
```

## Possíveis recursos com cache

- categorias;
- cidades;
- cidades próximas;
- home;
- profissionais em destaque;
- perfil público do profissional;
- filtros frequentes;
- rate limiting;
- tentativas de OTP.

## Cuidados

- badges de disponibilidade devem ter TTL curto;
- reputação e ranking não devem ficar desatualizados por longos períodos;
- bloqueio de profissional deve invalidar cache imediatamente;
- denúncia grave ou bloqueio deve refletir rapidamente na busca;
- dados sensíveis não devem ser armazenados em cache sem necessidade;
- cache não deve ser tratado como fonte da verdade.

---

# Escalabilidade

## Diretriz principal

A aplicação deve ser stateless desde a V1.

## Requisitos

- não armazenar sessão em memória local;
- utilizar tokens para autenticação;
- armazenar arquivos fora do container;
- manter banco externo;
- manter cache externo;
- configurar aplicação por variáveis de ambiente;
- expor health checks;
- suportar múltiplas instâncias da API;
- estar pronta para uso com load balancer;
- evitar acoplamento com filesystem local;
- evitar dependência de estado em memória da aplicação.

## Modelo futuro de escala horizontal

```text
Load Balancer
 ↓
WorkLink API instance 1
WorkLink API instance 2
WorkLink API instance 3
 ↓
PostgreSQL / Redis / Storage
```

## O que não será usado na V1

- microserviços;
- Kafka;
- CQRS completo;
- Event Sourcing;
- Kubernetes obrigatório;
- OpenSearch obrigatório;
- arquitetura distribuída complexa.

Essas tecnologias poderão ser avaliadas futuramente, conforme necessidade real.

---

# Disponibilidade

## Diretriz

A V1 deve ser simples, mas preparada para maior disponibilidade futura.

## Requisitos

- API stateless;
- health check;
- readiness check;
- graceful shutdown;
- retry controlado em integrações externas;
- timeouts configurados;
- tratamento de falhas externas;
- banco com backup;
- logs de erro;
- monitoramento básico;
- possibilidade futura de múltiplas instâncias;
- endpoints críticos resilientes a falhas parciais.

---

# Containers e ambiente local

## Tecnologias

```text
Docker
Docker Compose
Makefile
```

## Objetivo

Garantir ambiente local reproduzível, simples de subir e adequado para desenvolvimento, testes e CI/CD.

As imagens Docker de aplicação devem ser pensadas para produção, não apenas para "rodar localmente". Sempre que houver imagem da API, ela deve usar build multi-stage para separar claramente build e runtime, reduzindo tamanho, superfície de ataque e tempo de deploy.

## Serviços previstos no Docker Compose

```text
worklink-api
postgres
redis
minio
```

Opcionalmente no futuro:

```text
mailhog
localstack
observability stack
```

## Imagem Docker da aplicação

A imagem da API deve seguir estas diretrizes:

- usar Dockerfile multi-stage;
- separar estágio de build e estágio de runtime;
- aproveitar cache copiando primeiro arquivos de dependência e build;
- gerar artefato reproduzível antes de montar a imagem final;
- manter na imagem final apenas o necessário para executar a aplicação;
- não incluir código-fonte, caches, dependências de desenvolvimento ou ferramentas de build no runtime;
- definir variáveis e perfil de produção de forma explícita quando aplicável;
- executar com usuário não-root sempre que possível;
- expor `HEALTHCHECK` ou endpoint compatível com health/readiness;
- usar `.dockerignore` para excluir arquivos desnecessários, secrets, builds locais e diretórios temporários;
- manter PostgreSQL, Redis e storage fora do container da API.

Para backend Java 21/Spring Boot, o estágio final deve usar uma imagem de runtime/JRE enxuta e copiar apenas o artefato gerado no build.

## Makefile

O projeto deve possuir um Makefile didático e intuitivo.

### Comandos desejados

```bash
make up
make down
make restart
make logs
make api
make db
make redis
make storage
make test
make test-unit
make test-integration
make test-functional
make migrate
make clean
```

## Objetivos do Makefile

- facilitar onboarding;
- padronizar comandos;
- reduzir erros manuais;
- facilitar uso por agentes de IA;
- permitir subir tudo ou partes isoladas;
- permitir rodar testes com comandos simples;
- facilitar execução local e no CI;
- tornar o ambiente didático e previsível.

---

# Variáveis de ambiente e secrets

## Diretriz

Nenhum segredo deve ser salvo no código-fonte.

## Uso local

Utilizar:

```text
.env
.env.example
```

O `.env.example` deve conter valores fictícios e instruções.

O `.env` real não deve ser versionado.

## Configurações por variável de ambiente

- credenciais do banco;
- URL do banco;
- usuário do banco;
- senha do banco;
- JWT secret;
- chaves de criptografia;
- credenciais do storage;
- credenciais de OTP/SMS;
- URLs externas;
- configurações de cache;
- configurações de ambiente;
- configurações de CORS;
- flags de funcionalidade.

## Produção

Em produção, secrets devem ser gerenciados por solução segura, como:

- GitHub Actions Secrets;
- secrets do provedor cloud;
- AWS Secrets Manager;
- GCP Secret Manager;
- Azure Key Vault;
- Doppler;
- Vault;
- Kubernetes Secrets com External Secrets futuramente.

---

# Autenticação, autorização e autenticidade

## Diretriz

O WorkLink deve garantir que usuários, profissionais e administradores sejam autenticados de forma segura, que cada perfil tenha acesso apenas às funcionalidades permitidas e que ações sensíveis tenham autoria rastreável.

## Autenticação

A V1 deverá utilizar autenticação por telefone com código de verificação OTP.

### Requisitos

- OTP com expiração curta;
- OTP armazenado em hash, nunca em texto puro;
- limite de tentativas;
- rate limit por telefone, IP e dispositivo quando possível;
- invalidação do OTP após uso;
- proteção contra enumeração de usuários;
- geração de access token e refresh token após autenticação;
- refresh token armazenado de forma segura, preferencialmente em hash;
- rotação de refresh token;
- possibilidade de revogar sessões;
- logs de autenticação sem expor OTP, token ou dados sensíveis.

## Autorização

O sistema deve aplicar controle de acesso por perfil.

### Perfis iniciais

- cliente;
- profissional;
- administrador.

### Requisitos

- cliente não pode acessar dados administrativos;
- cliente não pode acessar dados privados de outros usuários;
- profissional não pode acessar denúncias internas contra terceiros;
- profissional não pode acessar autoria interna de avaliações anônimas;
- administrador deve ter acesso restrito conforme necessidade operacional;
- endpoints sensíveis devem validar ownership e permissões;
- ações administrativas devem ser auditáveis;
- permissões devem seguir o princípio do menor privilégio.

## Autenticidade e rastreabilidade

O sistema deve manter rastreabilidade de autoria para ações sensíveis.

### Ações que exigem autoria rastreável

- início de contato;
- envio de feedback pós-contato;
- criação de avaliação;
- avaliação anônima;
- denúncia;
- contestação de avaliação;
- alteração de perfil profissional;
- alteração de disponibilidade;
- bloqueio/desbloqueio de profissional;
- acesso administrativo a denúncia;
- acesso administrativo a evidências confidenciais;
- alteração de dados sensíveis;
- exclusão de conta.

## Avaliação anônima

A avaliação pode ser anônima publicamente, mas nunca deve ser anônima para a plataforma.

### Requisitos

- o público não deve ver a identidade do avaliador;
- o sistema deve manter autoria interna;
- apenas usuários autorizados devem conseguir consultar autoria interna;
- acessos administrativos à autoria devem ser auditados;
- a autoria interna não deve ser exposta em endpoints públicos;
- a modelagem deve reduzir risco de exposição acidental da identidade do avaliador.

## Sessões e tokens

### Requisitos

- access token com curta duração;
- refresh token com rotação;
- revogação de sessão;
- armazenamento seguro no app mobile;
- tokens nunca devem aparecer em logs;
- tokens devem ser invalidados em caso de suspeita de comprometimento;
- refresh token não deve ser salvo em texto puro;
- sessões devem poder ser revogadas pelo sistema.

## Auditoria de autenticação

O sistema deve registrar eventos de autenticação e ações sensíveis sem expor dados pessoais desnecessários.

### Eventos auditáveis

- login solicitado;
- OTP validado;
- falha recorrente de OTP;
- refresh token utilizado;
- sessão revogada;
- alteração de dados sensíveis;
- ação administrativa;
- tentativa de acesso indevido;
- bloqueio/desbloqueio de profissional;
- acesso a denúncia;
- acesso a evidência confidencial.

---

# Segurança da informação

## Diretrizes

A V1 deve nascer seguindo práticas de segurança desde o início, alinhadas a OWASP, LGPD e desenvolvimento seguro.

## Referências de segurança

- OWASP ASVS;
- OWASP API Security Top 10;
- OWASP MASVS para mobile;
- OWASP Secrets Management Cheat Sheet;
- OWASP Database Security Cheat Sheet;
- OWASP Logging Cheat Sheet.

## Requisitos gerais de segurança

- autenticação segura;
- autorização por perfil;
- proteção contra IDOR;
- validação de entrada;
- sanitização de saída;
- rate limiting;
- proteção contra brute force;
- proteção contra enumeração de usuários;
- logs sem dados sensíveis;
- controle de upload;
- armazenamento seguro de arquivos;
- mascaramento de dados sensíveis;
- criptografia em trânsito;
- criptografia em repouso;
- criptografia de campo para dados sensíveis;
- auditoria de ações administrativas;
- proteção de endpoints administrativos;
- proteção contra abuso em avaliações;
- proteção contra abuso em denúncias;
- proteção contra scraping de dados públicos;
- controle de CORS adequado;
- exposição mínima de dados em respostas públicas.

---

# LGPD e privacidade

## Princípios

- minimização de dados;
- finalidade clara;
- consentimento quando aplicável;
- transparência;
- controle de acesso;
- retenção definida;
- exclusão de conta;
- anonimização pública de avaliações;
- rastreabilidade interna;
- resposta a incidentes;
- privacidade por padrão;
- privacidade desde a concepção.

## Dados pessoais tratados

- nome;
- telefone;
- cidade;
- localização;
- CPF/CNPJ do profissional;
- avaliações;
- denúncias;
- anexos;
- fotos;
- links sociais;
- histórico de contato.

## Dados que não devem ser coletados na V1

- endereço completo do usuário;
- dados bancários;
- cartão de crédito;
- documentos com foto;
- localização contínua em tempo real;
- dados financeiros.

---

# Criptografia e proteção de dados

## Criptografia em trânsito

Todas as comunicações devem usar HTTPS/TLS.

## Criptografia em repouso

Devem ser criptografados em repouso:

- banco de dados;
- backups;
- storage;
- anexos;
- evidências de denúncia.

## Criptografia em nível de campo

Devem ser criptografados em campo ou protegidos com mecanismo equivalente:

- CPF/CNPJ;
- telefone do cliente;
- telefone do profissional, se não for exposto diretamente;
- descrição detalhada de denúncia;
- dados internos de moderação;
- metadados sensíveis;
- evidências confidenciais.

## Dados que devem ser hasheados

- OTP;
- refresh tokens;
- identificadores sensíveis usados para deduplicação;
- CPF/CNPJ normalizado para verificação de duplicidade, usando hash com segredo/pepper.

## Avaliação anônima

A avaliação pode ser anônima publicamente, mas deve manter rastreabilidade interna.

Diretriz:

```text
Público não vê quem avaliou.
A plataforma mantém registro interno do autor.
```

Recomendação de modelagem:

```text
reviews
review_authorship
```

---

# Armazenamento de arquivos

## Diretriz

Arquivos não devem ser armazenados diretamente no banco de dados.

## Produção

Utilizar storage S3-compatible.

## Local

Utilizar MinIO.

## Metadados no banco

O banco deve armazenar:

- identificador do arquivo;
- tipo;
- dono;
- finalidade;
- caminho interno;
- status;
- vínculo com entidade;
- data de criação;
- permissões;
- classificação do arquivo.

## Classificação dos arquivos

### Públicos ou semi-públicos

- foto do profissional;
- portfólio autorizado.

### Confidenciais

- anexos de denúncia;
- evidências;
- prints de conversa;
- arquivos relacionados a assédio, crime, ameaça ou golpe.

## Requisitos de segurança para arquivos

- bucket privado por padrão;
- URLs assinadas com expiração;
- validação de tipo;
- validação de tamanho;
- bloqueio de extensões perigosas;
- nomes internos aleatórios;
- não confiar no nome original do arquivo;
- criptografia;
- auditoria de acesso;
- retenção definida;
- remoção segura quando aplicável;
- separação lógica entre arquivos públicos e confidenciais;
- acesso restrito a anexos de denúncia;
- não expor caminho interno do storage diretamente ao usuário.

---

# Logs e auditoria

## Logs

A aplicação deve possuir logs estruturados.

## Dados proibidos em logs

- CPF/CNPJ;
- telefone completo;
- OTP;
- tokens;
- refresh tokens;
- payload de denúncia;
- evidências;
- localização precisa;
- secrets;
- dados sensíveis de moderação.

## Auditoria

Devem ser auditadas ações sensíveis:

- login administrativo;
- bloqueio de profissional;
- desbloqueio de profissional;
- acesso a denúncia;
- alteração de status de denúncia;
- revisão de avaliação;
- contestação de avaliação;
- alteração de dados sensíveis;
- exclusão de conta;
- acesso a evidências confidenciais;
- acesso à autoria interna de avaliação anônima.

---

# Resposta a incidentes

## Diretriz

A V1 deve possuir plano mínimo de resposta a incidentes de segurança e privacidade.

## Fluxo mínimo

1. Detectar incidente
2. Conter impacto
3. Avaliar dados afetados
4. Identificar titulares impactados
5. Corrigir causa
6. Avaliar necessidade de comunicação à ANPD e titulares
7. Documentar decisões
8. Melhorar controles

---

# Testes backend

## Testes unitários

### Tecnologias

```text
JUnit 5
Mockito
AssertJ
```

### Objetivo

Testar regras de domínio e casos de uso isolados.

### Cobertura mínima obrigatória

Todos os testes unitários backend devem gerar relatório de cobertura e manter cobertura mínima de 95%.

A pipeline de GitHub Actions deve falhar automaticamente quando a cobertura unitária backend ficar abaixo de 95%.

### Exemplos

- avaliação anônima;
- disponibilidade;
- níveis de confiança;
- regras de denúncia;
- pós-contato;
- bloqueio de profissional;
- completude de perfil;
- autorização de ações sensíveis.

## Testes de integração

### Tecnologias

```text
Spring Boot Test
Testcontainers
PostgreSQL container
Redis container quando necessário
```

### Objetivo

Testar integração real com dependências externas controladas.

### Exemplos

- repositories;
- migrations;
- constraints;
- transações;
- persistência de denúncias;
- rastreabilidade de avaliação anônima;
- bloqueios;
- queries de busca;
- invalidação de dados críticos;
- persistência de auditoria.

## Testes funcionais/E2E de API

### Tecnologias

```text
Jest.js
Axios ou Supertest
fixtures
seeders
Docker Compose
```

### Objetivo

Validar fluxos reais da API como caixa-preta.

### Diretriz

Os testes funcionais não devem importar código Java nem conhecer detalhes internos do backend.

Eles devem:

- preparar massa;
- chamar endpoints HTTP;
- validar respostas;
- validar efeitos esperados;
- limpar massa.

## Estrutura sugerida

```text
functional-tests/
 ├── fixtures/
 ├── seeders/
 ├── specs/
 └── jest.config.js
```

## Fluxos funcionais obrigatórios

- autenticação do cliente;
- cadastro do profissional;
- busca por cidade e categoria;
- contato via WhatsApp;
- pós-contato;
- avaliação anônima;
- denúncia;
- profissional bloqueado não aparecer na busca;
- profissional indisponível perder destaque;
- usuário não autenticado não iniciar contato;
- usuário não acessar dados privados de outro usuário;
- profissional não acessar dados administrativos;
- avaliação anônima não expor autoria publicamente.

---

# Testes mobile

## Testes unitários

### Tecnologias

```text
flutter_test
mocktail
```

### Objetivo

Testar lógica isolada do app Flutter.

### Cobertura mínima obrigatória

Todos os testes unitários mobile devem gerar relatório de cobertura e manter cobertura mínima de 95% para a lógica testável do app.

A pipeline de GitHub Actions deve falhar automaticamente quando a cobertura unitária mobile ficar abaixo de 95%, sempre que houver suíte mobile configurada.

## Testes de widget

### Tecnologia

```text
flutter_test
```

### Objetivo

Validar renderização e comportamento de componentes e telas.

### Exemplos

- botão de contato aparece;
- badge de disponibilidade aparece;
- flag de avaliação anônima aparece;
- estado vazio aparece;
- formulário inválido bloqueia envio;
- mensagem de denúncia é exibida corretamente;
- tela de código de verificação renderiza corretamente;
- tela de perfil profissional exibe sinais de confiança.

## Testes de integração/E2E mobile

### Tecnologia inicial

```text
integration_test
```

### Objetivo

Validar fluxos de tela completos em Android Emulator e iOS Simulator.

### Fluxos

- login por telefone;
- verificação por código;
- busca por categoria;
- seleção de cidade;
- perfil profissional;
- contato;
- pós-contato;
- avaliação anônima;
- denúncia;
- nenhum profissional encontrado.

## Testes E2E avançados futuros

### Tecnologia candidata

```text
Patrol
```

### Quando usar

Quando for necessário testar melhor:

- permissões nativas;
- localização;
- câmera;
- galeria;
- notificações push;
- interações específicas do sistema operacional.

---

# CI/CD

## Ferramenta principal

```text
GitHub Actions
```

## Pipeline backend

Deve executar:

- build;
- análise estática;
- testes unitários com cobertura mínima de 95%;
- testes de integração;
- testes funcionais;
- geração de imagem Docker multi-stage e enxuta para runtime;
- validação básica da imagem Docker quando aplicável;
- validação de migrations;
- scan de dependências;
- scan de segurança.

## Pipeline mobile

Deve executar:

- flutter analyze;
- flutter test com cobertura unitária mínima de 95% quando houver suíte unitária mobile;
- testes de widget;
- build Android;
- testes Android em emulador ou serviço externo;
- build iOS em runner macOS;
- testes iOS em iOS Simulator;
- publicação em track interna/TestFlight quando aplicável.

## Runners

```text
Linux runner:
- backend
- Android
- testes gerais

macOS runner:
- build iOS
- testes iOS
```

---

# Publicação mobile

## Android

Publicar via Google Play Console.

Artefato:

```text
AAB
```

## iOS

Publicar via App Store Connect.

Artefato:

```text
IPA
```

## Testes antes de produção

- Android internal testing track;
- iOS TestFlight;
- testes automatizados;
- teste manual final em aparelho real quando possível.

---

# Rollback e estratégia de release mobile

## Android

A Play Store permite rollout gradual e pausa de rollout.

## iOS

A App Store não possui rollback instantâneo equivalente a sistemas web. Correções normalmente exigem nova submissão de versão.

## Estratégia recomendada

- rollout gradual;
- track interna;
- TestFlight;
- feature flags quando fizer sentido;
- testes automatizados;
- checklist de release;
- versionamento semântico;
- capacidade de desativar funcionalidade crítica pelo backend quando possível.

---

# Observabilidade

## Requisitos mínimos

- logs estruturados;
- correlation id;
- health checks;
- métricas básicas;
- monitoramento de erros;
- rastreabilidade de fluxos críticos;
- alerta para falhas relevantes.

## Eventos importantes

- login solicitado;
- código validado;
- profissional cadastrado;
- perfil atualizado;
- contato iniciado;
- feedback pós-contato enviado;
- avaliação enviada;
- denúncia criada;
- profissional bloqueado;
- profissional desbloqueado;
- erro em storage;
- erro em OTP;
- erro em upload;
- tentativa de acesso não autorizado;
- falha recorrente de autenticação.

## Ferramentas candidatas

- Spring Boot Actuator;
- Micrometer;
- Prometheus;
- Grafana;
- Sentry;
- OpenTelemetry;
- ELK futuramente.

---

# Qualidade de código

## Backend

- Checkstyle;
- SpotBugs;
- PMD;
- SonarQube ou SonarCloud;
- cobertura unitária mínima de 95%;
- arquitetura validada por testes, quando aplicável;
- revisão automatizada por IA/workflow.

## Mobile

- flutter analyze;
- lint rules;
- padronização de widgets;
- componentes reutilizáveis;
- testes de widget;
- organização por features;
- design system inicial.

---

# Organização dos repositórios

## Opção recomendada para V1

```text
Monorepo
```

Estrutura:

```text
worklink/
 ├── worklink-api/
 ├── worklink-mobile/
 ├── functional-tests/
 ├── docker/
 ├── docs/
 ├── Makefile
 └── docker-compose.yml
```

## Justificativa

O monorepo facilita:

- coordenação inicial;
- uso por agentes de IA;
- versionamento conjunto;
- ambiente local unificado;
- testes integrados;
- documentação centralizada.

---

# Documentação técnica

## Documentos obrigatórios

- README principal;
- README da API;
- README do mobile;
- guia de ambiente local;
- guia de testes;
- guia de variáveis de ambiente;
- OpenAPI/Swagger;
- ADRs;
- C4 Model;
- threat model;
- checklist OWASP;
- política básica de segurança;
- guia de incidentes.

---

# ADRs iniciais recomendados

- ADR 001 — Escolha de Flutter + Dart para mobile
- ADR 002 — Escolha de Java 21 + Spring Boot para backend
- ADR 003 — Escolha de PostgreSQL como banco principal
- ADR 004 — Escolha de monólito modular com DDD e arquitetura hexagonal
- ADR 005 — Estratégia de storage S3-compatible + MinIO local
- ADR 006 — Estratégia de testes automatizados
- ADR 007 — Estratégia de segurança e proteção de dados
- ADR 008 — Estratégia de CI/CD
- ADR 009 — Estratégia de cache com Redis
- ADR 010 — Estratégia de avaliação anônima com rastreabilidade interna
- ADR 011 — Estratégia de autenticação por telefone com OTP
- ADR 012 — Estratégia de autorização e auditoria de ações sensíveis

---

# Requisitos não funcionais

## RNF01 — Multiplataforma mobile

O app deve ser desenvolvido com Flutter e Dart, permitindo publicação em Android e iOS a partir de uma base principal de código.

## RNF02 — Manutenibilidade

O sistema deve possuir arquitetura modular, organização por domínio e separação clara entre camada de API, aplicação, domínio e infraestrutura.

## RNF03 — Segurança

O sistema deve seguir práticas de desenvolvimento seguro baseadas em OWASP, incluindo autenticação, autorização, validação de entrada, proteção contra IDOR, logs seguros e controle de acesso.

## RNF04 — Privacidade e LGPD

O sistema deve aplicar minimização de dados, finalidade clara, proteção de dados sensíveis, anonimização pública quando aplicável e rastreabilidade interna.

## RNF05 — Criptografia

O sistema deve usar criptografia em trânsito, criptografia em repouso e criptografia de campo para dados sensíveis.

## RNF06 — Testabilidade

O sistema deve possuir testes unitários, testes de integração, testes funcionais de API, testes mobile de widget e testes mobile de integração. Toda suíte de testes unitários deve manter cobertura mínima de 95%.

## RNF07 — Ambiente reproduzível

O projeto deve permitir subir dependências locais com Docker Compose e Makefile. A imagem da aplicação deve usar Dockerfile multi-stage quando existir imagem de runtime da API.

## RNF08 — Configuração segura

O sistema deve usar variáveis de ambiente e não deve versionar secrets.

## RNF09 — Observabilidade

O sistema deve expor health checks, logs estruturados, métricas básicas e rastreabilidade de fluxos críticos.

## RNF10 — Escalabilidade horizontal

A API deve ser stateless e preparada para múltiplas instâncias atrás de um load balancer.

## RNF11 — Disponibilidade

A aplicação deve possuir health checks, timeouts, graceful shutdown e tratamento adequado de falhas externas.

## RNF12 — Armazenamento seguro de arquivos

Fotos e evidências devem ser armazenadas em storage externo, com controle de acesso e URLs assinadas quando necessário.

## RNF13 — Qualidade de código

O projeto deve possuir análise estática, lint, padronização, práticas de clean code e cobertura unitária mínima de 95%.

## RNF14 — CI/CD

O projeto deve possuir pipeline automatizada para build, testes, análise, validação de cobertura unitária mínima de 95%, geração de artefatos e geração de imagem Docker multi-stage quando aplicável.

## RNF15 — Evolução arquitetural

A arquitetura deve permitir evolução futura para cache avançado, filas, workers, OpenSearch, read replicas ou extração de serviços, caso haja necessidade real.

## RNF16 — Autenticação segura

O sistema deve autenticar usuarios de forma segura com credenciais protegidas por hash adequado, limite de tentativas,
protecao contra brute force e enumeracao, recuperacao de senha por token curto de uso unico e geracao segura de tokens.
Quando OTP for ativado futuramente, deve possuir curta duracao, armazenamento protegido, limite de tentativas e
invalidacao apos o uso.

## RNF17 — Autorização por perfil

O sistema deve garantir que clientes, profissionais e administradores acessem apenas os recursos permitidos ao seu perfil.

## RNF18 — Autenticidade e rastreabilidade

O sistema deve manter autoria rastreável para ações sensíveis, incluindo avaliações anônimas, denúncias, alterações de perfil e ações administrativas.

---

# Fora do escopo técnico da V1

A V1 não deve implementar inicialmente:

- microserviços;
- Kubernetes obrigatório;
- Kafka;
- CQRS completo;
- Event Sourcing;
- OpenSearch obrigatório;
- chat interno completo;
- pagamento dentro do app;
- ranking com IA;
- recomendação inteligente;
- verificação documental avançada;
- seguro de serviço;
- alta disponibilidade multi-região;
- arquitetura distribuída complexa.

---

# Decisões pendentes

Algumas decisões podem ser tomadas posteriormente sem bloquear o épico:

- cloud provider inicial;
- serviço de OTP/SMS;
- serviço definitivo de observabilidade;
- ferramenta final para build iOS;
- ferramenta final para gestão de secrets;
- provedor S3-compatible em produção;
- ferramenta de feature flags;
- ferramenta de monitoramento mobile.

---

# Critérios de sucesso técnico da V1

A fundação técnica da V1 será considerada bem-sucedida se:

- o app mobile rodar em Android e iOS;
- o backend expuser APIs seguras e testadas;
- o ambiente local subir com comandos simples;
- dados sensíveis forem protegidos;
- o banco for consistente e bem modelado;
- os fluxos críticos tiverem testes automatizados;
- o app possuir build e pipeline automatizados;
- houver logs, health checks e métricas mínimas;
- a aplicação puder rodar em múltiplas instâncias futuramente;
- a arquitetura permitir evolução sem reescrita completa;
- ações sensíveis tiverem autoria rastreável;
- avaliações anônimas preservarem anonimato público sem perder rastreabilidade interna;
- denúncias e evidências confidenciais forem protegidas adequadamente.

---

# Resumo executivo

A V1 técnica do WorkLink deverá nascer como uma plataforma mobile-first, usando Flutter/Dart no app, Java 21/Spring Boot no backend, PostgreSQL como fonte da verdade, Docker para ambiente local, testes automatizados, segurança baseada em OWASP e arquitetura modular com DDD e Hexagonal Architecture.

O objetivo técnico é construir uma base simples, segura, testável e evolutiva, capaz de validar o produto regionalmente sem impedir crescimento futuro.

A aplicação deve nascer preparada para proteger dados pessoais, manter autenticidade das ações sensíveis, suportar crescimento horizontal futuro e permitir evolução gradual para mecanismos mais sofisticados de ranking, reputação, observabilidade, cache e moderação.
