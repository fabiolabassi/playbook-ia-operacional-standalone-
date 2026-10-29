# Checkpoint 10 - CI/CD e gate operacional

## Objetivo
Executar testes automatizados em cada mudança relevante e bloquear regressões.

## Estratégia
- disparar workflow apenas em alterações de `devops/**` e do workflow
- validar a secret `OPENAI_API_KEY`
- executar promptfoo em todos os prompts relevantes
- comentar resumo do PR

## Trade-offs
### Alternativa 1: rodar em todo push
Prós:
- muito simples
Contras:
- dispara em docs e mudanças irrelevantes

### Alternativa 2: rodar só em prompts e workflow
Prós:
- econômico e relevante
Contras:
- exige disciplina na organização do repo

## Alternativa escolhida
Usamos o modelo 2, com validação da secret e gates determinísticos + judge LLM.

## Resultado esperado
A ação gera feedback rápido e evita que mudanças irrelevantes quebrem o pipeline.