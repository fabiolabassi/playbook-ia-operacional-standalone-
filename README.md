# Playbook de IA Operacional — Aegis

Biblioteca de prompts operacionais versionados, parametrizáveis e avaliados com Promptfoo.
Cada prompt e sua documentação vivem juntos; as suítes rodam no GitHub Actions em mudanças relevantes.

## Organização

```text
devops/<prompt>/
  prompt.md
  README.md
  promptfooconfig.yaml
.github/workflows/prompt-tests.yml
docs/checkpoints/
```

Os oito prompts dos checkpoints 01–06 estão em `devops/`, cada qual com configuração de teste.
Os três prompts estruturados comparam OpenAI e Google. Os prompts de saída aberta usam OpenAI para
geração e Gemini como judge. Isso exige `OPENAI_API_KEY` e `GOOGLE_API_KEY`; não coloque chaves em arquivos.

## Executar localmente

Instale Node.js 22+ e configure as duas chaves no ambiente. Em seguida:

```bash
bash run-tests.sh
```

O script executa todos os oito configs sem cache e grava resultados em `results/`.
Essas avaliações fazem chamadas reais: OpenAI pode gerar cobrança; a faixa gratuita Google tem cotas
e disponibilidade limitadas e não deve ser tratada como ilimitada. Configure controles de uso no provedor.

Para validar sintaxe e referências de configuração sem chamar modelos:

```bash
npx --yes promptfoo@0.125.1 validate config -c devops/nota-de-triagem/promptfooconfig.yaml
```

## CI

`.github/workflows/prompt-tests.yml` roda em PRs e pushes para `main` quando há alterações em
`devops/**` ou no workflow, e também manualmente. PRs internos avaliam somente os prompts alterados;
mudanças no workflow e execuções em `main` avaliam a suíte inteira. A concorrência é limitada a dois
jobs para controlar o volume de chamadas. Resultados são salvos como artifacts e um resumo é comentado no PR.

Cadastre os secrets `OPENAI_API_KEY` e `GOOGLE_API_KEY` em **Settings → Secrets and variables → Actions**.
PRs de forks não recebem secrets e não executam avaliações que chamem provedores.

## Checkpoints e estado da evidência

| Checkpoint | Entrega |
|---|---|
| 01–06 | Prompts e documentação em `devops/` |
| 07 | [`docs/checkpoints/07-biblioteca.md`](docs/checkpoints/07-biblioteca.md) |
| 08 | [`docs/checkpoints/08-testes.md`](docs/checkpoints/08-testes.md) |
| 09 | [`docs/checkpoints/09-juiz.md`](docs/checkpoints/09-juiz.md) |
| 10 | [`docs/checkpoints/10-ci.md`](docs/checkpoints/10-ci.md) |

As configurações e o workflow não substituem evidência de execução real nem calibração humana.
Essas etapas estão identificadas como pendentes até serem realizadas e registradas; não há resultados simulados.
