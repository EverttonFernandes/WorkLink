# WLT-020 — Projeto nativo mobile Android/iOS

**Story**: [WLT-020-projeto-nativo-mobile-android-ios.md](../../jira-pessoal/historias-tecnicas/WLT-020-projeto-nativo-mobile-android-ios.md)

**Versão**: MINOR

**Status**: DONE

---

## Objetivo

Gerar os projetos nativos Android e iOS do aplicativo Flutter, habilitando builds reais, testes em emulador/simulador e publicação futura nas lojas.

## Escopo

- Gerar `android/` e `ios/` no `worklink-mobile/`.
- Configurar identificadores mínimos e versão.
- Validar build Android real no ambiente containerizado.
- Atualizar a pipeline mobile para build Android executável.
- Documentar a estratégia iOS.

## Fora do Escopo

- Publicação efetiva nas lojas.
- Signing de produção.
- Testes em aparelho físico.

## Plano

### Fase 1 — Descoberta

- [x] Confirmar o estado atual do módulo Flutter e ausência dos diretórios nativos.
- [x] Mapear restrições do ambiente Docker para geração dos projetos nativos.
- [x] Identificar impacto no `Makefile` e na CI.

### Fase 2 — Implementação

- [x] Gerar projeto Android nativo mínimo.
- [x] Gerar projeto iOS nativo mínimo.
- [x] Ajustar build Android real e documentação iOS.

### Fase 3 — Gates

- [x] Validar build Android em container.
- [x] Validar pipeline mobile atualizada.
- [x] Atualizar documentação da entrega.

## Implementação realizada

- Geração dos diretórios nativos `android/` e `ios/` dentro de `worklink-mobile/` usando `flutter create` em container Docker.
- Normalização do identificador nativo para `br.com.worklink.mobile` no Android e no iOS.
- Ajuste do nome visível do app para `WorkLink`.
- Correção do `MainActivity.kt` para o novo namespace nativo.
- Endurecimento do target `make mobile-android-build` com limpeza prévia de `worklink-mobile/android/.gradle` para evitar lock de cache em bind mount.
- Atualização do `README` mobile com build Android real e referência explícita da estratégia iOS.
- Ajuste do gate de cobertura unitária para manter telas Flutter cobertas no gate de tela, sem contaminar a métrica unitária.

## Validações executadas

- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura `95.81%`
- `make mobile-screen-test`: PASS
- `make mobile-integration-test`: PASS para contrato HTTP; emulador/simulador/browser `N/A`
- `make mobile-android-build`: PASS

## Exit Bar

```yaml
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  mobile_tests: PASS
  coverage: PASS
  security: PASS
  sre: PASS
  arch_review: PASS
  final_review: PASS
```
