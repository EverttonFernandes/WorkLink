# WL-014 — Denúncia de profissional

## História

Como usuário, quero denunciar um profissional por fraude, assédio, ameaça, perfil falso, serviço não realizado ou outro
motivo para que a plataforma registre o caso para análise posterior.

## Fonte oficial

- `docs/jira-pessoal/historias/WL-014-denuncia-profissional.md`
- `docs/requisitos/epico-requisitos-de-negocio.md`
- `docs/requisitos/epico-requisitos-nao-funcionais.md`
- `docs/prototipos-de-tela/tela-denunciar-profissional.png`

## Critérios de aceite

- [x] Usuário deve conseguir abrir denúncia a partir do perfil.
- [x] Denúncia deve exigir motivo.
- [x] Denúncia deve permitir descrição.
- [x] Evidência deve ser opcional.
- [x] Denúncia deve ser registrada para análise.
- [x] Casos graves devem exibir orientação para buscar autoridades.

## Escopo técnico

- Criar domínio de denúncia com motivo obrigatório, descrição opcional e evidência opcional.
- Registrar denúncia vinculada ao profissional e ao usuário autenticado.
- Classificar motivos graves para retorno de orientação institucional sem prometer mediação jurídica.
- Persistir denúncia em tabela própria para análise administrativa futura.
- Auditar registro da denúncia como ação sensível.
- Criar tela mobile de denúncia acessível a partir do perfil.
- Cobrir backend e mobile com testes no padrão GIVEN/WHEN/THEN.

## Fora do escopo

- Mediação completa de conflito.
- Decisão automática de culpa.
- Processo jurídico.
- Painel administrativo de moderação.

## Evidências

- `make backend-unit-test`: PASS, 226 testes e cobertura mínima atendida.
- `make backend-static-analysis`: PASS.
- `make backend-integration-test`: PASS, Flyway até `v014`.
- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura 96,58%.
- `make mobile-screen-test`: PASS, 48 testes de tela.
- `make mobile-integration-test`: N/A por ausência de Android Emulator, iOS Simulator ou Chrome.
- `make functional-test`: N/A por ausência de cenários reais.
- `make backend-image-build`: PASS.
- `git diff --check`: PASS.
- Security diff scan: PASS.
