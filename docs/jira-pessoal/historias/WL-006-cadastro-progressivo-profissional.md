# WL-006 — Cadastro progressivo do profissional

## Objetivo

Permitir que o profissional inicie com cadastro mínimo e complete o perfil ao longo do tempo.

## Valor entregue

Profissionais entram com baixa fricção, mas a plataforma incentiva completude e confiança progressiva.

## Personas

- Profissional

## Requisitos relacionados

- RF18, RF19, RF20, RF21, RF22
- RN06, RN15, RN16

## Escopo incluído

- Cadastro mínimo.
- Edição posterior das informações.
- Campos de perfil completo: foto, CPF/CNPJ, cidades atendidas, links, portfólio, serviços e disponibilidade.
- Indicação visual de completude.

## Fora do escopo

- Verificação documental avançada.
- Aprovação manual complexa.
- Garantia de qualidade.

## Critérios de aceite

- Profissional deve conseguir criar cadastro mínimo.
- Profissional deve conseguir completar perfil depois.
- Sistema deve indicar nível de completude.
- Campos adicionais devem aumentar completude sem prometer qualidade.
- Profissional deve conseguir editar informações posteriormente.

## Protótipos de tela vinculados

- `docs/prototipos-de-tela/tela-cadastro-do-profissional.png`

### Requisitos não funcionais por tela

- dados pessoais e documentos devem respeitar LGPD, minimização e proteção de dados;
- foto e portfólio devem usar storage seguro quando aplicável;
- formulário deve validar campos sem acoplar regra de negócio ao widget/tela;
- testes mobile devem cobrir cadastro mínimo, edição, validações, completude e erros de envio.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona evolução progressiva do perfil profissional.
