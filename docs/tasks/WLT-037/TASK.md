# WLT-037 - Backend cloud minimo para aplicativo nas lojas

## Historia

Como dono do produto, quero um backend cloud minimo, estavel e de baixo custo, para que o app publicado nas lojas carregue
dados reais e nao dependa de localhost, tunnel temporario ou ambiente manual.

## Aceite

- API HTTPS estavel.
- PostgreSQL cloud com migrations aplicadas.
- Health/readiness validados.
- App mobile apontando para a API cloud.
- Secrets fora do Git.
- Custo mensal inicial documentado.
- Recuperacao basica documentada.

## Bloqueio real

Sem conta/provedor cloud e secrets reais, esta historia pode preparar automacao e runbook, mas nao pode ser fechada como
producao pronta.
