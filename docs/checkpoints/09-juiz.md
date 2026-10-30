# Checkpoint 09 — LLM-as-judge

`causa-raiz-cerebro`, `backpressure-relay` e as três etapas do Forge usam OpenAI para gerar a resposta
e Gemini para avaliar rubricas específicas. O threshold é 0.75, equivalente a 6/8, e as rubricas
exigem que nenhum critério fique zerado.

**Calibração humana final pendente.** Foi feita uma revisão cega preliminar independente, sem consultar
as notas do Gemini antes de pontuar as respostas dos artifacts da execução #59. Como esta revisão foi
feita por um assistente de IA, ela não substitui a validação de uma pessoa responsável pelo playbook.
Além disso, a execução contém uma resposta por suíte e não oferece controles positivos e negativos
pareados; portanto, os dados são um piloto, não uma calibração conclusiva.

### Revisão cega preliminar — execução #59

Escala aplicada na revisão independente: quatro critérios de 0 a 2, na ordem da rubrica; aprovação exige pelo menos
6/8 e nenhum zero. As diferenças identificadas são materialmente relevantes: o Gemini aprovou as cinco
respostas, embora a revisão independente as tenha pontuado abaixo do limiar.

| Suíte | Revisão independente por critério | Total | Gemini | Divergência observada |
|---|---:|---:|---:|---|
| `causa-raiz-cerebro` | 1/0/0/0 | 1/8 — reprova | 7/8 — aprova | A resposta atribui a saturação a uma reindexação “travada”, sem sequência nem evidência; recomenda aumentar heap sem justificar e não explicita lacunas. |
| `backpressure-relay` | 2/1/1/1 | 5/8 — reprova | 8/8 — aprova | Afirma que opções garantem SLA e ausência de perda sem demonstrar mecanismos; recomenda autoscaling apesar do orçamento excedido e minimiza custo. |
| `migracao-forge-diagnostico` | 2/1/1/1 | 5/8 — reprova | 7/8 — aprova | Trata necessidade de tempo real do billing como fato, embora a tolerância a atraso esteja explicitamente pendente; não aborda duplicidade/ordenação em detalhe. |
| `migracao-forge-planejamento` | 2/0/2/1 | 5/8 — reprova | 7/8 — aprova | O plano não define idempotência, replay ou reconciliação, apesar de serem requisitos explícitos; presume broker e arquitetura não definidos. |
| `migracao-forge-execucao` | 2/0/1/1 | 4/8 — reprova | 8/8 — aprova | Inventa thresholds, prazos, owners e datas como fatos; checksums não cobrem por si só idempotência/reconciliação. |

**Ajuste feito:** as cinco rubricas foram endurecidas para penalizar hipóteses apresentadas como fatos,
garantias sem evidência, métricas/owners/datas inventados e menções genéricas sem tratamento operacional.
Os resultados da execução #59 são anteriores a esse ajuste; nenhuma reavaliação foi disparada para
evitar chamadas pagas. A eficácia das novas instruções ainda precisa ser verificada em uma próxima
execução autorizada.

**Próximo passo para concluir:** uma pessoa deve pontuar, sem ver os resultados do Gemini, exemplos bons
e ruins de cada rubrica, comparar as notas por critério e registrar os desacordos. Até essa revisão e
uma execução das rubricas ajustadas, os judges não devem ser considerados calibrados nem usados como
único gate de qualidade.

## Evidência de execução real

