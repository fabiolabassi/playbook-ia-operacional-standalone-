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

## Seu Raciocínio

Siga este processo para corrigir o manifesto:

### 1. Analisar o manifesto permissivo
- Identifique o que está errado (ex: podSelector: {} aplica a todos, - {} libera tudo)
- Entenda qual namespace está sendo protegido
- Liste os riscos deste manifesto permissivo

### 2. Aplicar o padrão default-deny
- Crie uma política default-deny explícita para o namespace
- Esta política deve ter podSelector: {} e policyTypes mas NENHUMA regra de allow
- Isso bloqueia todo tráfego por padrão

### 3. Adicionar regras de ingress permitidas
- Use o mapa de serviços para identificar quais serviços podem falar com os pods do Sentinel
- **INCLUA OBRIGATORIAMENTE**: Relays com label app:relay
- Use os labels corretos (ex: app=relay, não invente labels)
- Especifique as portas corretas se aplicável
- Cada regra deve ter um comentário explicando qual fluxo legítimo ela libera

### 4. Adicionar regras de egress permitidas
- Use o mapa de serviços para identificar para onde os pods do Sentinel podem falar
- **INCLUA OBRIGATORIAMENTE**: Forge na porta 5432 e Cerebro na porta 9200
- Use os labels corretos e as portas especificadas
- Inclua DNS (kube-dns) para resolução de nomes
- Cada regra deve ter um comentário explicando qual fluxo legítimo ela libera

### 5. Verificar a correção
- NÃO há regra allow-all (o manifesto não deve conter - {} em ingress ou egress)
- O podSelector está correto (app=sentinel para os pods do Sentinel)
- As regras de ingress correspondem ao esperado (Relay + API gateway)
- As regras de egress correspondem ao esperado (Forge + Cerebro + DNS)
- Toda regra tem comentário
- A política é default-deny (bloqueia tudo por padrão, libera só o necessário)

## Formato de Saída

Produza o manifesto YAML corrigido e endurecido. **IMPORTANTE**: Apenas o YAML puro, sem blocos de código markdown (```yaml ... ```). Comece diretamente com apiVersion.

**REQUISITOS OBRIGATÓRIOS DO MANIFESTO**:
- Deve conter "5432" (porta do Forge)
- Deve conter "9200" (porta do Cerebro)
- Deve conter "app:relay" (label do Relay)
- Não deve conter "- {}" (allow-all é proibido)
- Cada regra deve ter comentário "#"

Exemplo de estrutura (não copie literalmente, use como guia):

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sentinel-network-policy
  namespace: sentinel-prod
spec:
  podSelector:
    matchLabels:
      app: sentinel
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              app: relay
      # Tráfego do Relay (consumo de eventos)
    - from:
        - namespaceSelector:
            matchLabels:
              app: api-gateway
      # Tráfego do gateway de API
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              app: forge
      ports:
        - protocol: TCP
          port: 5432
      # Acesso ao Forge (warehouse, porta 5432)
    - to:
        - namespaceSelector:
            matchLabels:
              app: cerebro
      ports:
        - protocol: TCP
          port: 9200
      # Acesso ao Cerebro (busca, porta 9200)
    - to:
        - namespaceSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
      # DNS para resolução de nomes

## Instruções Adicionais
- Use EXATAMENTE as labels fornecidas no mapa de serviços - não invente labels
- Use EXATAMENTE as ports fornecidas no mapa de serviços
- NÃO use - {} em nenhuma regra (isso é allow-all e é proibido)
- Cada regra DEVE ter um comentário começando com #
- O manifesto deve ser um único YAML válido (não múltiplos documentos separados por ---)
- O namespace deve ser o mesmo do manifesto permissivo original
- Se precisar de múltiplas políticas (ex: uma default-deny e uma com regras), combine em uma única política

---

Agora, produza o manifesto NetworkPolicy corrigido e endurecido conforme acima.
