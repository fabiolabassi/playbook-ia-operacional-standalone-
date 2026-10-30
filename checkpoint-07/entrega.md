# Checkpoint 07 - A biblioteca vira código

## Mapeamento

A biblioteca adota as convenções do [prompt-registry](https://github.com/fabricioveronez/prompt-registry): categoria de domínio na raiz (`devops/`), uma pasta por resultado operacional e arquivos `prompt.md` e `README.md` em cada pasta. Os prompts usam frontmatter com `nome`, `descricao`, `versao`, `tags` e `inputs`; os nomes em `inputs` correspondem aos placeholders `{{...}}`.

Os seis itens do desafio são representados por oito prompts porque a migração do Forge é uma cadeia de três etapas: diagnóstico, planejamento e execução. Todos os prompts partem da versão `1.0.0`; revisões posteriores incrementam a versão do prompt.

## Inventário

- CP01: `devops/triagem-de-pods/`
- CP02: `devops/nota-de-triagem/`
- CP03: `devops/causa-raiz-cerebro/`
- CP04: `devops/backpressure-relay/`
- CP05: `devops/migracao-forge-diagnostico/`, `devops/migracao-forge-planejamento/`, `devops/migracao-forge-execucao/`
- CP06: `devops/networkpolicy-sentinel/`

O índice da categoria está em `devops/README.md`; o índice e instruções de uso estão no `README.md` da raiz.

## Limite da evidência

Este checkout já usa a estrutura do template, mas não contém metadados que provem um fork ou clone inicial do repositório modelo. A origem Git configurada é `fabiolabassi/playbook-ia-operacional-standalone-`. Não há execução de prompt/modelo registrada neste arquivo.
