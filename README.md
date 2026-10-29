# Playbook de IA Operacional - Aegis

Repositório contendo prompts de operação para o sistema Aegis, validados com testes automatizados via promptfoo e GitHub Actions.

## Estrutura

```text
.
├── .github/
│   └── workflows/
│       └── prompt-tests.yml
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
├── checkpoint-08/
│   └── entrega.md
├── checkpoint-09/
│   └── entrega.md
├── checkpoint-10/
│   └── entrega.md
├── run-tests.sh
└── README.md
