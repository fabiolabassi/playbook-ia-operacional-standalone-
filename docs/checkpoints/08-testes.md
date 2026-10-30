# Checkpoint 08 — Testes determinísticos

`nota-de-triagem`, `triagem-de-pods` e `networkpolicy-sentinel` têm asserts estruturais e de conteúdo
com fixtures representativas. Cada config executa `gpt-4o-mini` e `gemini-3.1-flash-lite`,
com limites de custo e latência por chamada.

Os limites são contratos a verificar em execuções reais; a validação do YAML não comprova desempenho,
custo ou qualidade. Após cadastrar `OPENAI_API_KEY` e `GOOGLE_API_KEY`, execute o workflow ou `bash run-tests.sh`
e registre os resultados sem editar ou inventar saídas.
