# Autorização por Perfil e Ownership

## Contexto

A WLT-010 adiciona autorização explícita para endpoints sensíveis do WorkLink V1. A autenticação e emissão de tokens foi entregue na WLT-009; esta entrega consome o `access token` assinado e decide se o principal autenticado pode executar a ação solicitada.

## Decisão

A autorização fica na camada de aplicação, por ações sensíveis e ownership, sem acoplar regra de negócio ao Spring ou a controllers.

Componentes principais:

- `AuthenticatedPrincipal`: representa o principal autenticado com identificador e perfil.
- `AuthenticatedProfile`: perfis `CUSTOMER`, `PROFESSIONAL` e `ADMINISTRATOR`.
- `SensitiveAction`: catálogo explícito das ações sensíveis conhecidas.
- `AuthorizeSensitiveActionUseCase`: política de autorização e ownership.
- `ResolveAuthenticatedPrincipalUseCase`: porta de aplicação para resolver principal a partir do token.
- `AuthenticatedPrincipalHttpResolver`: adapter HTTP para extrair `Authorization: Bearer`.
- `HmacSha256JwtAccessTokenPrincipalResolverAdapter`: adapter de infraestrutura que valida assinatura e expiração do token HMAC-SHA-256.

## Regras Aplicadas

- Ações administrativas exigem `ADMINISTRATOR`.
- Alteração de perfil profissional exige `PROFESSIONAL` dono do perfil ou `ADMINISTRATOR`.
- Acesso a dados privados de cliente exige ownership.
- Acesso a autoria interna de avaliação anônima e denúncias de terceiros é tratado como ação administrativa.
- Falha de autenticação retorna `401`.
- Falha de autorização retorna `403`.
- Tokens inválidos, expirados ou adulterados não resolvem principal autenticado.

## Endpoints Protegidos Nesta Entrega

- `POST /api/v1/categories`
- `POST /api/v1/cities`
- `PATCH /api/v1/professionals/{professionalIdentifier}/profile`

As listagens públicas continuam abertas porque fazem parte da descoberta inicial do produto.

## Limites

- RBAC corporativo e IAM externo permanecem fora do escopo.
- Auditoria persistida das decisões sensíveis será entregue na WLT-011.
- Novos endpoints sensíveis devem declarar `SensitiveAction` e passar pela mesma política antes de executar o caso de uso.
