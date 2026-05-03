# Entrega WLT-017 — CI/CD, builds e scans

## Resultado

Pipeline inicial de CI/CD criada para validar backend, mobile, imagem Docker e dependências antes de merge.

## Entregues

- Workflow `.github/workflows/ci.yml`.
- Job backend com análise estática, unitários, cobertura, integração e funcionais.
- Job mobile com análise estática, testes mobile e estratégia Android.
- Job de imagem Docker multi-stage da API.
- Validação do runtime da imagem sem Maven/Javac.
- Job de scan básico de dependências.
- Estratégia iOS documentada.
- Alvos `backend-image-build`, `mobile-android-build` e `ci` no Makefile.

## Validações

- `WORKLINK_ENV_FILE=.env.example docker compose --env-file .env.example config`
- `docker build -f docker/worklink-api.Dockerfile -t worklink-api:ci-local .`
- `docker run --rm --entrypoint sh worklink-api:ci-local -lc "test -f /app/worklink-api.jar && ! command -v mvn && ! command -v javac"`
- `make mobile-android-build`
- `git diff --check`

## Observações

- A pipeline não publica em produção.
- iOS real depende de runner macOS e projeto iOS gerado.
