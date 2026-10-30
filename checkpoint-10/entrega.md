# Checkpoint 10 - CI/CD e gate operacional

## Pipeline e gate

O workflow `.github/workflows/prompt-tests.yml` roda em pull requests destinados à `main`, em pushes para `main` e manualmente. Assim, um push numa branch com PR aberta é avaliado uma vez, pelo evento da PR. A matriz avalia os oito prompts, cada um com uma configuração OpenAI. A action oficial `promptfoo/promptfoo-action@v1` comenta os resultados nos PRs; `pull-requests: write` autoriza o comentário. `fail-on-threshold: 100` reprova qualquer suíte que não passe todos os asserts e o judge. Nenhuma etapa usa `continue-on-error`.

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
| Provedores | Só OpenAI `gpt-4o-mini`, pois é o único provedor com tokens/credenciais de API disponíveis para este projeto. Isso permite rodar o gate de custo real e evita introduzir um provider sem credencial/avaliação estável. **Não cumpre o requisito do desafio de ao menos dois provedores distintos.** | Meta Llama via Ollama não exige tokens de API e processa dados localmente, mas o ensaio Llama 3.2 1B reprovou 3/3 casos na execução #55. Anthropic/Google exigiriam credenciais e orçamento que não estão disponíveis. |
| Comentários e resultados | Action oficial, comentário em PR, no máximo dois jobs e uma chamada concorrente por avaliação; cache por prompt/config e compartilhamento externo desligado. | Comentar apenas link para resultados evita texto no PR, mas piora feedback rápido; sem cache é mais simples, mas repete chamadas e aumenta custo. |

**Envelope de custo:** os asserts `cost` limitam a US$ 0,01 por chamada para OpenAI, inclusive nos três casos da nota de triagem. Todo custo de inferência no gate é, portanto, reportável pelo provider; o preço real depende de tokens, tarifa vigente e cache e deve ser conferido no relatório/fatura. A avaliação baseline adiciona chamadas proporcionais aos casos do prompt; o head pode reutilizar cache, conforme as chaves coincidam. A matriz limitada a dois jobs reduz picos de concorrência, não o número total de avaliações.

## Escolha de modelo por checkpoint

`gpt-4o-mini` é o único modelo configurado para inferência e julgamento porque só há tokens/credenciais OpenAI disponíveis. Foi escolhido como compromisso entre custo por token, latência e qualidade adequada para saídas estruturadas e tarefas operacionais rubricadas; limites de US$ 0,01/chamada e 5 s são gates a medir, não garantia antecipada. A contrapartida de privacidade é que as entradas são enviadas a um serviço externo: os fixtures são fictícios e dados reais devem ser sanitizados. A tentativa com Meta Llama 3.2 1B via Ollama melhoraria processamento local, mas falhou todos os três exemplos de nota na execução #55; Anthropic/Google exigiriam credenciais não disponíveis. Usar só OpenAI deixa pendente o requisito explícito de dois provedores; não alegamos aderência integral. Saídas críticas continuam exigindo revisão humana.

| Checkpoint | Modelo/provedor escolhido | Trade-off considerado |
|---|---|---|
| CP01 — triagem de pods | OpenAI `gpt-4o-mini` | Custo/latência contidos para classificar snapshots; asserts cobrem causas e estado saudável. Sanitizar logs e identificadores antes de envio externo. |
| CP02 — nota de triagem | OpenAI `gpt-4o-mini` | Três casos estruturados com teto monetário e de latência. Llama local foi ensaiado, mas reprovou 3/3 exemplos; somente OpenAI fica no gate executável. |
| CP03 — causa-raiz | OpenAI `gpt-4o-mini`, inclusive como juiz | Evita custo de modelo maior, com rubrica para raciocínio; juiz ainda precisa calibração humana. Sanitizar artefatos antes de uso externo. |
| CP04 — backpressure | OpenAI `gpt-4o-mini` | Compara opções e restrições sob teto de custo/latência; rubric verifica qualidade. Fornecer cenários anonimizados. |
| CP05 — migração do Forge | OpenAI `gpt-4o-mini` em cadeia | Mantém inferência por etapa e contexto manejável; verificar saídas entre elos e sanitizar dados operacionais. |
| CP06 — NetworkPolicy | OpenAI `gpt-4o-mini`, com revisão humana obrigatória | Baixo custo para gerar YAML, mas o impacto de erro é alto; asserts e revisão de segurança são necessários. Nunca incluir credenciais. |
| CP07 — biblioteca versionada | Nenhum modelo no runtime | Organização/documentação não requer inferência; evita custo e exposição de dados sem benefício. |
| CP08 — testes estruturados | OpenAI `gpt-4o-mini` | Todos os testes de execução usam o provider com credencial disponível; teto de custo e latência por chamada. O requisito de dois provedores permanece pendente. |
| CP09 — LLM-as-judge | OpenAI `gpt-4o-mini` como juiz | Custo menor que modelo de maior capacidade; calibração contra notas humanas continua necessária antes de confiar no corte. |
| CP10 — CI/CD | OpenAI `gpt-4o-mini` nos configs; GitHub Actions | A secret OpenAI é injetada pelo Actions; o pipeline mede gates, mas as reprovações semânticas da execução #55 ainda precisam ser corrigidas. |

**Limitação de conformidade:** o desafio exige dois provedores distintos. Esta configuração usa apenas OpenAI porque é o único provider com tokens/credenciais disponíveis e a execução experimental Meta Llama 3.2 1B via Ollama falhou todos os casos da nota (#55). A escolha documenta a restrição real, mas deixa o requisito de diversidade de provedores não atendido. OpenAI recebe dados por API externa, portanto dados sensíveis devem ser removidos ou pseudonimizados.

**Comparação relativa:** a action oficial avalia o checkout atual; por isso, o workflow complementa-a com comparação explícita de taxa de aprovação entre o prompt do commit-base e o prompt do head, usando a configuração/testes do head. Mudanças em fixtures/configs são avaliadas pelo gate absoluto do head. Uma queda de aprovação comparada reprova o job; flutuação do juiz continua sendo possível e é mitigada pelo threshold rubric e pelo contrato absoluto.

## Execução e evidência

As oito configurações OpenAI passaram por `promptfoo validate config`. Na execução #55, os três casos da nota passaram com OpenAI; a configuração experimental Llama via Ollama reprovou os três casos e foi removida. A mesma execução teve falhas de rubric em backpressure, causa-raiz e as três etapas do Forge. O comparador de baseline foi corrigido no commit `179f9f9`; a execução seguinte é necessária para confirmar o parser corrigido e o estado atual do gate. A secret `OPENAI_API_KEY` configurada no GitHub não está disponível no shell local. Pull requests de forks não recebem secrets do repositório por padrão e falharão na validação sem um mecanismo seguro aprovado pelos mantenedores.