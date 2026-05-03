# Backend — Monólito modular hexagonal

## Objetivo

Definir a organização evolutiva do backend do WorkLink como monólito modular com DDD tático e Ports and Adapters.

A arquitetura deve proteger regra de negócio de frameworks, banco, cache, storage, mensageria, SDKs e APIs externas.

## Pacote raiz

```text
br.com.worklink
```

## Bounded contexts iniciais

| Contexto | Pacote | Responsabilidade |
|----------|--------|------------------|
| Identity & Access | `identityaccess` | autenticação, autorização, sessões, tokens, OTP e identidade |
| Customer | `customer` | usuário cliente |
| Professional | `professional` | profissional, perfil, portfólio e completude |
| Discovery | `discovery` | busca, filtros, listagem e ranking simples |
| Contact | `contact` | intenção de contato e redirecionamento para WhatsApp |
| Post-Contact Feedback | `postcontactfeedback` | feedback após contato e confirmação de serviço |
| Review & Reputation | `reviewreputation` | avaliações, reputação e sinais de qualidade |
| Report & Moderation | `reportmoderation` | denúncias, moderação, bloqueios e contestação |
| Location | `location` | cidades, localização e regiões atendidas |
| Notification | `notification` | notificações futuras |
| Admin | `admin` | funcionalidades administrativas |

## Estrutura interna por contexto

```text
br.com.worklink.<contexto>
├── api
├── application
├── domain
└── infrastructure
```

## Responsabilidades por camada

### `api`

Contém controllers, DTOs HTTP, presenters e componentes de entrada.

Pode:

- validar contrato HTTP;
- converter entrada externa para comandos da aplicação;
- chamar casos de uso;
- montar resposta externa.

Não pode:

- decidir regra de negócio;
- acessar repository JPA, cache, storage ou SDK externo diretamente;
- chamar adapter concreto para contornar caso de uso.

### `application`

Contém casos de uso, comandos, portas e orquestração.

Pode:

- coordenar fluxo do caso de uso;
- depender do domínio;
- depender de portas abstratas;
- abrir transações quando o framework exigir na borda de aplicação.

Não pode:

- conhecer adapter concreto;
- conhecer JPA repository concreto;
- chamar HTTP externo, Redis, storage ou SDK diretamente.

### `domain`

Contém entidades, value objects, specifications, invariantes e serviços de domínio.

Pode:

- expressar regra de negócio;
- proteger invariantes;
- validar transições de estado;
- compor specifications.

Não pode:

- depender de Spring;
- depender de JPA;
- depender de banco, cache, storage, fila, HTTP ou SDK externo;
- ler variável de ambiente;
- executar lógica de controller, job, consumer ou adapter.

### `infrastructure`

Contém adapters concretos.

Pode:

- implementar portas da aplicação;
- conhecer JPA, Redis, storage, HTTP, mensageria e SDKs;
- transformar dados externos em modelos aceitos pelo núcleo.

Não pode:

- decidir regra de negócio;
- forçar domínio ou aplicação a conhecer detalhe externo.

## Regra central de dependência

O fluxo de dependência deve preservar o núcleo:

```text
api -> application -> domain
infrastructure -> application/domain
```

O núcleo nunca deve depender da borda:

```text
domain -X-> infrastructure
domain -X-> api
application -X-> infrastructure
application -X-> api
```

## Guardrail automatizado

O backend deve manter teste ArchUnit para bloquear violações de fronteira.

O teste deve falhar quando:

- `domain` depender de frameworks ou infraestrutura;
- `application` depender de adapters concretos;
- `api` acessar infraestrutura diretamente;
- qualquer contexto criar acoplamento que ignore portas e adapters.

## Pragmatismo obrigatório

Não criar abstração sem comportamento real.

Esta arquitetura deve orientar crescimento incremental. Interfaces, adapters, entidades e casos de uso devem surgir quando uma história funcional ou técnica precisar deles.
