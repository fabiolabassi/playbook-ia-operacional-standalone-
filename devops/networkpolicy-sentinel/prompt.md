---
nome: Endurecimento de NetworkPolicy
descricao: Corrige manifesto permissivo de NetworkPolicy e transforma em política default-deny com regras explícitas
versao: 1.0.0
tags: [kubernetes, networkpolicy, seguranca, hardening]
inputs:
  - nome: manifesto_permissivo
    descricao: NetworkPolicy permissivo a ser corrigida (com allow-all)
  - nome: regras_seguranca
    descricao: Padrão de segurança da Aegis (default-deny, regras de ingress/egress)
  - nome: mapa_servicos
    descricao: Labels e ports de cada serviço (Sentinel, Relay, API gateway, Forge, Cerebro, DNS)
---

Você é um engenheiro de segurança sênior na Aegis. Sua tarefa é corrigir um manifesto de NetworkPolicy permissivo e transformá-lo em uma política de rede segura seguindo os padrões da empresa.

## Manifesto Permissivo (a ser corrigido)
{{manifesto_permissivo}}

## Regras de Segurança da Aegis
{{regras_seguranca}}

## Mapa de Serviços (labels e ports)
{{mapa_servicos}}

## Regras de saída obrigatórias
Sua resposta DEVE ser um único bloco YAML válido, sem marcadores de código markdown, começando diretamente com `apiVersion` e terminando no final do manifesto.

O YAML deve obedecer a estes requisitos absolutos:
- usar `kind: NetworkPolicy`
- listar `policyTypes:` com `Ingress` e `Egress`
- incluir `podSelector` com label do Sentinel: `app: sentinel`
- usar `default-deny` explícito: não pode existir regra allow-all; não pode haver `- {}` em ingress ou egress
- o ingress deve permitir apenas tráfego do Relay e do API gateway
- o egress deve permitir apenas tráfego do Forge na porta 5432, do Cerebro na porta 9200 e do DNS interno na porta 53
- cada regra deve ter comentário `#` explicando o fluxo permitido
- o namespace deve continuar sendo `sentinel-prod`
- use EXATAMENTE os labels e portas do mapa de serviços
- o YAML deve ser válido e consistente, sem texto extra antes ou depois

## Seu Raciocínio

### 1. Analisar o manifesto permissivo
- Identifique o que está errado no manifesto original (por exemplo: `podSelector: {}` e `- {}` liberam tudo)
- Entenda o namespace protegido: `sentinel-prod`
- Identifique os riscos de um allow-all no namespace

### 2. Aplicar o padrão default-deny
- Crie uma política que bloqueie tudo por padrão
- A política deve ter `podSelector` correto para os pods do Sentinel
- Não pode haver `- {}` em ingress/egress

### 3. Adicionar regras de ingress permitidas
- O tráfego de entrada do Sentinel deve vir somente do Relay e da API gateway
- Use os labels corretos do mapa de serviços: `app: relay` e `app: api-gateway`
- Use `namespaceSelector` ou `podSelector` com os labels corretos
- Cada regra precisa de comentário explicando o fluxo legítimo

### 4. Adicionar regras de egress permitidas
- O tráfego de saída do Sentinel deve ir somente para:
  - Forge na porta 5432
  - Cerebro na porta 9200
  - DNS interno na porta 53
- Use os labels corretos do mapa de serviços: `app: forge`, `app: cerebro`, `k8s-app: kube-dns`
- Cada regra precisa de comentário explicando o fluxo legítimo

### 5. Verificar a correção
- Não existe `- {}` em ingress ou egress
- O manifesto é um único YAML válido
- O namespace continua `sentinel-prod`
- `podSelector` usa `app: sentinel`
- ingress e egress estão restritos ao mínimo necessário
- cada regra contém um comentário `#`

## Formato de Saída
Produza UM ÚNICO manifesto YAML corrigido e endurecido.

Requisitos obrigatórios do manifesto:
- `apiVersion: networking.k8s.io/v1`
- `kind: NetworkPolicy`
- `metadata:` com `namespace: sentinel-prod`
- `spec:` com `podSelector` para `app: sentinel`
- `policyTypes:` com `Ingress` e `Egress`
- `ingress` com regras que liberam apenas Relay e API gateway
- `egress` com regras que liberam apenas Forge (5432), Cerebro (9200) e DNS (53)
- comentários `#` em todas as regras
- não usar `- {}` em nenhuma parte
- sem blocos de código Markdown, sem texto extra, sem explicação fora do YAML

## Instruções Adicionais
- Use EXATAMENTE as labels e portas do mapa de serviços
- Não invente namespaces, labels, portas ou nomes de serviços
- Não use `- {}` em nenhuma regra
- O YAML deve ser válido e coerente
- Produza apenas o manifesto final

---

Agora, produza o manifesto NetworkPolicy corrigido e endurecido conforme acima.
