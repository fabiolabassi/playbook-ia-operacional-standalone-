# Playbook de IA Operacional - Aegis

Repositório contendo prompts de operação para o sistema Aegis, validados com testes automatizados via promptfoo e GitHub Actions.

## Estrutura

```
.
├── .github/
│   └── workflows/
│       └── prompt-tests.yml    # Pipeline de CI/CD
├── devops/
│   ├── nota-de-triagem/
│   │   ├── prompt.md
│   │   ├── promptfooconfig.yaml
│   │   └── README.md
│   ├── triagem-de-pods/
│   ├── networkpolicy-sentinel/
│   ├── causa-raiz-cerebro/
│   └── ...
└── README.md
```

## Como Rodar os Testes Localmente

### Pré-requisitos

1. Node.js 20+
2. npm
3. Chaves de API (OPENAI_API_KEY e ANTHROPIC_API_KEY)

### Instalação

```bash
npm install -g promptfoo
```

### Executar Testes

```bash
# Teste individual
promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml

# Todos os testes
promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml --output-file results/nota-de-triagem.json
promptfoo eval -c devops/triagem-de-pods/promptfooconfig.yaml --output-file results/triagem-de-pods.json
promptfoo eval -c devops/networkpolicy-sentinel/promptfooconfig.yaml --output-file results/networkpolicy-sentinel.json
promptfoo eval -c devops/causa-raiz-cerebro/promptfooconfig.yaml --output-file results/causa-raiz-cerebro.json
```

## Configuração do GitHub Actions

### Secrets Necessários

Configure os seguintes secrets no repositório GitHub (Settings → Secrets and variables → Actions):

- `OPENAI_API_KEY`: Chave da API da OpenAI
- `ANTHROPIC_API_KEY`: Chave da API da Anthropic

### Workflow

O workflow roda automaticamente em:
- Pull requests para o branch main
- Push para o branch main
- Disparo manual (workflow_dispatch)

O workflow falha se qualquer teste falhar, garantindo que nenhuma regressão entre no repositório.

## Estratégia de Testes

### Testes Determinísticos (nota-de-triagem, triagem-de-pods, networkpolicy-sentinel)

Usam asserts simples (contains, regex, javascript) para validar saídas estruturadas.

### LLM-as-Judge (causa-raiz-cerebro)

Usa um juiz LLM para avaliar a qualidade da análise de causa-raiz em uma escala de 0-8, com corte ≥ 6 para aprovação.

## Evidências de Execução

Após rodar os testes (localmente ou via GitHub Actions), registre os resultados em:
- `checkpoint-08/entrega.md` - Testes determinísticos
- `checkpoint-09/entrega.md` - LLM-as-judge
- `checkpoint-10/entrega.md` - Pipeline em produção

## Licença

Este repositório faz parte do material didático da pós-graduação em AIOps e Inteligência Artificial com Engenharia Cloud.
