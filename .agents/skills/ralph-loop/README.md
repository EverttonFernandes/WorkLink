---
name: ralph-loop-readme
description: Índice auxiliar dos subagentes do Ralph Loop no WorkLink V1.
document_type: skill_reference
max_lines: 300
---

# Ralph Loop — WorkLink V1

Para instruções técnicas da skill, veja [SKILL.md](./SKILL.md).

O Ralph Loop deste projeto usa subagentes especializados para evitar mistura de responsabilidades. A regra central é simples: cada gate é aprovado pelo agente dono daquele tipo de risco.

## Subagentes

| Subagente | Skill | Responsabilidade |
|-----------|-------|------------------|
| Product Manager | `ralph-loop/product-manager` | Guardião do negócio, backlog, `IMPLEMENTATION.md`, `progress.txt` e documentação de entrega |
| Executor | `ralph-loop/executor-agent` | Implementação com TDD e correção da `correction_queue` |
| QA | `ralph-loop/qa-agent` | Testes unitários, integração, funcionais/E2E, mobile, coverage, lint e boas práticas de testes/código |
| SRE | `ralph-loop/sre-agent` | DevOps, ambiente reproduzível, configuração, CI/CD, observabilidade, disponibilidade e prontidão operacional |
| Segurança | `ralph-loop/security-specialist-agent` | Autenticação, autorização, autenticidade, LGPD, proteção de dados e coordenação com `security-guardian` |
| Security Guardian | `security-guardian` | Auditoria local de diff com OWASP, CWE, Diff Risk Scoring e veredito de bloqueio |
| Arquiteto | `ralph-loop/architect-reviewer-agent` | Arquitetura, SOLID, modularidade e manutenibilidade |
| Final Reviewer | `ralph-loop/final-reviewer-agent` | Revisão holística pré-fechamento |

## Árvore De Decisão

```text
1. correction_queue OPEN?
   -> Executor

2. Gates de testes/qualidade PENDING/FAIL?
   -> QA

3. Gate SRE PENDING/FAIL?
   -> SRE

4. Gate security PENDING/FAIL?
   -> Security Specialist
   -> Security Specialist coordena security-guardian quando aplicável

5. arch_review PENDING?
   -> Architect Reviewer

6. final_review PENDING?
   -> Final Reviewer

7. Todos obrigatórios PASS e não aplicáveis N/A?
   -> Product Manager documenta entrega
   -> Git Operator fecha commit/tag
```

## Exit Bar

```yaml
exit_bar:
  lint:              PASS
  unit_tests:        PASS
  integration_tests: PASS  # ou N/A
  func_tests:        PASS  # ou N/A quando func_tests_detected: false
  mobile_tests:      PASS  # ou N/A
  sonar:             PASS  # ou N/A
  coverage:          PASS  # ou N/A
  sre:               PASS  # ou N/A
  security:          PASS
  arch_review:       PASS
  final_review:      PASS
```

`SKIP`, `ABORTED`, `SKIPPED` ou qualquer status inventado são inválidos. Na prática, `SKIP = FAIL`.

## Separação De Responsabilidades

- QA não decide segurança, LGPD, autenticação, autorização, CI/CD ou observabilidade.
- SRE não decide cobertura funcional nem vulnerabilidade de código.
- Security Specialist não substitui o `security-guardian`; ele coordena e interpreta o gate de segurança no contexto da história.
- Security Guardian não interpreta produto nem plano; ele audita diff local e emite veredito técnico.
- Executor nunca marca gate como `PASS`.

## Fontes Normativas

- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`
- `.agents/workflows/start-work.md`

## Memória Do Loop

O loop persiste estado em:

- `docs/tasks/<KEY>/IMPLEMENTATION.md`
- `docs/tasks/<KEY>/progress.txt`

Se não estiver nesses artefatos, não deve ser tratado como fato operacional do ciclo.
