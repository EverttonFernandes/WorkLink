# WL-017 — Métricas funcionais e base para ranking futuro

## Resumo

Entrega da base analítica funcional da V1 para registrar buscas e consultar sinais agregados de descoberta, contato,
responsividade, disponibilidade e reputação, preparando evolução futura de ranking sem introduzir algoritmo sofisticado.

## Valor entregue

- Buscas por profissionais passam a ser persistidas.
- Administração consulta métricas funcionais agregadas.
- Contatos iniciados são agregados por profissional, categoria e cidade.
- Feedbacks pós-contato fornecem sinais de responsividade.
- Disponibilidade dos profissionais é contabilizada.
- Avaliações fornecem sinais de reputação.
- A resposta explicita `rankingAlgorithmEnabled=false` para evitar ranking opaco na V1.

## Escopo técnico

- Criada migração `V016__create_functional_search_events.sql`.
- Criadas portas e casos de uso de métricas funcionais.
- Criado adapter JDBC para persistência de busca e leitura de agregados.
- `GET /api/v1/professionals` registra evento de busca com filtros e quantidade de resultados.
- `GET /api/v1/admin/functional-metrics` expõe agregados administrativos protegidos por perfil administrador.
- Criado evento operacional `FUNCTIONAL_METRIC_FLOW`.

## Fora do escopo

- Ranking algorítmico sofisticado.
- Recomendação por IA.
- OpenSearch obrigatório.
- Tela administrativa.

## Evidências de qualidade

- `make backend-static-analysis`: PASS.
- `make backend-unit-test`: PASS, 255 testes, cobertura mínima de 95% atendida.
- `make backend-integration-test`: PASS, Flyway até `v016`.
- `make backend-image-build`: PASS.
- `make functional-test`: N/A, ainda sem cenários reais.
- `git diff --check`: PASS.
- Varredura de segredos no diff adicionado: PASS.

## Versionamento

- Versão planejada: `v0.34.0`.
