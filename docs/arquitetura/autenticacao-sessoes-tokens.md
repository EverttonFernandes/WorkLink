# Autenticação, Sessões e Tokens

## Contexto

A WLT-009 entrega a base técnica de autenticação segura para fluxos sensíveis do WorkLink V1. O objetivo é permitir autenticação por telefone com OTP sem vazar existência de conta, sem armazenar códigos ou tokens em texto puro e sem acoplar regras de aplicação a Spring, JDBC ou formato de token.

## Modelo

- `CustomerAccount`: conta técnica do cliente identificada por telefone normalizado e verificado.
- `AuthenticationOtpChallenge`: desafio de OTP com hash do código, expiração, contador de tentativas e bloqueio.
- `AuthenticationRefreshSession`: sessão de refresh token persistida apenas por hash, com expiração e revogação.

## Fluxos

### Solicitação de OTP

O caso de uso normaliza o telefone, gera OTP, protege o valor com `ProtectSensitiveValuePort` e persiste apenas o hash. A resposta HTTP é sempre genérica para reduzir enumeração de telefone.

### Verificação de OTP

O caso de uso busca desafio ativo, compara o hash do OTP informado, rejeita desafios expirados e bloqueia após falhas recorrentes. Em sucesso, cria ou reutiliza a conta do cliente e emite access token + refresh token.

### Refresh de sessão

O refresh token é opaco, gerado por `SecureRandom`, retornado uma única vez e armazenado somente pelo hash. Ao renovar a sessão, o token anterior é revogado e uma nova sessão é emitida.

### Revogação

A revogação recebe o refresh token, calcula seu hash e revoga a sessão correspondente quando válida. Erros usam resposta genérica para não expor estado interno.

## Fronteiras

- Casos de uso dependem apenas de portas de aplicação.
- JWT, relógio, geração de OTP/token e JDBC ficam em adaptadores de infraestrutura.
- O envio real de SMS fica fora desta entrega e deve entrar como porta/adaptador futuro.
- Autorização por perfil e ownership pertence à WLT-010.

## Segurança

- OTP não é persistido em texto puro.
- Refresh token não é persistido em texto puro.
- Access token é assinado com HMAC-SHA-256 por adaptador de infraestrutura.
- Segredos vêm de variáveis de ambiente.
- Tokens, OTP e hashes não são registrados em logs.
- Mensagens de erro evitam enumeração de telefone e sessão.
