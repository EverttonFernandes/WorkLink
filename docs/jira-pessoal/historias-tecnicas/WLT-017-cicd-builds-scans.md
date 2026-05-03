# WLT-017 — CI/CD, builds e scans

## Objetivo

Criar pipeline automatizada para build, testes, análise, scans e geração de artefatos.

## Valor técnico

Garante validação repetível e reduz risco de regressão antes de publicação.

## RNFs relacionados

- RNF14, RNF06, RNF13

## Escopo incluído

- GitHub Actions.
- Pipeline backend.
- Pipeline mobile.
- Build Java.
- Testes unitários, integração e funcionais.
- Validação obrigatória de cobertura unitária mínima de 95%.
- Validação de migrations.
- Scan de dependências e segurança quando configurado.
- Build de imagem Docker multi-stage da API quando aplicável.
- Validação básica da imagem Docker gerada quando aplicável.
- Build Android.
- Estratégia para build iOS em runner macOS ou serviço compatível.

## Fora do escopo

- Publicação pública automática em produção.
- Infra cloud definitiva.

## Critérios de aceite

- Pipeline backend deve executar build, análise e testes disponíveis.
- Pipeline backend deve falhar quando a cobertura unitária ficar abaixo de 95%.
- Pipeline backend deve gerar imagem Docker multi-stage quando aplicável.
- Imagem Docker final deve conter apenas runtime e artefato necessário para execução.
- Pipeline deve bloquear imagem que dependa de arquivos locais, secrets versionados ou ferramentas de build no runtime final.
- Pipeline deve validar health check da imagem quando houver endpoint disponível.
- Pipeline mobile deve executar `flutter analyze` e `flutter test`.
- Pipeline mobile deve falhar quando a cobertura unitária Flutter ficar abaixo de 95%, se houver suíte unitária mobile configurada.
- Build Android deve ser automatizável.
- Build iOS deve ter estratégia documentada.
- Falhas críticas devem bloquear merge/fechamento.

## Entrega versionável

- Tipo sugerido: `MINOR`
