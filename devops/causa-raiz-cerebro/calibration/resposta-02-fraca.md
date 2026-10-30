Os logs confirmam que a reindexação foi a causa direta e exclusiva. O heap cresceu porque o job ficou
travado desde as 02:00, e isso causou o circuit breaker e todos os timeouts. A solução é dobrar o heap
imediatamente e encerrar o job atual; não é necessário validar outras hipóteses nem medir o consumo.
