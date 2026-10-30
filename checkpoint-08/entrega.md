# Checkpoint 08 - Testes de prompts estruturados

Os três prompts com saída estruturada têm suítes próprias:

| Prompt | Configuração | Cobertura |
|---|---|---|
| Nota de triagem | `devops/nota-de-triagem/promptfooconfig.yaml` | Três alertas; cinco rótulos, handle, limite de oito linhas, latência e custo |
| Triagem de pods | `devops/triagem-de-pods/promptfooconfig.yaml` | CrashLoop/OOM, falha de pull e falta de CPU, cluster saudável, latência e custo |
| NetworkPolicy | `devops/networkpolicy-sentinel/promptfooconfig.yaml` | Dois documentos, default-deny e allowlist, seletores/portas, ausência de regra allow-all, comentários, latência e custo |

As suítes executáveis usam somente `openai:gpt-4o-mini`, o único provedor para o qual há tokens/credenciais disponíveis. Na nota, os três casos compartilham os asserts de conteúdo e latência, além de limite de US$ 0,01 por chamada. A alternativa Meta Llama 3.2 1B via Ollama foi testada na execução #55, mas reprovou nos três casos e foi retirada para não manter um gate que não passa.

**Aderência:** essa decisão é uma limitação em relação ao enunciado, que pede pelo menos dois provedores distintos. O uso apenas de OpenAI não cumpre esse item; não simulamos um segundo provedor nem declaramos conformidade integral. OpenAI oferece qualidade adequada e latência/custo por token controláveis pelo assert, mas envia os dados ao serviço externo; sanitizar PII, segredos e identificadores antes de qualquer uso real.

**Validação:** Promptfoo 0.125.1 validou as oito configurações OpenAI. **Evidência de execução:** na execução #55, OpenAI passou os três casos da nota (3/3); o teste experimental com Meta Llama 3.2 1B via Ollama reprovou os três (0/3) e foi removido. A execução não foi inventada nem substituída por mock. O segredo do repositório não está disponível no shell local; `bash run-tests.sh` requer `OPENAI_API_KEY` e grava JSONs em `results/`, ignorados pelo Git.
