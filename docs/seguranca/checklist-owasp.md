# Checklist OWASP — WorkLink V1

## API

- [x] Autenticação por token.
- [x] Autorização por perfil e ownership.
- [x] Validação de entrada em domínio e aplicação.
- [x] Tratamento uniforme de erros.
- [x] Logs sanitizados.
- [x] Auditoria de ações sensíveis.
- [ ] Rate limiting produtivo.
- [ ] WAF ou proteção equivalente em produção.

## Dados sensíveis

- [x] Documento profissional protegido.
- [x] Autoria interna de avaliação não exposta publicamente.
- [x] `.env` real ignorado pelo Git.
- [x] Evidências tratadas como arquivos controlados.
- [ ] Cofre de secrets produtivo configurado.

## Mobile

- [x] Estratégia de testes unitários e tela.
- [ ] Hardening de build release.
- [ ] Revisão de permissões Android/iOS antes da publicação.
