# WLT-012 — LGPD, privacidade e minimização de dados

## História

Como time técnico, quero aplicar privacidade por padrão e minimização de dados na V1, para reduzir risco regulatório e
proteger usuários, profissionais e denunciantes.

## Fonte oficial

- `docs/jira-pessoal/historias-tecnicas/WLT-012-lgpd-privacidade-dados-sensiveis.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/spec-driven-development/padroes-de-testes.md`
- `docs/spec-driven-development/codigo-limpo.md`
- `docs/spec-driven-development/padrões-de-projeto-e-design-de-codigo.md`

## Critérios de aceite

- [x] O sistema não deve coletar dados fora do escopo da V1.
- [x] Avaliações anônimas devem ocultar identidade publicamente.
- [x] Dados pessoais devem ter finalidade clara.
- [x] Acesso a dados sensíveis deve ser restrito.
- [x] Exclusão de conta deve ser considerada no desenho técnico.
- [x] Incidentes de privacidade devem ter fluxo mínimo documentado.

## Escopo técnico

- Criar inventário executável de dados pessoais, finalidade, retenção e exposição.
- Bloquear campos HTTP desconhecidos para evitar coleta silenciosa fora do contrato.
- Criar projeção de autoria pública para avaliação anônima futura.
- Documentar desenho técnico de exclusão de conta e resposta mínima a incidentes de privacidade.
- Cobrir a política de privacidade com testes unitários e de API.

## Fora do escopo

- Implementar fluxo funcional de avaliação.
- Implementar exclusão real de conta.
- Implementar portal administrativo LGPD.
- Coletar dados bancários, cartão, documentos com foto, localização contínua ou dados financeiros.

## Evidências de conclusão

- Backend unitário: `rm -rf worklink-api/target && make backend-unit-test` com 159 testes e cobertura JaCoCo mínima atendida.
- Backend estático: `make backend-static-analysis` sem violações.
- Backend integração: `make backend-integration-test` com migrations até `v009` aplicadas e cobertura atendida.
- Mobile estático: `make mobile-static-analysis` sem issues.
- Mobile unitário: `make mobile-unit-test` com 33 testes e 99,51% de cobertura.
- Mobile tela/widget: `make mobile-screen-test` com 22 testes aprovados.
- Mobile integração: `make mobile-integration-test` classificado como N/A por exigir Android Emulator, iOS Simulator ou Chrome.
- Funcional/E2E: `make functional-test` classificado como N/A por ainda não haver cenários reais.
- Segurança: varredura local não encontrou segredos; apenas placeholder esperado de senha no `compose.yml`.
- Integridade do diff: `git diff --check` sem erros.
