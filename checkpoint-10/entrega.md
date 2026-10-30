# Checkpoint 10 - CI/CD e gate operacional

## Pipeline e gate

O workflow `.github/workflows/prompt-tests.yml` roda em todo `pull_request`, `push` e acionamento manual. Uma matriz avalia os oito prompts em nove configurações; a nota de triagem é executada separadamente com OpenAI e Ollama para aplicar asserts específicos de cada provedor. Não há filtro de paths. A action oficial `promptfoo/promptfoo-action@v1` comenta os resultados nos PRs; `pull-requests: write` autoriza o comentário. `fail-on-threshold: 100` reprova qualquer suíte que não passe todos os asserts e o judge. Nenhuma etapa usa `continue-on-error`.

O gate combina:
- asserts determinísticos para formato, conteúdo, política de rede e latência; custo é verificado somente quando o provedor reporta essa métrica;
- rubric LLM com threshold 0.75 nas tarefas que exigem julgamento semântico;
- validação explícita de `OPENAI_API_KEY`.

As chaves devem ser cadastradas como Actions repository secrets; nunca em YAML. `no-share: true` evita compartilhar os resultados com o serviço de visualização. A action publica comentário no PR; pushes e execuções manuais deixam o resultado no log/summary do workflow.

## Decisões e alternativas

| Decisão | Escolhida | Alternativa e trade-off |
|---|---|---|
| Escopo do gatilho | Todo PR e push, suíte completa. Evita que uma mudança transversal deixe passar regressões em prompts não alterados, ao custo de mais chamadas e tempo. | Filtrar somente `devops/**` e workflow seria mais barato, mas alterações em scripts, dependências ou fixtures poderiam afetar a suíte sem dispará-la. |
| Gate | 100% de aprovação da suíte: asserts determinísticos e judge semântico. Impede que falhas conhecidas entrem; rubrics com threshold 0.75 reduzem a dependência de um score exato não determinístico. | Só asserts determinísticos seriam mais reprodutíveis/baratos, mas não avaliariam qualidade semântica. Um threshold mais alto/nota exata seria mais estrito, mas pode gerar falsos negativos por flutuação do juiz. |
| Comparação histórica | Para alterações em `prompt.md`, `promptfooconfig.yaml` ou nos casos externos de teste, a action aplica o gate atual e um passo adicional executa o contrato ao prompt-base e ao head, comparando a taxa de aprovação. O head também precisa passar 100% do gate absoluto. | Avaliar apenas o head é mais barato, mas não mede delta histórico. Comparar apenas scores médios exige mais repetições e tolerância estatística para não confundir ruído do judge com regressão. |
| Cobertura | Executar todos os oito prompts a cada execução. Facilita o raciocínio e reduz risco de dependências entre prompts/configs. | Executar só prompts alterados economizaria tokens e tempo, mas mudanças compartilhadas podem afetar prompts não selecionados. |
| Provedores | OpenAI para as suítes, incluindo a nota com limite de custo de US$ 0,01 por chamada; Meta Llama 3.2 1B via Ollama roda separadamente nos mesmos casos de nota, sem cobrança de API por token. A inferência local ainda consome CPU/memória/energia e pode variar em qualidade e latência. | Um segundo provedor de nuvem pode oferecer melhor qualidade, mas exige uma chave e orçamento adicionais. Um único OpenAI seria mais simples, mas não atenderia ao requisito de provedores distintos. |
| Comentários e resultados | Action oficial, comentário em PR, no máximo dois jobs e uma chamada concorrente por avaliação; cache por prompt/config e compartilhamento externo desligado. | Comentar apenas link para resultados evita texto no PR, mas piora feedback rápido; sem cache é mais simples, mas repete chamadas e aumenta custo. |

**Envelope de custo:** os asserts `cost` limitam a US$ 0,01 por chamada onde aplicável. Na nota de triagem, as configurações OpenAI e Ollama reutilizam `tests.yaml`, mas são executadas em jobs separados; `defaultTest` aplica o limite apenas à configuração OpenAI. A inferência local do Llama não tem preço por token de API, mas tem custo operacional de infraestrutura que não é quantificado pelo assert Promptfoo. Assim o gate monetário permanece ativo para chamadas pagas e não trata uma métrica de API inexistente como zero ou falha. A avaliação baseline adiciona chamadas proporcionais aos casos/providers daquele prompt; o head pode reutilizar o cache da action, mas isso depende de as chaves de cache coincidirem. O custo real da OpenAI depende de tokens, preço vigente e cache; deve ser conferido no relatório/fatura do provedor. A matriz limitada a dois jobs reduz picos de concorrência, não o número total de avaliações.

## Escolha de modelo por checkpoint

