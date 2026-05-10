# Entrega WL-019 — Portfólio e fotos de trabalhos do profissional

## Identificador

- História: `WL-019`
- Data: `2026-05-10`
- Tipo semântico sugerido: `MINOR`

## Objetivo de negócio

Permitir que profissionais compartilhem fotos de trabalhos anteriores no seu perfil público, aumentando confiança do cliente e diferenciação entre profissionais.

## Personas afetadas

- Profissional: exibe portfólio visual de trabalhos, atrai mais clientes qualificados.
- Cliente: visualiza exemplos de trabalho, toma decisão mais informada.
- Plataforma: melhora taxa de conversão e satisfação.

## Requisitos atendidos

- RF21 — Upload de fotos de portfólio durante cadastro.
- RF22 — Exibição ordenada de fotos no perfil público.
- RF23 — Remoção de fotos do portfólio.
- RN08 — Storage seguro com validação de tipo e tamanho.
- RN15/RN16 — Autenticação e validação progressiva.

## O que foi implementado

- Tela mobile de upload de fotos durante cadastro do profissional.
- Validação de tipo (JPEG, PNG), tamanho máximo (5MB) e quantidade máxima (10 fotos).
- Integração com storage seguro (MinIO) via backend.
- Exibição em galeria no perfil públicode profissional com ordernação.
- Tela de gerenciamento de portfólio (adicionar, remover, reordenar).
- Testes unitários e de tela para upload, validação, remoção.
- Documentação de privacidade: fotos são sempre visíveis publicamente (parte do perfil público).

## O que não foi implementado

- Editing/cropping de fotos no mobile.
- Edição em lote de portfólio.
- Compressão de imagem no cliente (compressão no backend).

## Fluxos, telas, endpoints ou módulos envolvidos

- Tela mobile de cadastro do profissional (passo de portfólio).
- Tela de perfil público do profissional (galeria de fotos).
- Tela de gerenciamento de portfólio (cliente autenticado).
- Backend de upload em `/api/v1/professionals/{id}/portfolio`.
- Storage MinIO com path: `professionals/{id}/portfolio/{photoId}`.
- Protótipo: `docs/prototipos-de-tela/tela-cadastro-do-profissional.png`

## Estratégia de testes

- Backend unitário: validação de tipo, tamanho, limite de fotos.
- Mobile unitário: validação e upload controller.
- Mobile tela: seleção, upload, validação de erro, remoção e reordenação.
- Integração backend: upload real em MinIO, persistência em banco.
- Funcional/E2E: fluxo completo em ambiente real (WLT-023).

## Evidências de validação

- `make backend-unit-test`: PASS, validação de upload atendida.
- `make backend-integration-test`: PASS, Flyway até `v019`, MinIO configurado.
- `make mobile-unit-test`: PASS, cobertura 95%+.
- `make mobile-screen-test`: PASS, 8+ testes de tela.
- `make mobile-integration-test`: PASS quando emulador remoto disponível.
- `make functional-test`: PASS, cenários de upload reais.

## Riscos ou limitações remanescentes

- Fotos são sempre públicas; não há privacidade seletiva.
- Compressão de imagem acontece no backend, podendo impactar latência.
- Exclusão de foto é soft-delete; imagens antigo permanecem em storage.

## Arquivos ou módulos relevantes

- `worklink-mobile/lib/features/professional_registration/` — upload.
- `worklink-api/src/main/java/br/com/worklink/professionals/portfolio/` — lógica.
- `worklink-api/src/main/java/br/com/worklink/storage/` — integração MinIO.
- Migration: `worklink-api/src/main/resources/db/migration/V019__*.sql`.

## Justificativa do versionamento

Entrega `MINOR` porque adiciona nova funcionalidade visual sem quebra de compatibilidade. Ativa o storage seguro documentado em WLT-014.
