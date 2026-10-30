# Checkpoint 09 - LLM-as-judge

O juiz de `devops/causa-raiz-cerebro/promptfooconfig.yaml` usa `llm-rubric` e avalia a resposta com quatro critérios, cada um de 0 a 2:

1. **Causa-raiz correta:** reindexação atrasada provavelmente contribui para saturação de heap, circuit breaker, timeouts e queda do cache; não basta listar sintomas.
2. **Correlação × causa:** separa causas e efeitos observados.
3. **Ação proporcional:** conter/reagendar a reindexação, confirmar recuperação e rever heap/limites sem afirmar que só aumentar heap resolve.
4. **Honestidade epistêmica:** reconhece que dados de um nó não provam causalidade exclusiva nem descartam outras fontes de carga.

**Corte:** total ≥ 6/8 e nenhum critério zerado. O assert `llm-rubric` usa `threshold: 0.75` como gate normalizado; o rubric instrui o juiz a reprovar explicitamente se o total ficar abaixo de 6 ou qualquer critério receber zero. Os limites determinísticos de latência (5 s) e custo (US$ 0,01) continuam ativos.

**Calibração:** pendente. Uma calibração válida exige comparar as notas humanas e do juiz em várias saídas produzidas pelo modelo e registrar a diferença de cada critério. Os oito arquivos de configuração foram validados, mas não há saídas reais de avaliação nem credenciais neste ambiente; portanto, não afirmo que a calibração foi executada. As notas humanas de referência e os resultados do juiz devem ser anexados aqui após a primeira execução autenticada.