---
task_key: WLT-009
title: "Autenticação segura, sessões e tokens"
story_path: "docs/jira-pessoal/historias-tecnicas/WLT-009-autenticacao-sessoes-tokens.md"
official_order: 20
phase: DONE
loop_iteration: 1
version_suggestion: MINOR
func_tests_detected: false
func_tests_path: "functional-tests/src/**/*.spec.js"
func_tests_framework: "Jest + Axios"
exit_bar:
  lint: PASS
  unit_tests: PASS
  integration_tests: PASS
  func_tests: N/A
  mobile_tests: PASS
  coverage: PASS
  sonar: N/A
  sre: PASS
  security: PASS
  arch_review: PASS
  final_review: PASS
metrics:
  unit_coverage_minimum: 95
  changed_files: 56
  risk_level: HIGH
release:
  commit_hash: "verificado no fechamento via git rev-parse HEAD"
  semantic_tag: v0.20.0
correction_queue: []
cycle_history:
  - iteration: 0
    phase: EXECUTION
    summary: "WLT-009 iniciada como próxima história oficial do Kanban unificado."
    evidence:
      - "docs/jira-pessoal/historias-tecnicas/WLT-009-autenticacao-sessoes-tokens.md"
  - iteration: 1
    phase: DONE
    summary: "Autenticação segura por telefone entregue com OTP hasheado, access token assinado, refresh token opaco, rotação e revogação."
    evidence:
      - "make backend-unit-test: PASS, 111 testes, cobertura JaCoCo validada"
      - "make backend-static-analysis: PASS"
      - "make backend-integration-test: PASS, Flyway v008 aplicado"
      - "make mobile-static-analysis: PASS"
      - "make mobile-unit-test: PASS, cobertura 99.51%"
      - "make mobile-screen-test: PASS, 22 testes"
      - "make mobile-integration-test: N/A"
      - "make functional-test: N/A"
      - "git diff --check: PASS"
      - "secret scan: PASS, somente placeholder esperado em compose.yml"
---

# WLT-009 — Autenticação segura, sessões e tokens

## Plano BDD/TDD

- Dado um telefone, quando solicitar OTP, então o sistema deve persistir apenas o hash do código e responder mensagem genérica.
- Dado um OTP expirado, quando verificar o código, então a autenticação deve falhar sem revelar se o telefone existe.
- Dado falhas recorrentes de OTP, quando exceder o limite, então o desafio deve ser bloqueado.
- Dado OTP correto, quando verificar, então o sistema deve criar ou reutilizar cliente e emitir access token + refresh token.
- Dado refresh token válido, quando renovar sessão, então o token antigo deve ser revogado e um novo refresh token deve ser salvo apenas como hash.
- Dado refresh token válido, quando revogar sessão, então novas renovações com ele devem falhar.

## Decisões

- Access token será JWT assinado por HMAC-SHA-256 em adaptador de infraestrutura, sem acoplar o caso de uso ao formato.
- Refresh token será opaco, gerado por `SecureRandom`, retornado uma única vez e persistido apenas como hash.
- OTP e refresh token usarão `ProtectSensitiveValuePort`, entregue na WLT-013.
- O envio real de SMS fica fora da WLT-009; a V1 fixa o contrato seguro sem escolher provedor definitivo.
- Respostas de solicitação e falhas de verificação serão genéricas para reduzir enumeração.

## Restrições Pragmáticas e Padrões

- Não introduzir Spring Security completo nesta história.
- Não acoplar domínio/casos de uso a servlet, Spring, SQL, JWT ou fornecedor de SMS.
- Testes devem usar padrão `GIVEN`, `WHEN`, `THEN`.
- Tokens, OTP e hashes não devem ser logados.

## Log de Iterações

- Iteração 0: plano criado para base técnica de autenticação, sessões e tokens.
- Iteração 1: implementação concluída com domínio, portas, casos de uso, adaptadores JDBC/token, endpoints REST, migração `V008` e testes BDD/TDD.

## Aprendizados do Loop

- A WLT-013 já fornece a fronteira correta para hash de OTP e refresh token; WLT-009 deve consumir essa porta em vez de recriar criptografia.
- A autenticação pode nascer sem provedor SMS definitivo desde que a fronteira de envio fique fora do caso de uso e nenhum segredo seja persistido ou logado em claro.
