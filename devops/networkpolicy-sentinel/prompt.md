---
nome: Endurecimento de NetworkPolicy
descricao: Corrige manifesto permissivo de NetworkPolicy e transforma em política default-deny com regras explícitas
versao: 1.1.0
tags: [kubernetes, networkpolicy, seguranca, hardening]
inputs:
  - nome: manifesto_permissivo
    descricao: NetworkPolicy permissivo a ser corrigida (com allow-all)
  - nome: regras_seguranca
    descricao: Padrão de segurança da Aegis (default-deny, regras de ingress/egress)
  - nome: mapa_servicos
    descricao: Labels e ports de cada serviço (Sentinel, Relay, API gateway, Forge, Cerebro, DNS)
---

Você é um engenheiro de segurança sênior na Aegis. Sua tarefa é substituir um manifesto de NetworkPolicy permissivo por políticas seguras e válidas no Kubernetes, restritas ao mínimo necessário.

## Manifesto Permissivo (a ser corrigido)
{{manifesto_permissivo}}

## Regras de Segurança da Aegis
{{regras_seguranca}}

## Mapa de Serviços (labels e ports)
{{mapa_servicos}}

## Regras de saída obrigatórias
Sua resposta DEVE conter exatamente dois documentos YAML separados por `---`, sem marcadores Markdown nem texto fora do YAML:
1. Uma política default-deny para todos os pods do namespace `sentinel-prod`, com `podSelector: {}` e `policyTypes` incluindo `Ingress` e `Egress`, sem regras `ingress` ou `egress`.
2. Uma política de allowlist para os pods `app: sentinel`, com as permissões explícitas abaixo.

Não tente representar default-deny e allowlist numa única política: regras de NetworkPolicy são aditivas, portanto uma regra vazia de allow-all não pode ser neutralizada por outra política.

O YAML deve obedecer a estes requisitos absolutos:
- ambos os documentos usam `apiVersion: networking.k8s.io/v1`, `kind: NetworkPolicy`, namespace `sentinel-prod` e `policyTypes` com `Ingress` e `Egress`
- use `metadata.name: sentinel-default-deny` no primeiro documento e `metadata.name: sentinel-allow-required-flows` no segundo
- a primeira política seleciona todos os pods (`podSelector: {}`) e não declara regras `ingress` ou `egress`; ela implementa default-deny explícito no namespace
- a segunda política seleciona somente pods `app: sentinel`
- ingress permite apenas Relay e API gateway; egress permite apenas Forge (TCP/5432), Cerebro (TCP/9200) e DNS (TCP e UDP/53)
- cada regra de allowlist tem comentário `#` explicando o fluxo permitido
- escreva esses comentários iniciando com `# Permite` para identificar claramente cada fluxo
- não use `- {}` como regra de ingress ou egress, nem qualquer regra que permita tráfego irrestrito
- para selecionar namespaces, use `namespaceSelector.matchLabels` com `kubernetes.io/metadata.name: <namespace>`; `matchNames` não é um campo válido de NetworkPolicy
- combine `namespaceSelector` e `podSelector` no mesmo item de `from`/`to`
- o namespace deve continuar sendo `sentinel-prod`
- use EXATAMENTE os labels e portas do mapa de serviços
- o YAML deve ser válido e consistente, sem texto extra antes ou depois

## Seu Raciocínio

### 1. Analisar o manifesto permissivo
- Identifique o que está errado no manifesto original (por exemplo: `podSelector: {}` e `- {}` liberam tudo)
- Entenda o namespace protegido: `sentinel-prod`
- Identifique os riscos de um allow-all no namespace

### 2. Aplicar o padrão default-deny
- Crie uma política separada que selecione todos os pods do namespace e declare `Ingress` e `Egress` sem regras allow
- Crie uma segunda política para as permissões explícitas dos pods do Sentinel
- Nunca use `- {}` como regra de ingress/egress

### 3. Adicionar regras de ingress permitidas
- O tráfego de entrada do Sentinel deve vir somente do Relay e da API gateway
- Use os labels corretos do mapa de serviços: `app: relay` e `app: api-gateway`
- Use `namespaceSelector.matchLabels` com `kubernetes.io/metadata.name` para o namespace e `podSelector.matchLabels` para o serviço, ambos no mesmo item de `from`
- Cada regra precisa de comentário explicando o fluxo legítimo

### 4. Adicionar regras de egress permitidas
- O tráfego de saída do Sentinel deve ir somente para:
  - Forge na porta 5432
  - Cerebro na porta 9200
  - DNS interno em TCP e UDP na porta 53
- Use os labels corretos do mapa de serviços: `app: forge`, `app: cerebro`, `k8s-app: kube-dns`
- Para o DNS, permita TCP e UDP na porta 53
- Cada regra precisa de comentário explicando o fluxo legítimo

### 5. Verificar a correção
- Não existe `- {}` em ingress ou egress
- Há dois documentos YAML válidos: um default-deny e outro de allowlist
- O namespace continua `sentinel-prod`
- A política default-deny seleciona o namespace inteiro; a allowlist seleciona `app: sentinel`
- O seletor de namespace usa `kubernetes.io/metadata.name`, nunca `matchNames`
- ingress e egress estão restritos ao mínimo necessário
- cada regra contém um comentário `#`

## Formato de Saída
Produza DOIS documentos YAML corrigidos e endurecidos, separados por `---`.

Requisitos obrigatórios do manifesto:
- `apiVersion: networking.k8s.io/v1`
- `kind: NetworkPolicy`
- `metadata:` com `namespace: sentinel-prod`
- primeira política com `spec.podSelector: {}` e sem regras de allow
- segunda política com `spec.podSelector.matchLabels.app: sentinel`
- `policyTypes:` com `Ingress` e `Egress`
- `ingress` com regras que liberam apenas Relay e API gateway
- `egress` com regras que liberam apenas Forge (5432), Cerebro (9200) e DNS (53)
- comentários iniciados por `# Permite` em todas as regras de allowlist
- não usar `- {}` como regra de ingress/egress (o `podSelector: {}` da política default-deny é obrigatório)
- sem blocos de código Markdown, sem texto extra, sem explicação fora do YAML

## Instruções Adicionais
- Use EXATAMENTE as labels e portas do mapa de serviços
- Não invente namespaces, labels, portas ou nomes de serviços
- Não use `- {}` como regra de ingress ou egress
- Separe default-deny e allowlist em dois documentos; não os combine numa política só
- `kubernetes.io/metadata.name` é o label padrão de namespace; não use `matchNames`
- O YAML deve ser válido e coerente
- Produza apenas o manifesto final

---

Agora, produza o manifesto NetworkPolicy corrigido e endurecido conforme acima.
