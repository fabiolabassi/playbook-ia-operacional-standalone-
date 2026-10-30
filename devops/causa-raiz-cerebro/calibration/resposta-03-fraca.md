A causa-raiz é o cache pequeno de 512 MB. A queda de hit ratio prova que o cache insuficiente gerou
as buscas lentas, e o circuit breaker é consequência desse cache. Aumente o cache e o heap
imediatamente para evitar novas falhas. A reindexação está em andamento normalmente e não tem relação
com o incidente.
