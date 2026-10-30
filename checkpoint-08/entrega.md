# Checkpoint 08 - Testes de prompts estruturados

Os três prompts com saída estruturada têm suítes próprias:

| Prompt | Configuração | Cobertura |
|---|---|---|
| Nota de triagem | `devops/nota-de-triagem/promptfooconfig.yaml` | Três alertas; cinco rótulos, handle, limite de oito linhas, latência e custo |
| Triagem de pods | `devops/triagem-de-pods/promptfooconfig.yaml` | CrashLoop/OOM, falha de pull e falta de CPU, cluster saudável, latência e custo |
| NetworkPolicy | `devops/networkpolicy-sentinel/promptfooconfig.yaml` | Dois documentos, default-deny e allowlist, seletores/portas, ausência de regra allow-all, comentários, latência e custo |

Os provedores são `openai:gpt-4o-mini` e Ollama local (`qwen3:0.6b`) na configuração de nota de triagem. OpenAI usa a secret do repositório; Ollama evita créditos de API, mas consome tempo e recursos do runner e pode variar em qualidade/latência. Cada avaliação inclui limites de 5.000 ms e US$ 0,01.

**Validação:** Promptfoo 0.125.1 aceitou os oito arquivos com `promptfoo validate config`. **Evidência de execução:** ainda não há saída real do `promptfoo eval`, pois a chave do repositório não está disponível no shell local; Ollama também não está instalado localmente. Não registrei resultados inventados. O workflow instala Ollama e baixa o modelo; localmente, com Ollama em execução e `OPENAI_API_KEY` configurada, `bash run-tests.sh` grava JSONs em `results/`, que é ignorado pelo Git.
