# WL-006 — Cadastro progressivo do profissional

## Versão

- Tipo: `MINOR`
- Tag planejada: `v0.16.0`

## Entrega

Foi entregue a base de cadastro progressivo do profissional. O backend agora permite completar/editar perfil profissional com foto referenciada por arquivo seguro, documento, link útil, portfólio e serviços, calculando a completude sem prometer qualidade. O app mobile ganhou a tela de cadastro progressivo baseada no protótipo oficial, com campos mínimos, opcionais, indicação visual de etapa/completude e ações de continuar ou salvar para depois.

## Escopo entregue

- Domínio `Professional` evoluído com campos progressivos opcionais e cálculo de completude.
- Classificações `BASIC_PROFILE`, `PROGRESSIVE_PROFILE` e `COMPLETE_PROFILE`.
- Caso de uso `CompleteProfessionalProfileUseCase`.
- Portas `LoadProfessionalByIdentifierPort` e `UpdateProfessionalPort`.
- Endpoint `PATCH /api/v1/professionals/{professionalIdentifier}/profile`.
- Adapter JDBC com carregamento e atualização de perfil progressivo.
- Migração `V005__add_progressive_professional_profile.sql`.
- Tela mobile `ProfessionalRegistrationScreen` com controller e draft testáveis.
- Navegação real pelo app para cadastro profissional.
- Ajuste no Makefile para limpar `coverage/` antes de cada suíte mobile com cobertura.

## Decisões

- Autenticação e ownership real não foram implementados nesta história; o contrato usa o identificador do profissional até as histórias de segurança.
- Foto/portfólio usam referência preparada pela fundação de storage, sem upload binário real nesta entrega.
- Completude é apenas sinal de preenchimento e não garantia de qualidade.
- Regras de completude ficam em domínio/modelo/controlador, não dentro de widgets.

## Gates

- `make backend-static-analysis`: PASS
- `make backend-unit-test`: PASS, 88 testes, JaCoCo >= 95%
- `make backend-integration-test`: PASS, Flyway aplicado até v005
- `make mobile-static-analysis`: PASS
- `make mobile-unit-test`: PASS, cobertura 100.00%
- `make mobile-screen-test`: PASS
- `make mobile-integration-test`: N/A, sem emulador/simulador/Chrome no container
- `make functional-test`: N/A, sem cenários reais
- `git diff --check`: PASS
- Scan de segredos: PASS, apenas referência parametrizada `${WORKLINK_POSTGRES_PASSWORD}` em `compose.yml`

## Fora do escopo rastreado

- Autenticação do profissional.
- Ownership/autorização real da edição.
- Upload binário de foto ou portfólio.
- Verificação documental avançada.
- Garantia de qualidade.
