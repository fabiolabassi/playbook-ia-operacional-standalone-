#!/bin/bash

set -e

echo "=== Verificando pré-requisitos ==="

if ! command -v node &> /dev/null; then
    echo "ERRO: Node.js não encontrado. Instale Node.js 20+ em https://nodejs.org/"
    exit 1
fi

echo "✓ Node.js encontrado: $(node --version)"

if ! command -v npm &> /dev/null; then
    echo "ERRO: npm não encontrado."
    exit 1
fi

echo "✓ npm encontrado: $(npm --version)"

if ! command -v promptfoo &> /dev/null; then
    echo "promptfoo não encontrado. Instalando..."
    npm install -g promptfoo
fi

echo "✓ promptfoo encontrado"

if [ -z "$OPENAI_API_KEY" ]; then
    echo "AVISO: OPENAI_API_KEY não configurada."
    echo "Configure com: export OPENAI_API_KEY=..."
    exit 1
fi

echo ""
echo "=== Criando diretório de resultados ==="
mkdir -p results

echo ""
echo "=== Rodando testes ==="

echo "Rodando nota-de-triagem..."
promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml -o results/nota-de-triagem.json

echo "Rodando triagem-de-pods..."
promptfoo eval -c devops/triagem-de-pods/promptfooconfig.yaml -o results/triagem-de-pods.json

echo "Rodando networkpolicy-sentinel..."
promptfoo eval -c devops/networkpolicy-sentinel/promptfooconfig.yaml -o results/networkpolicy-sentinel.json

echo "Rodando causa-raiz-cerebro..."
promptfoo eval -c devops/causa-raiz-cerebro/promptfooconfig.yaml -o results/causa-raiz-cerebro.json

echo ""
echo "=== Testes concluídos ==="
echo "Resultados salvos em results/"
