# Checkpoint 08 - Testes de prompts estruturados

Os três prompts com saída estruturada têm suítes próprias:

| Prompt | Configuração | Cobertura |
|---|---|---|
| Nota de triagem | `devops/nota-de-triagem/promptfooconfig.yaml` | Três alertas; cinco rótulos, handle, limite de oito linhas, latência e custo |
| Triagem de pods | `devops/triagem-de-pods/promptfooconfig.yaml` | CrashLoop/OOM, falha de pull e falta de CPU, cluster saudável, latência e custo |
| NetworkPolicy | `devops/networkpolicy-sentinel/promptfooconfig.yaml` | Dois documentos, default-deny e allowlist, seletores/portas, ausência de regra allow-all, comentários, latência e custo |

Os provedores são `openai:gpt-4o-mini` e Meta Llama 3.2 1B via Ollama, em configurações separadas que compartilham os mesmos três casos e asserts de conteúdo/latência. A configuração OpenAI aplica limite de US$ 0,01 por chamada; a configuração Ollama não inclui assertion monetária, porque o modelo local não tem cobrança por token de API nem fornece custo ao Promptfoo. OpenAI usa a secret do repositório; Ollama evita envio ao provedor externo e créditos de API, mas consome recursos locais/de runner e pode ter maior latência ou qualidade inferior. O alvo de latência de 5.000 ms continua valendo para ambos.

**Validação:** Promptfoo 0.125.1 aceitou as nove configurações atuais com `promptfoo validate config`. **Evidência de execução:** os logs do Actions para a configuração anterior confirmaram que Ollama iniciou e respondeu, mas o assert de custo compartilhado falhava por custo indisponível; a separação das configurações corrige essa incompatibilidade. O modelo foi alterado para Meta Llama 3.2 1B via Ollama para corresponder ao provedor indicado no desafio; sua nova execução ainda precisa ser confirmada no Actions. Não há execução autenticada local, pois a chave do repositório não está disponível no shell local e Ollama não está instalado localmente. Não registrei resultados inventados. O workflow instala Ollama e baixa o modelo; localmente, com Ollama em execução e `OPENAI_API_KEY` configurada, `bash run-tests.sh` grava JSONs em `results/`, que é ignorado pelo Git.
