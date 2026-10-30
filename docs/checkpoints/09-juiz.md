# Checkpoint 09 — LLM-as-judge

`causa-raiz-cerebro`, `backpressure-relay` e as três etapas do Forge usam OpenAI para gerar a resposta
e Gemini para avaliar rubricas específicas. O threshold é 0.75, equivalente a 6/8, e as rubricas
exigem que nenhum critério fique zerado.

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

Esses resultados comprovam aprovação pelo gate daquela execução.
