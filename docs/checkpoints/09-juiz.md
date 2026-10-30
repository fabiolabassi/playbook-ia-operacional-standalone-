# Checkpoint 09 — LLM-as-judge

`causa-raiz-cerebro`, `backpressure-relay` e as três etapas do Forge usam OpenAI para gerar a resposta
e Gemini para avaliar rubricas específicas. O threshold é 0.75, equivalente a 6/8, e as rubricas
exigem que nenhum critério fique zerado.

**Calibração pendente:** antes de tratar esses judges como gates confiáveis, uma pessoa deve pontuar
amostras boas e ruins sem ver as notas do modelo, comparar por critério e registrar divergências.
Não há calibração humana nova nesta entrega; por isso, o judge está configurado, mas sua calibração
não é declarada concluída.
