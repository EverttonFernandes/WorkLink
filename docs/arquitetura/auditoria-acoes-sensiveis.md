# Auditoria de Ações Sensíveis

## Objetivo

A WLT-011 adiciona uma trilha persistida de auditoria para ações sensíveis da V1, mantendo autoria interna,
rastreabilidade e minimização de dados.

## Decisão arquitetural

A auditoria fica na camada de aplicação e é acessada por porta:

- `RecordSensitiveAuditEventUseCase`
- `SaveSensitiveAuditEventPort`
- `JdbcSensitiveAuditEventRepositoryAdapter`

Controllers apenas orquestram resolução do principal autenticado, autorização, execução do caso de uso funcional e
registro do evento. A regra de auditoria não depende de HTTP, Spring MVC ou detalhes de banco.

## Dados persistidos

A tabela `sensitive_audit_events` persiste somente metadados mínimos:

- identificador do evento
- autor interno
- perfil do autor
- ação sensível
- tipo e identificador do alvo
- resultado
- data de ocorrência

Não são persistidos payloads brutos, tokens, telefone, documento, segredo, evidência ou conteúdo confidencial.

## Ações auditáveis

A entrega registra auditoria para ações sensíveis já existentes:

- cadastro administrativo de categoria
- cadastro administrativo de cidade
- conclusão/edição de perfil profissional

O catálogo também prepara ações futuras para contato, feedback, avaliação anônima rastreável, denúncia, acesso a
evidência confidencial, contestação, login administrativo e acesso administrativo a dados sensíveis. Os disparos reais
dessas ações devem ser conectados quando cada fluxo funcional existir.

## Segurança e privacidade

A avaliação anônima futura poderá preservar anonimato público sem perder autoria interna, porque autoria e exibição
pública são responsabilidades separadas. Acesso administrativo à autoria interna e a evidências confidenciais possui
ações próprias no catálogo, evitando consultas sensíveis sem trilha auditável.

## Evolução

SIEM, outbox, consulta administrativa avançada e retenção detalhada de auditoria ficam fora da WLT-011. A estrutura atual
permite evoluir para esses mecanismos sem acoplar domínio, framework e infraestrutura externa.
