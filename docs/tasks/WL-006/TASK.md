# WL-006 — Cadastro progressivo do profissional

## História

Como profissional, quero iniciar com um cadastro mínimo e completar meu perfil depois, para entrar com baixa fricção e aumentar a confiança do meu perfil ao longo do tempo.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-006-cadastro-progressivo-profissional.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/prototipos-de-tela/tela-cadastro-do-profissional.png`

## Critérios de aceite

- [x] Profissional deve conseguir criar cadastro mínimo.
- [x] Profissional deve conseguir completar perfil depois.
- [x] Sistema deve indicar nível de completude.
- [x] Campos adicionais devem aumentar completude sem prometer qualidade.
- [x] Profissional deve conseguir editar informações posteriormente.

## Escopo técnico

- Evoluir domínio de profissional com dados progressivos opcionais e cálculo de completude.
- Criar caso de uso para completar/editar perfil profissional.
- Persistir campos opcionais de perfil sem acoplar regra de negócio ao banco, HTTP ou widget.
- Criar tela mobile de cadastro progressivo seguindo o protótipo.
- Cobrir domínio, caso de uso, API, adapter, lógica mobile e widget com BDD/TDD.

## Fora do escopo

- Autenticação real do profissional.
- Verificação documental avançada.
- Upload binário real de foto/portfólio.
- Garantia de qualidade do serviço.
