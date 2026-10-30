A reindexação ainda estava em andamento às 10:00, quando heap e throughput de indexação estavam
altos. Os logs já mostram fila cheia, rejeições e circuit breaker às 09:58; às 10:01 surgem buscas
com falha. Isso torna a carga de reindexação uma hipótese plausível, enquanto cache e timeouts podem
ser efeitos da pressão no cluster. Não há evidência suficiente para provar a relação causal nem para
saber qual tarefa consumiu mais recursos. Eu investigaria a reindexação e acompanharia heap, fila e
p99 antes de decidir o que fazer. A tolerância da busca a atraso e o consumo por tarefa precisam ser
confirmados.
