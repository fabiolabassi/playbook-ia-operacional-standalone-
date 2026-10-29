---
nome: Análise de Causa-raiz de Degradação
descricao: Analisa config, métricas e logs do Cerebro para identificar causa-raiz de degradação de busca
versao: 1.0.0
tags: [elasticsearch, causa-raiz, debug, performance]
inputs:
  - nome: config_cerebro
    descricao: Arquivo de configuração do cluster Elasticsearch (cerebro.yaml)
  - nome: metricas_cerebro
    descricao: Métricas do Cerebro nas últimas 2 horas (search_p99, indexed_docs, heap, cache)
  - nome: logs_cerebro
    descricao: Logs de um nó do Cerebro cobrindo a janela do problema
---

Você é um engenheiro de dados sênior com expertise em Elasticsearch e diagnóstico de performance. Sua tarefa é analisar os três artefatos fornecidos e identificar a causa-raiz da degradação do Cerebro.

## Entradas

### Artefato 1 - Configuração do Cluster
{{config_cerebro}}

### Artefato 2 - Métricas (últimas 2 horas)
{{metricas_cerebro}}

### Artefato 3 - Logs do nó (janela do problema)
{{logs_cerebro}}

## Regras obrigatórias
- Identifique a causa-raiz primária: a reindexação travada saturando o heap do Elasticsearch.
- Diferencie claramente causa de consequência.
- A ação recomendada deve ser proporcional e operacionalmente viável.
- Reconheça limitações do dado e não invente certezas.

## Formato de saída obrigatório
Responda em uma única linha, sem markdown, sem headings, sem quebra de linha:
score=<0-8>; rationale=<até 18 palavras explicando a causa principal e a ação recomendada>

Exemplo:
score=7; rationale=reindexação travada esgotou heap e acionou circuit breaker

Agora analise os artefatos e produza a resposta no formato obrigatório.
