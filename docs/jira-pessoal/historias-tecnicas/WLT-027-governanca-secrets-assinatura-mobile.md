# WLT-027 — Governança de secrets e assinatura mobile

## Objetivo

Definir e implementar a governança mínima de secrets, chaves e assinatura mobile para que Android e iOS possam evoluir para publicação sem vazamento de credenciais.

## Valor técnico

Publicação em lojas exige keystores, certificados, tokens e credenciais sensíveis. Esta história garante que o projeto tenha uma política objetiva antes de automatizar CD.

## RNFs relacionados

- RNF03
- RNF06
- RNF10
- RNF13

## Escopo incluído

- Mapear secrets necessários para Android, iOS, SonarCloud e integrações de loja.
- Atualizar `.env.example`, documentação e GitHub Actions com nomes esperados de secrets.
- Validar que arquivos sensíveis permanecem ignorados pelo Git.
- Definir rotação, ownership e recuperação de credenciais.
- Registrar política de assinatura para debug, staging/internal testing e produção.
- Adicionar checks simples contra versionamento acidental de keystores, certificates e profiles.

## Fora do escopo

- Criação de contas comerciais.
- Compra ou emissão de certificados reais.
- Upload automático para lojas.
- Gestão corporativa avançada de cofres externos.

## Critérios de aceite

- O projeto possui inventário de secrets por ambiente.
- Arquivos de assinatura sensíveis estão cobertos por `.gitignore`.
- O workflow documenta quais secrets são opcionais e quais bloqueiam CD.
- Existe orientação de rotação e revogação.
- A pipeline falha ou alerta se artefatos sensíveis forem adicionados por engano.

## Entrega versionável

- Tipo sugerido: `MINOR`
- Motivo: adiciona controle operacional necessário para CD mobile seguro.
