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
│   │   └── README.md
│   ├── migracao-forge-diagnostico/
│   │   ├── prompt.md
│   │   └── README.md
│   ├── migracao-forge-planejamento/
│   │   ├── prompt.md
│   │   └── README.md
│   ├── migracao-forge-execucao/
│   │   ├── prompt.md
│   │   └── README.md
│   └── README.md
├── run-tests.sh
└── README.md
```

## Compatibilidade com prompt-registry

O repositório foi organizado seguindo as convenções do template `prompt-registry`:

- categoria por domínio em pasta raiz (`devops/`)
- um prompt por diretório, nomeado pelo resultado e não pela técnica
- `prompt.md` contendo frontmatter + prompt parametrizável com `{{variavel}}`
- `README.md` com documentação humana (objetivo, uso, exemplo, limitações)
- versionamento semver por prompt (`versao: 1.0.0`)
- parâmetros documentados em `inputs` no frontmatter, alinhados aos placeholders do prompt

Essa estrutura permite que cada prompt seja tratado como artefato versionado, revisado e testado, em vez de texto solto no histórico do chat.

## Como Rodar os Testes Localmente

### Pré-requisitos

1. Node.js 20+
2. npm
3. Chave de API (OPENAI_API_KEY)

### Instalação

```bash
npm install -g promptfoo
```

### Executar Testes

```bash
# Teste individual
promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml

# Todos os testes
promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml -o results/nota-de-triagem.json
promptfoo eval -c devops/triagem-de-pods/promptfooconfig.yaml -o results/triagem-de-pods.json
promptfoo eval -c devops/networkpolicy-sentinel/promptfooconfig.yaml -o results/networkpolicy-sentinel.json
promptfoo eval -c devops/causa-raiz-cerebro/promptfooconfig.yaml -o results/causa-raiz-cerebro.json
```

## Configuração do GitHub Actions

### Secrets Necessários

Configure o seguinte secret no repositório GitHub (Settings → Secrets and variables → Actions):

- `OPENAI_API_KEY`: Chave da API da OpenAI (disponível em https://platform.openai.com/api-keys)

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
