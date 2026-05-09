# WL-017 — Métricas funcionais e base para ranking futuro

## História

Como produto e administração, quero registrar sinais funcionais de descoberta, contato, responsividade, disponibilidade e
reputação para permitir evolução futura de ranking sem criar algoritmo sofisticado na V1.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-017-metricas-ranking-futuro.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`

## Critérios de aceite

- [x] Sistema deve registrar buscas realizadas.
- [x] Sistema deve registrar contatos iniciados por profissional, categoria e cidade.
- [x] Sistema deve registrar sinais de responsividade.
- [x] Sistema deve registrar sinais de disponibilidade.
- [x] Sistema deve manter dados suficientes para ranking futuro.
- [x] A V1 não deve implementar algoritmo sofisticado de ranking.

## Escopo técnico

- Persistir eventos de busca de profissionais.
- Expor leitura administrativa de sinais funcionais agregados.
- Reaproveitar dados existentes de contato, feedback, avaliações e disponibilidade.
- Registrar eventos operacionais seguros para descoberta.
- Cobrir comportamento com testes BDD/TDD.

## Fora do escopo

- Ranking algorítmico sofisticado.
- Recomendação por IA.
- OpenSearch obrigatório.
- Tela administrativa.

## Evidências

- `GET /api/v1/professionals` persiste eventos de busca em `worklink.professional_search_events`.
- `GET /api/v1/admin/functional-metrics` expõe sinais agregados para administração.
- Contatos são agregados por profissional, categoria e cidade a partir de `contact_intentions`.
- Responsividade é agregada a partir de `post_contact_feedbacks`.
- Reputação é agregada a partir de `professional_reviews`.
- Disponibilidade é agregada a partir de `professionals.availability_status`.
- `rankingAlgorithmEnabled=false` documenta que a V1 não possui algoritmo sofisticado de ranking.
- `make backend-static-analysis`: PASS.
- `make backend-unit-test`: PASS, 255 testes, cobertura mínima de 95% atendida.
- `make backend-integration-test`: PASS, Flyway até `v016`.
- `make backend-image-build`: PASS.
- `make functional-test`: N/A, ainda sem cenários funcionais reais.
- `git diff --check`: PASS.
- Varredura de segredos no diff adicionado: PASS.
