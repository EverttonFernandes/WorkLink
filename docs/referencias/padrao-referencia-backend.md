# Padrão de Código de Referência — projeto-referencia-backend-em-camadas

## Contexto da Referência

Este documento resume o padrão arquitetural e de código observado no módulo:

- `projeto-de-referencia-backend-em-camadas`

O objetivo deste registro não é copiar mecanicamente a solução de origem, e sim documentar os princípios estruturais que
devem orientar a futura refatoração do back-end deste projeto.

## Leitura Geral do Padrão

O contexto `padrao-de-referencia-em-camadas` adota uma separação clara entre:

- `api`
- `application`
- `domain`
- `infra`

Com algumas características fortes:

- controllers finos
- services de aplicação como orquestradores
- converters como porta de entrada para montagem do agregado
- domínio centrado em agregado com builder e specification
- infraestrutura persistindo e carregando o agregado

## Padrão Observado por Camada

### API

Referência lida:

- `me/referencia/business/team/api/TeamApi.java`

Padrão observado:

- o endpoint é fino
- recebe DTO validado
- faz apenas enriquecimento mínimo de contexto do DTO
- delega para `service` ou `command handler`
- não implementa regra de negócio relevante no controller
- respostas são simples e previsíveis

Leitura aplicada ao nosso projeto:

- controllers devem permanecer o mais finos possível
- validação HTTP, semântica REST e montagem de response continuam na `api`
- regra de negócio não deve escorrer para o controller

### Application Service

Referência lida:

- `me/referencia/business/team/application/service/TeamService.java`

Padrão observado:

- service coordena repositório, converter e publicação de eventos
- service não concentra regra de domínio arbitrária
- service assume o papel de caso de uso / orquestrador

Leitura aplicada ao nosso projeto:

- nossos services devem ficar mais claramente posicionados como orquestradores
- converter entra antes
- specification e regras de domínio entram no agregado ou no fluxo de domínio
- service evita virar classe utilitária anêmica ou camada inchada

### Converter

Referência lida:

- `me/referencia/business/team/application/converter/TeamCreateDTOConverter.java`

Padrão observado:

- converter resolve dependências e identificadores necessários
- converter monta o agregado pronto para validação e persistência
- converter usa `specification` do domínio ao construir
- converter tem responsabilidade clara e focada

Leitura aplicada ao nosso projeto:

- converter deve ser o ponto formal de transformação do DTO em comando/agregado
- validações de formato e obrigatoriedade continuam aqui quando fizer sentido
- carregamento de dependências ou resolução de identificadores também deve morar aqui, não no controller

### Domain

Referência lida:

- `me/referencia/business/team/domain/Teams.java`
- `me/referencia/business/team/domain/specification/CompositeSpecificationForTeam.java`

Padrão observado:

- existe agregado principal claro
- o agregado possui builder dedicado
- specification é composta e injetada
- estado, mudanças e invariantes ficam próximos do modelo central
- subdomínios e value objects aparecem quando ajudam o desenho

Leitura aplicada ao nosso projeto:

- devemos reforçar o agregado principal por contexto
- specifications devem ser compostas e coesas
- o domínio deve ficar mais expressivo e menos espalhado em services
- quando fizer sentido, builders ou command handlers podem organizar melhor a criação e a mutação do agregado

### Infra

Referência lida:

- `me/referencia/business/team/infra/TeamsRepositoryImpl.java`

Padrão observado:

- infraestrutura expõe repositório de contexto
- implementação concreta resolve loaders, JPA repository e persistência
- infraestrutura carrega e persiste o agregado de forma mais centralizada
- dependências externas ficam fora do domínio

Leitura aplicada ao nosso projeto:

- a camada `infrastructure` deve continuar isolando detalhes de JPA/Hibernate e bancos
- repositórios concretos devem assumir melhor o papel de adaptadores do domínio
- loaders, facades e integrações externas não devem contaminar `application` e `domain`

## Diferenças Relevantes em Relação ao Projeto Atual

Hoje, no `DigitalBankAPI`, o desenho já tem boa separação, mas ainda difere do padrão `padrao-de-referencia-em-camadas` em alguns pontos:

- services ainda concentram parte da montagem do fluxo que poderia ser deslocada para converters e agregados
- domínio ainda está mais simples e menos orientado a agregado rico
- infraestrutura está mais enxuta, mas menos padronizada como adaptador de contexto completo
- não há uma padronização única de builder / command handler por fatia funcional

## Padrões que Faz Sentido Trazer

- controllers mais finos e ainda mais focados em HTTP
- services mais explicitamente orquestradores
- converters com papel mais forte na montagem do agregado
- specifications compostas como regra formal do domínio
- repositórios concretos mais consistentes como adaptadores de contexto
- maior uniformidade entre as fatias de conta, transferência, movimentação e notificação

## Padrões que Não Devem Ser Copiados Cegamente

- não copiar base classes genéricas apenas por copiar
- não migrar o domínio inteiro para uma abstração excessiva
- não perder a simplicidade já conquistada no projeto atual
- não quebrar contratos HTTP apenas para se aproximar visualmente do outro projeto

## Garantia Principal da Refatoração

A garantia funcional da futura refatoração deve continuar sendo:

- `make functional-test`

Se a suíte funcional continuar verde ao final da refatoração:

- os comportamentos principais da API continuam corretos
- a refatoração pode seguir para ajuste dos testes unitários afetados

## Conclusão

O padrão `padrao-de-referencia-em-camadas` é útil como referência de:

- organização de camadas
- responsabilidade de cada camada
- centralidade do agregado
- força dos converters e specifications

O objetivo da futura história não será clonar aquele módulo, e sim trazer este projeto para um nível de consistência
estrutural semelhante, preservando o domínio e os contratos já construídos aqui.
