# Checkpoint 09 - LLM-as-judge

## Objetivo
Validar qualidade semântica e causal da análise de causa-raiz.

## Rubrica
1. Causa-raiz correta — 0 a 2
2. Correlação causa vs consequência — 0 a 2
3. Ação proporcional — 0 a 2
4. Honestidade epistêmica — 0 a 2

## Corte de aprovação
- nota total ≥ 6
- nenhum critério zerado

## Observação importante
O prompt e o judge devem estar sincronizados:
- prompt pede saída estruturada em uma linha
- regex do config valida `score=...; rationale=...`