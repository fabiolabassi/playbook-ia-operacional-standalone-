# Checkpoint 08 — Testes determinísticos

`nota-de-triagem`, `triagem-de-pods` e `networkpolicy-sentinel` têm asserts estruturais e de conteúdo
com fixtures representativas. Cada config executa `gpt-4o-mini` e `gemini-3.1-flash-lite`,
com limites de custo e latência por chamada.

## Evidência de execução real

Na execução [#59 do GitHub Actions](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903),
em 29/10/2026, os três jobs determinísticos terminaram com sucesso:

| Configuração | Job |
|---|---|
| `nota-de-triagem` | [success](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903/job/123852297190) |
| `triagem-de-pods` | [success](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903/job/123852297336) |
| `networkpolicy-sentinel` | [success](https://github.com/fabiolabassi/playbook-ia-operacional-standalone-/actions/runs/40990743903/job/123852297382) |

Cada job executou o config Promptfoo com os provedores definidos; `success` confirma que as avaliações
terminaram sem asserts reprovados. Os JSONs completos foram publicados como artifacts do run, com
retenção de 14 dias. A evidência vale para os casos e versões executados nessa execução; não garante
desempenho ou qualidade em execuções futuras.
