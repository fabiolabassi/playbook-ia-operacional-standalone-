---
nome: Análise de Causa-raiz de Degradação
descricao: Analisa config, métricas e logs do Cerebro para identificar causa-raiz de degradação de busca
versao: 1.1.0
tags: [elasticsearch, causa-raiz, debug, performance]
inputs:
  - nome: config_cerebro
    descricao: Arquivo de configuração do cluster Elasticsearch (cerebro.yaml)
  - nome: metricas_cerebro
    descricao: Métricas do Cerebro nas últimas 2 horas (search_p99, indexed_docs, heap, cache)
  - nome: logs_cerebro
    descricao: Logs de um nó do Cerebro cobrindo a janela do problema
---

# Análise de Causa-raiz de Degradação

## Objetivo
Prompt para análise de causa-raiz de degradação no sistema de busca Cerebro (Elasticsearch). Recebe três artefatos (configuração, métricas e logs) e correlaciona as informações para identificar a causa-raiz, distinguindo entre causa e consequência, e recomenda ação proporcional ao diagnóstico.

## Quando Usar
- Quando o Cerebro apresenta degradação de performance (latência alta, resultados incompletos)
- Para investigação pós-incidente do Cerebro
- Para documentação de RCA (Root Cause Analysis)
- Quando há necessidade de entender interações entre configuração, métricas e logs

## Exemplo de Uso

### Entrada (resumida)
**Config**: jvm_heap: 8g, reindex_job schedule: "0 2 * * *", avg_duration_min: 90
**Métricas**: search_p99 subiu de 850ms às 08h para 6700ms às 10h, heap_used de 61% para 94%
**Logs**: reindex task em 41% às 10h (deveria terminar ~03:30), circuit breaker disparou aos 96% heap

### Saída Esperada (resumida)
```
### CAUSA-RAIZ
A reindexação ainda estava em 41% às 10:00, embora a duração média informada seja 90 minutos. A atividade de indexação coincide com o aumento do heap e da latência; os dados sustentam que ela contribui para a saturação, mas não provam que seja a única causa.

### EVIDÊNCIAS
- O heap subiu de 61% para 94% enquanto a reindexação avançou apenas de 38% para 41%.
- Logs registram fila de escrita cheia, circuit breaker, buscas parciais e timeout.

### AÇÃO RECOMENDADA
Conter ou pausar a reindexação conforme o procedimento operacional e monitorar heap, rejeições e p99; investigar a causa do atraso antes de alterar limites.

### LIMITAÇÕES
Os artefatos são de um nó e não isolam outras fontes de carga nem provam causalidade exclusiva.
```

## Limitações
- Requer que os três artefatos sejam fornecidos completos e cobrindo a mesma janela temporal
- Assume familiaridade com Elasticsearch (heap, GC, circuit breaker, shards)
- A análise depende da qualidade dos logs - se faltarem eventos críticos, a causa-raiz pode não ser identificável
- Não substitui investigação mais profunda com ferramentas de profiling ou análise de heap dump
- Específico para Cerebro/Elasticsearch - não é genérico para outros sistemas de busca

## Privacidade antes de usar um provedor externo

Trate os artefatos como produção: remova credenciais, tokens, dados pessoais, nomes de tenants/clientes, hostnames internos, IPs e identificadores de índices que possam revelar informação operacional. Preserve timestamps relativos, métricas e relações entre eventos; use pseudônimos consistentes dentro do mesmo incidente para não destruir a correlação. Os fixtures deste repositório são fictícios.

## Técnica Utilizada
- Análise estruturada baseada em evidências: configuração, métricas e logs são correlacionados sem exigir exposição de raciocínio privado
- Role Prompting: define o modelo como "engenheiro de dados sênior com expertise em Elasticsearch"
- Requisito de Evidência: exige citação de trechos específicos dos logs e correlações entre artefatos
- Honestidade Epistêmica: seção explícita para incertezas e limitações
