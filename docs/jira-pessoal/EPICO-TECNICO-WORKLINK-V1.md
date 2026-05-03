# Épico Técnico — WorkLink V1

## Objetivo

Construir uma fundação técnica simples, segura, testável, reproduzível e evolutiva para a V1 do WorkLink.

A fundação deve nascer com cobertura unitária mínima obrigatória de 95%, validada localmente quando possível e bloqueada pela pipeline de GitHub Actions.

Quando houver imagem Docker da aplicação, ela deve nascer com build multi-stage e runtime enxuto, preparada para produção e não apenas para facilitar execução local.

## Tese técnica

A V1 não deve nascer como arquitetura complexa demais, mas também não pode começar com decisões frágeis que comprometam segurança, LGPD, testes, operação, manutenção ou crescimento horizontal futuro.

## Stack definida

- Mobile: Flutter + Dart.
- Backend: Java 21 + Spring Boot.
- Banco principal: PostgreSQL.
- Cache: Redis quando fizer sentido.
- Storage: S3-compatible em produção e MinIO local.
- Arquitetura: monólito modular, DDD tático e arquitetura hexagonal.

## Entregas técnicas

1. Monorepo e stack base.
2. Arquitetura modular hexagonal.
3. PostgreSQL e consistência transacional.
4. Ambiente local reproduzível com Docker Compose e imagem de aplicação multi-stage.
5. Configuração segura e secrets.
6. Qualidade estática e clean code.
7. Testabilidade backend com cobertura unitária mínima de 95%.
8. Testabilidade mobile com cobertura unitária mínima de 95% quando houver suíte unitária.
9. Autenticação segura.
10. Autorização por perfil.
11. Rastreabilidade e auditoria.
12. LGPD e privacidade.
13. Criptografia e proteção de dados.
14. Storage seguro de arquivos.
15. Observabilidade.
16. Disponibilidade e escalabilidade stateless.
17. CI/CD com bloqueio de cobertura unitária abaixo de 95% e geração de imagem Docker multi-stage quando aplicável.
18. Documentação técnica, ADRs e release mobile.

## Fora do escopo técnico da V1

- microserviços
- Kubernetes obrigatório
- Kafka
- CQRS completo
- Event Sourcing
- OpenSearch obrigatório
- alta disponibilidade multi-região
- arquitetura distribuída complexa
- ranking com IA
- recomendação inteligente

## Versionamento

Histórias técnicas geralmente sugerem `MINOR`, pois adicionam capacidade operacional, arquitetural, segurança ou qualidade. O tipo final deve ser confirmado pelo Product Manager no fechamento da entrega.
