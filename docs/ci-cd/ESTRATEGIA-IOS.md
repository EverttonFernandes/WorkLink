# Estratégia iOS — WorkLink V1

## Objetivo

Registrar a estratégia para build iOS sem exigir macOS local durante o desenvolvimento diário.

## Estratégia

- Builds Android podem rodar em runner Linux quando o projeto Android existir.
- Builds iOS devem rodar em runner macOS no GitHub Actions ou em serviço compatível com Xcode.
- A pipeline iOS deve executar `flutter pub get`, `flutter analyze`, testes Flutter aplicáveis e `flutter build ios --no-codesign`.
- Assinatura, certificados e publicação em lojas ficam fora da V1 técnica inicial.
- Secrets de assinatura nunca devem ser versionados; quando necessários, devem vir do secret store do CI.

## Critério para Ativação

Ativar o job iOS real quando:

- o diretório `worklink-mobile/ios` existir;
- houver runner macOS disponível;
- os secrets de assinatura necessários estiverem definidos fora do repositório.

## Estado atual

- O diretório `worklink-mobile/ios` já existe no repositório.
- O próximo passo para ativação real é adicionar um job macOS na pipeline para executar `flutter build ios --no-codesign`.
