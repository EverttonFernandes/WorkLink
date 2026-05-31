# Entrega WLT-032 — Massa regional de homologação mobile

## Resumo

A massa de homologação mobile passou a cobrir a região inicial prevista para o WorkLink V1, permitindo validação manual e automatizada de descoberta/listagem regional.

## Escopo entregue

- Seed funcional de homologação com Charqueadas, São Jerônimo, Triunfo, Arroio dos Ratos, Eldorado do Sul, General Câmara e Butiá.
- Pelo menos um profissional fictício por cidade, distribuído em categorias de serviços gerais.
- Dados de preview mobile alinhados à região inicial para APK debug/preview web sem backend publicado.
- Checagem funcional Jest garantindo a presença mínima da massa regional.
- Testes mobile atualizados para a massa regional e para execução estável em Docker.
- Preview web estabilizado com build estático, evitando queda por WebSocket de debug.

## Evidências

- `make mobile-static-analysis`: PASS.
- `make mobile-unit-test`: PASS, cobertura unitária mobile 95,38%.
- `make mobile-screen-test`: PASS.
- `make functional-test`: PASS, 5 suítes e 12 testes.
- Preview web confirmado em `http://localhost:18080`.

## Observações

- `worklink-mobile/pubspec.lock` já estava modificado no workspace e não faz parte desta entrega.
- As alterações pendentes de `WLT-033/DTM-004` permanecem fora do escopo da WLT-032.
