# WL-005 — Perfil público detalhado do profissional

## História

Como usuário cliente, quero abrir o perfil público detalhado do profissional a partir da listagem, para avaliar melhor se devo iniciar contato.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-005-perfil-publico-profissional.md`
- `docs/jira-pessoal/KANBAN-OFICIAL.md`
- `docs/prototipos-de-tela/tela-perfil-do-profissional.png`

## Critérios de aceite

- [x] Usuário deve conseguir abrir perfil a partir da listagem.
- [x] Perfil deve mostrar dados principais do profissional.
- [x] Perfil deve mostrar serviços, cidades atendidas e disponibilidade quando cadastrados.
- [x] Perfil deve deixar claro que completude não garante qualidade.
- [x] Perfil deve oferecer acesso ao contato e à denúncia.

## Escopo técnico

- Criar modelo mobile para perfil público.
- Criar tela mobile de perfil público detalhado.
- Integrar abertura do perfil a partir da listagem existente.
- Expor ações de contato e denúncia por callbacks.
- Cobrir lógica e tela com testes BDD/TDD.

## Fora do escopo

- Chat interno.
- Contrato ou pagamento.
- Verificação documental avançada.
- Upload/storage real de fotos e portfólio.
- Avaliações reais persistidas.
- Autenticação/autorização/rastreabilidade real das ações.