`gpt-4o-mini` é a opção de API configurada para os prompts: busca custo por token e latência menores que modelos de maior capacidade, mantendo qualidade suficiente para saídas estruturadas e para tarefas operacionais com rubrica. O limite de US$ 0,01/chamada e de 5 s é um gate a medir, não uma afirmação de que toda execução já cumpriu esses valores. Para CP02/08, Meta Llama 3.2 1B via Ollama é a segunda família/provedor: sem cobrança de API por token e com dados processados localmente, em troca de consumo de recursos locais e possível perda de qualidade/latência. Saídas críticas continuam exigindo revisão humana.

| Checkpoint | Modelo/provedor escolhido | Trade-off considerado |
|---|---|---|
| CP01 — triagem de pods | OpenAI `gpt-4o-mini` | Baixo custo/latência para classificar snapshots estruturados; qualidade avaliada por asserts. Logs podem conter segredos/PII: sanitizar antes de envio externo. |
| CP02 — nota de triagem | OpenAI `gpt-4o-mini` e Meta Llama 3.2 1B via Ollama | Compara API com limite monetário a inferência local sem tarifa de token; Ollama mantém dados locais, mas pode ser mais lento e menos consistente. |
| CP03 — causa-raiz | OpenAI `gpt-4o-mini` e juiz OpenAI configurado | Raciocínio semântico coberto por rubric e limite de custo; não usar dados reais identificáveis sem sanitização. Calibração do juiz permanece pendente. |
| CP04 — backpressure | OpenAI `gpt-4o-mini` | Adequado para comparar opções e restrições com custo/latência controlados; qualidade semântica é julgada, sem inventar custo de infraestrutura. Enviar apenas cenários anonimizados. |
| CP05 — migração do Forge | OpenAI `gpt-4o-mini` em cadeia | Mantém custo/latência por etapa e contexto suficiente para planejar em passos; cada elo precisa verificar a saída anterior. Dados internos devem ser sanitizados antes do provedor externo. |
| CP06 — NetworkPolicy | OpenAI `gpt-4o-mini`, com revisão humana obrigatória | Baixo custo para gerar YAML, mas erro tem alto impacto; asserts e revisão de segurança são necessários. Não enviar credenciais/endereços sensíveis. |
| CP07 — biblioteca versionada | Nenhum modelo no runtime | É organização/documentação; evita chamadas e exposição de dados sem benefício de inferência. Os prompts já têm provedor configurado para uso. |
| CP08 — testes estruturados | OpenAI `gpt-4o-mini`; Meta Llama 3.2 1B via Ollama na nota | OpenAI tem teto de custo e latência por chamada; Ollama valida os mesmos casos sem custo de token de API e sem enviar entradas para nuvem. |
| CP09 — LLM-as-judge | OpenAI `gpt-4o-mini` como juiz | Custo menor que um modelo maior e julgamento suficiente como gate inicial; calibração contra nota humana é requisito antes de confiar no corte. |
| CP10 — CI/CD | Repete os providers/modelos dos configs | Secret OpenAI fica no GitHub Actions; Ollama roda localmente no runner. O pipeline mede tempo/custo, mas as execuções recentes ainda mostraram falhas a corrigir. |

O Ollama atende ao segundo provedor no exercício porque serve um modelo **Meta Llama**; Qwen via Ollama não demonstraria, por si só, a família Meta explicitamente citada no enunciado. OpenAI recebe dados por API externa; Ollama local melhora privacidade, mas não elimina a necessidade de remover dados sensíveis dos fixtures.

**Comparação relativa:** a action oficial avalia o checkout atual; por isso, o workflow complementa-a com comparação explícita de taxa de aprovação entre o prompt do commit-base e o prompt do head, usando a configuração/testes do head. Mudanças em fixtures/configs são avaliadas pelo gate absoluto do head. Uma queda de aprovação comparada reprova o job; flutuação do juiz continua sendo possível e é mitigada pelo threshold rubric e pelo contrato absoluto.

## Execução e evidência

As configurações devem passar por `promptfoo validate config`. As execuções reais após o commit `4d5f285` mostraram que `cost` falha com Ollama porque o provedor não reporta custo ao Promptfoo. A configuração foi separada: o OpenAI mantém o limite monetário e o Ollama executa os mesmos casos sem esse assert. Essas execuções também registraram falhas de rubric em outras suítes e um relatório-base sem resultados na comparação de `triagem-de-pods`; portanto, o gate completo ainda requer nova execução e correção dessas falhas. A secret `OPENAI_API_KEY` configurada no GitHub não está disponível no shell local. Pull requests de forks não recebem secrets do repositório por padrão e falharão na validação sem um mecanismo seguro aprovado pelos mantenedores.