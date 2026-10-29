#!/bin/bash

# Script para rodar os testes do promptfoo localmente
# Uso: ./run-tests.sh

set -e

echo "=== Verificando pré-requisitos ==="

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "ERRO: Node.js não encontrado. Instale Node.js 20+ em https://nodejs.org/"
    exit 1
fi

echo "✓ Node.js encontrado: $(node --version)"

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo "ERRO: npm não encontrado."
    exit 1
fi

echo "✓ npm encontrado: $(npm --version)"

# Verificar promptfoo
if ! command -v promptfoo &> /dev/null; then
    echo "promptfoo não encontrado. Instalando..."
    npm install -g promptfoo
fi

echo "✓ promptfoo encontrado"

# Verificar chaves de API
if [ -z "$GROQ_API_KEY" ]; then
    echo "AVISO: GROQ_API_KEY não configurada. Configure com:"
    echo "  export GROQ_API_KEY=gsk_..."
    echo ""
    echo "Deseja continuar sem a chave de API? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "=== Criando diretório de resultados ==="
mkdir -p results

echo ""
echo "=== Rodando testes ==="

# Teste 1: nota-de-triagem
echo "Rodando nota-de-triagem..."
promptfoo eval -c devops/nota-de-triagem/promptfooconfig.yaml -o results/nota-de-triagem.json

# Teste 2: triagem-de-pods
echo "Rodando triagem-de-pods..."
promptfoo eval -c devops/triagem-de-pods/promptfooconfig.yaml -o results/triagem-de-pods.json

# Teste 3: networkpolicy-sentinel
echo "Rodando networkpolicy-sentinel..."
promptfoo eval -c devops/networkpolicy-sentinel/promptfooconfig.yaml -o results/networkpolicy-sentinel.json

# Teste 4: causa-raiz-cerebro
echo "Rodando causa-raiz-cerebro..."
promptfoo eval -c devops/causa-raiz-cerebro/promptfooconfig.yaml -o results/causa-raiz-cerebro.json

echo ""
echo "=== Testes concluídos ==="
echo "Resultados salvos em results/"
echo ""
echo "Para ver os resultados:"
echo "  cat results/nota-de-triagem.json"
echo "  cat results/triagem-de-pods.json"
echo "  cat results/networkpolicy-sentinel.json"
echo "  cat results/causa-raiz-cerebro.json"
