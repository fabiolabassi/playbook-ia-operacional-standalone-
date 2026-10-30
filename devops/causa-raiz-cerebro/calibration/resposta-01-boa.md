Os dados apontam a reindexação como provável gatilho da degradação, mas não provam causalidade
direta. Às 09:00 o throughput de indexação sobe de 4.100 para 9.800 docs/s enquanto heap chega a
79%; depois o heap alcança 94%, a fila de escrita cresce até 200/200 e rejeita bulks, e o circuit
breaker dispara. O p99 e a taxa de acerto do cache pioram no mesmo intervalo, e as buscas passam a
ter resultados parciais e falhas. Cache e timeouts parecem sintomas/consequências, não a causa
primária demonstrada.

Como contenção reversível, reduzir ou pausar a reindexação após confirmar o impacto e preservar seu
estado para retomada; acompanhar heap, fila, p99 e erros de busca. Antes de retomar, investigar
concorrência, throttling e capacidade de escrita. Os dados não mostram consumo de heap por tarefa nem
uma comparação controlada; verificar essas relações antes de declarar a causa confirmada ou aumentar
heap.