Na [execução #59](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903),
as cinco suítes com `llm-rubric` passaram:

| Suíte | Resultado |
|---|---|
| `causa-raiz-cerebro` | [success](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903/job/123852297236) |
| `backpressure-relay` | [success](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903/job/123852297280) |
| `migracao-forge-diagnostico` | [success](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903/job/123852297253) |
| `migracao-forge-planejamento` | [success](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903/job/123852297383) |
| `migracao-forge-execucao` | [success](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903/job/123852297263) |

O resultado comprova aprovação pelo gate configurado nessa execução, mas não substitui calibração
humana nem permite declarar que os judges estão calibrados.

## Teste do processo de calibração — execução local

Este teste reproduz o formato do método do repositório de referência: pontuar quatro respostas
boas/fracas, comparar cada critério e aceitar o judge apenas se a diferença absoluta for de no máximo
1 ponto **em cada critério de cada amostra**. As notas independentes abaixo são dados simulados para
testar o registro e a comparação; não representam uma avaliação humana real nem validam o judge.

### Rubrica detalhada

| Critério | 0 pontos | 1 ponto | 2 pontos |
|---|---|---|---|
| Causa e sintomas | Não identifica reindexação como hipótese plausível ou escolhe causa contradita | Menciona reindexação/heap sem conexão ou confunde causa e efeito | Usa reindexação lenta e aumento de heap/indexação como provável gatilho, separando sintomas e sem afirmar causalidade além da evidência |
| Sequência e evidências | Sequência ausente ou eventos invertidos | Cronologia parcial, com evidência/ordem incompleta | Correlaciona throughput/heap, throttling/fila, rejeições/circuit breaker e falhas de busca na ordem observada |
| Contenção e correção | Ação inútil ou arriscada sem pré-condições | Ação relevante, mas vaga ou sem validação | Contenção reversível, validação por heap/fila/p99 e investigação da concorrência/ritmo antes de retomar |
| Incerteza e integridade factual | Inventa fatos ou declara causalidade provada sem suporte | Incerteza genérica ou hipótese não qualificada | Explicita limites dos dados e verificações necessárias sem inventar fatos |

O gate continua exigindo soma >= 6/8 e nenhum critério zerado. Uma diferença acima de 1 em qualquer
critério reprova a calibração, mesmo que a decisão final de aprovação coincida.

### Amostras cegas e comparação

As quatro respostas estão em `devops/causa-raiz-cerebro/calibration/`; o config
`promptfooconfig.calibration.yaml` envia essas respostas pré-escritas pelo provider `echo` ao mesmo
judge Gemini, sem gerar novas respostas com OpenAI. Execução local: `eval-E1Z-2026-10-30T02:57:35`.
As notas simuladas foram dadas sem consultar as justificativas do Gemini.

| Amostra | Tipo | Avaliação humana simulada (C1/C2/C3/C4) | Gemini | Maior diferença | Resultado |
|---|---|---|---|---:|---|
| resposta-01-boa | Boa | 2/2/2/2 (8/8) | 2/2/2/2 (8/8), aprova | 0 | Dentro da tolerância |
| resposta-02-fraca | Fraca | 0/0/0/0 (0/8) | 0/0/0/0 (0/8), reprova | 0 | Dentro da tolerância |
| resposta-03-fraca | Fraca | 0/0/0/0 (0/8) | Reprova; justificativa qualitativa sem notas numéricas por critério | Não calculável | Comparação incompleta |
| resposta-04-boa-acao-vaga | Boa | 2/2/1/2 (7/8) | 2/2/2/2 (8/8), aprova | 1 (C3) | Dentro da tolerância |

**Resultado do teste:** nas três amostras com notas comparáveis, a diferença máxima foi de 1 ponto por
critério, dentro da tolerância escolhida. A amostra `resposta-03-fraca` foi reprovada pelo Gemini, mas
sua justificativa não trouxe pontuação numérica individual; a tolerância não pode ser calculada para
essa amostra. O teste demonstra o formato de comparação, não uma calibração efetiva do judge.

**Status: teste do processo registrado.** Uma calibração efetiva exigiria notas humanas reais e
pontuação explícita C1–C4 do judge em todas as amostras. As saídas completas do teste estão no arquivo
local `~/aegis-rubric-calibration-run.json`; ele não deve ser commitado, pois contém as respostas e
avaliações do judge.
