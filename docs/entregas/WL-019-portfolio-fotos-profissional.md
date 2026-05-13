# Entrega WL-019 — Portfólio e fotos de trabalhos do profissional

## Identificador

- História: `WL-019`
- Data: `2026-05-13`
- Tipo semântico: `MINOR`

## Objetivo de negócio

Permitir que o profissional associe fotos ou evidências visuais ao perfil público, aumentando a confiança do cliente sem
misturar portfólio com verificação documental ou garantia de qualidade.

## Requisitos atendidos

- RF13/RF20 — Perfil profissional mais completo com evidências públicas de trabalho.
- RN15/RN16 — Reuso de storage seguro, autorização por ownership e não exposição de dados sensíveis.
- Critério de aceite: profissional adiciona item de portfólio, sistema valida finalidade pública do arquivo e perfil
  público consome itens ativos.

## O que foi implementado

- Tabela `worklink.professional_portfolio_items` para vincular profissional e arquivo público de portfólio.
- Domínio `ProfessionalPortfolioItem`, use cases de adicionar/listar e portas de persistência.
- Endpoint público `GET /api/v1/professionals/{professionalIdentifier}/portfolio-items`.
- Endpoint autenticado `POST /api/v1/professionals/{professionalIdentifier}/portfolio-items` com ownership,
  auditoria sensível e limite de 10 itens ativos.
- Validação para aceitar somente arquivos `StoredFilePurpose.PROFESSIONAL_PORTFOLIO` com acesso público.
- Mobile consumindo os itens estruturados no gateway e exibindo-os no perfil público junto ao portfólio textual legado.

## Fora do escopo mantido

- Upload binário real no app.
- CDN produtiva.
- Crop, edição de imagem, reordenação avançada e remoção de itens.
- Curadoria administrativa complexa.

## Evidências de validação

- `make backend-unit-test`: PASS, 279 testes e coverage 95%+.
- `make backend-integration-test`: PASS, Flyway até `v018`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 95.09%.
- `make mobile-screen-test`: PASS.
- `make mobile-integration-test`: PASS para contrato HTTP; testes com emulador/simulador/browser ficaram `N/A`.
- `make functional-test`: `N/A`, ainda sem cenários funcionais reais.
- `git diff --check`: PASS.

## Arquivos ou módulos relevantes

- Backend: `worklink-api/src/main/java/br/com/worklink/domain/professional/ProfessionalPortfolioItem.java`
- Backend: `worklink-api/src/main/java/br/com/worklink/api/professional/ProfessionalPortfolioController.java`
- Backend: `worklink-api/src/main/resources/db/migration/V018__create_professional_portfolio_items.sql`
- Mobile: `worklink-mobile/lib/services/professional_service.dart`
- Mobile: `worklink-mobile/lib/app/worklink_application_gateway.dart`

## Justificativa do versionamento

Entrega `MINOR` porque adiciona uma nova capacidade funcional pública ao perfil profissional sem quebrar contratos
existentes.
