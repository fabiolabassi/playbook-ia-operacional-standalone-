#!/bin/bash

set -u

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

echo "✓ promptfoo será executado via npx (versão 0.125.1)"

if [ -z "${OPENAI_API_KEY:-}" ]; then
    echo "ERRO: OPENAI_API_KEY não configurada."
    exit 1
fi

echo ""
echo "=== Criando diretório de resultados ==="
mkdir -p results

echo ""
echo "=== Rodando todos os testes de prompts ==="
failed=0
for config in devops/*/promptfooconfig.yaml; do
    name="$(basename "$(dirname "$config")")"
    echo "Rodando $name..."
    if npx --yes promptfoo@0.125.1 eval -c "$config" --no-share -o "results/$name.json"; then
        echo "✓ $name passou"
    else
        echo "✗ $name falhou"
        failed=1
    fi
done

echo ""
if [ "$failed" -ne 0 ]; then
    echo "=== Uma ou mais suítes falharam; consulte os logs e results/ ==="
    exit 1
fi

echo "=== Todas as suítes passaram ==="
echo "Resultados salvos em results/"
