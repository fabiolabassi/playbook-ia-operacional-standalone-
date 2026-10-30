# Checkpoint 10 - CI/CD e gate operacional

## Pipeline e gate

O workflow `.github/workflows/prompt-tests.yml` roda em todo `pull_request`, `push` e acionamento manual. Uma matriz executa os oito arquivos `promptfooconfig.yaml` — não há filtro de paths. A action oficial `promptfoo/promptfoo-action@v1` comenta os resultados nos PRs; `pull-requests: write` autoriza o comentário. `fail-on-threshold: 100` reprova qualquer suíte que não passe todos os asserts e o judge. Nenhuma etapa usa `continue-on-error`.

O gate combina:
- asserts determinísticos para formato, conteúdo, política de rede, latência e custo;
- rubric LLM com threshold 0.75 nas tarefas que exigem julgamento semântico;
- validação explícita de `OPENAI_API_KEY`.

As chaves devem ser cadastradas como Actions repository secrets; nunca em YAML. `no-share: true` evita compartilhar os resultados com o serviço de visualização. A action publica comentário no PR; pushes e execuções manuais deixam o resultado no log/summary do workflow.

## Decisões e alternativas

| Decisão | Escolhida | Alternativa e trade-off |
|---|---|---|
| Escopo do gatilho | Todo PR e push, suíte completa. Evita que uma mudança transversal deixe passar regressões em prompts não alterados, ao custo de mais chamadas e tempo. | Filtrar somente `devops/**` e workflow seria mais barato, mas alterações em scripts, dependências ou fixtures poderiam afetar a suíte sem dispará-la. |
| Gate | 100% de aprovação da suíte: asserts determinísticos e judge semântico. Impede que falhas conhecidas entrem; rubrics com threshold 0.75 reduzem a dependência de um score exato não determinístico. | Só asserts determinísticos seriam mais reprodutíveis/baratos, mas não avaliariam qualidade semântica. Um threshold mais alto/nota exata seria mais estrito, mas pode gerar falsos negativos por flutuação do juiz. |
| Comparação histórica | Para alterações em `prompt.md` ou `promptfooconfig.yaml`, a action aplica o gate atual e um passo adicional executa o mesmo contrato de testes ao prompt-base e ao head, comparando a taxa de aprovação. O head também precisa passar 100% do gate absoluto. | Avaliar apenas o head é mais barato, mas não mede delta histórico. Comparar apenas scores médios exige mais repetições e tolerância estatística para não confundir ruído do judge com regressão. |
| Cobertura | Executar todos os oito prompts a cada execução. Facilita o raciocínio e reduz risco de dependências entre prompts/configs. | Executar só prompts alterados economizaria tokens e tempo, mas mudanças compartilhadas podem afetar prompts não selecionados. |
| Provedores | OpenAI para a suíte e Ollama local (`qwen3:0.6b`) na avaliação de notas. Ollama não exige secret nem créditos de API, mas adiciona download, uso de CPU/memória e variação de qualidade. | Um segundo provedor de nuvem pode oferecer melhor qualidade, mas exige uma chave e orçamento adicionais. Um único OpenAI seria mais simples, mas não atenderia ao requisito de provedores distintos. |
| Comentários e resultados | Action oficial, comentário em PR, no máximo dois jobs e uma chamada concorrente por avaliação; cache por prompt/config e compartilhamento externo desligado. | Comentar apenas link para resultados evita texto no PR, mas piora feedback rápido; sem cache é mais simples, mas repete chamadas e aumenta custo. |

**Envelope de custo:** a suíte atual tem 16 avaliações-alvo (três casos de nota em dois provedores, quatro casos de triagem e os demais prompts) e cinco chamadas adicionais de judge: até 21 inferências para o gate do head. Com o limite de US$ 0,01 por chamada, o teto nominal é US$ 0,21 sem cache. Em mudanças de prompt/config, a avaliação baseline adiciona chamadas proporcionais aos casos/providers daquele prompt; o head pode reutilizar o cache da action, mas isso depende de as chaves de cache coincidirem. O custo real depende de tokens, preço vigente e cache; deve ser conferido no relatório/fatura do provedor. A matriz limitada a dois jobs reduz picos de concorrência, não o número total de avaliações.

**Comparação relativa:** a action oficial avalia o checkout atual; por isso, o workflow complementa-a com comparação explícita de taxa de aprovação entre o prompt do commit-base e o prompt do head, usando a configuração/testes do head. Mudanças em fixtures/configs são avaliadas pelo gate absoluto do head. Uma queda de aprovação comparada reprova o job; flutuação do juiz continua sendo possível e é mitigada pelo threshold rubric e pelo contrato absoluto.

## Execução e evidência

Os oito arquivos de configuração passaram por `promptfoo validate config`, mas não foi possível registrar uma execução real neste ambiente: a secret `OPENAI_API_KEY` configurada no GitHub não está disponível no shell local. O workflow inicia Ollama e baixa `qwen3:0.6b` na job da nota de triagem; não há evidência de run ou falha provocada até a execução pelo GitHub Actions. Pull requests de forks não recebem secrets do repositório por padrão e falharão na validação sem um mecanismo seguro aprovado pelos mantenedores.