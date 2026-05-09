# C4 Model — WorkLink V1

## C1 — Contexto

O WorkLink conecta usuários clientes a profissionais locais. Clientes descobrem profissionais por cidade, categoria e
palavra-chave, iniciam contato via WhatsApp, registram feedback, avaliam anonimamente e denunciam casos sensíveis.
Profissionais mantêm perfil, disponibilidade e dados progressivos. Administradores moderam denúncias, bloqueios e
métricas.

## C2 — Containers

- Mobile Flutter: experiência principal do cliente/profissional.
- API Spring Boot: regras de aplicação, autorização, auditoria, moderação e métricas.
- PostgreSQL: dados transacionais e histórico funcional.
- Redis: infraestrutura prevista para cache/sessões efêmeras quando necessário.
- MinIO/S3 compatível: armazenamento seguro de arquivos e evidências.
- GitHub Actions: CI/CD, testes e quality gates.

## C3 — Componentes principais da API

- `api`: controllers HTTP e DTOs.
- `application`: casos de uso, portas, autorização, auditoria, métricas e privacidade.
- `domain`: regras de negócio puras.
- `infrastructure`: JDBC, autenticação, storage, observabilidade e configurações externas.

## Restrições

- Framework não pode conter regra de negócio.
- Chamadas externas não podem acoplar casos de uso.
- Dados sensíveis devem ser minimizados, protegidos e auditáveis.
