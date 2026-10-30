# Playbook de IA Operacional - Aegis

Repositório de prompts operacionais parametrizáveis para a Aegis, versionados como código, acompanhados por avaliações Promptfoo e executados em GitHub Actions.

## Executar as avaliações

Cada prompt em `devops/` possui uma configuração Promptfoo. As avaliações usam `openai:gpt-4o-mini`; a nota de triagem aplica limite de custo de US$ 0,01 por chamada. Para executar a suíte completa localmente, instale Node.js 22+ com npm e configure `OPENAI_API_KEY` no ambiente. O script usa `npx` para executar a versão fixada de Promptfoo. Não grave chaves no repositório.

**Limitação do desafio:** a execução foi restrita a OpenAI porque este é o único provedor para o qual há tokens/credenciais disponíveis. O enunciado exige pelo menos dois provedores distintos; portanto, esta escolha não satisfaz esse requisito e não deve ser apresentada como aderência integral. A execução anterior do Meta Llama 3.2 1B via Ollama reprovou os três casos da nota de triagem e foi removida do gate.

```bash
bash run-tests.sh
```

O workflow roda em cada pull request e push, exige aprovação de 100% dos testes e publica o resultado no PR. Os testes usam entradas fictícias; em uso real, remova ou pseudonimize identificadores de clientes, hostnames e outros dados sensíveis antes de enviá-los a provedores externos.

## Estrutura

```text
.
├── .github/
│   ├── scripts/
│   │   └── compare-evals.cjs
│   └── workflows/
│       └── prompt-tests.yml
├── devops/
│   ├── nota-de-triagem/
│   │   ├── prompt.md
│   │   ├── promptfooconfig.yaml
│   │   ├── tests.yaml
│   │   └── README.md
│   ├── triagem-de-pods/
│   │   ├── prompt.md
│   │   ├── promptfooconfig.yaml
│   │   └── README.md
│   ├── networkpolicy-sentinel/
│   │   ├── prompt.md
│   │   ├── promptfooconfig.yaml
│   │   └── README.md
│   ├── causa-raiz-cerebro/
│   │   ├── prompt.md
│   │   ├── promptfooconfig.yaml
│   │   └── README.md
│   ├── backpressure-relay/
│   │   ├── prompt.md
│   │   ├── promptfooconfig.yaml
│   │   └── README.md
│   ├── migracao-forge-diagnostico/
│   │   ├── prompt.md
│   │   ├── promptfooconfig.yaml
│   │   └── README.md
│   ├── migracao-forge-planejamento/
│   │   ├── prompt.md
│   │   ├── promptfooconfig.yaml
│   │   └── README.md
│   ├── migracao-forge-execucao/
│   │   ├── prompt.md
│   │   ├── promptfooconfig.yaml
│   │   └── README.md
│   └── README.md
├── checkpoint-07/
│   └── entrega.md
├── checkpoint-08/
│   └── entrega.md
├── checkpoint-09/
│   └── entrega.md
├── checkpoint-10/
│   └── entrega.md
├── .gitignore
├── run-tests.sh
└── README.md
```

Os oito prompts sob `devops/` têm configuração e fixture de avaliação. Os três outputs estruturados usam asserts determinísticos; os prompts de diagnóstico, decisão e planejamento usam avaliação LLM-as-judge quando qualidade semântica é necessária. A biblioteca segue a estrutura do template [prompt-registry](https://github.com/fabricioveronez/prompt-registry).

## Prompts

- [Triagem de pods](./devops/triagem-de-pods/)
- [Nota de triagem](./devops/nota-de-triagem/)
- [Causa-raiz do Cerebro](./devops/causa-raiz-cerebro/)
- [Estratégia de backpressure do Relay](./devops/backpressure-relay/)
- [Migração do Forge: diagnóstico](./devops/migracao-forge-diagnostico/)
- [Migração do Forge: planejamento](./devops/migracao-forge-planejamento/)
- [Migração do Forge: execução](./devops/migracao-forge-execucao/)
- [NetworkPolicy do Sentinel](./devops/networkpolicy-sentinel/)
