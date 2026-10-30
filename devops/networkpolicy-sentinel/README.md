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

# Endurecimento de NetworkPolicy

## Objetivo
Prompt para correção e endurecimento de manifestos de NetworkPolicy permissivos no Kubernetes. Transforma políticas allow-all em políticas default-deny com regras explícitas de ingress e egress, seguindo o padrão de segurança da Aegis e usando labels e ports corretos do mapa de serviços.

## Quando Usar
- Ao revisar NetworkPolicies permissivas que foram barradas por segurança
- Para criar políticas de rede seguindo o princípio de least privilege
- Para documentar e padronizar políticas de rede entre namespaces
- Como parte de um processo de hardening de segurança do cluster

## Exemplo de Uso

### Entrada (resumida)
**Manifesto permissivo**: podSelector: {}, ingress: - {}, egress: - {}
**Regras**: pods só aceitam Relay + API gateway, só fazem saída para Forge (5432) + Cerebro (9200) + DNS
**Mapa**: Sentinel (app=sentinel), Relay (app=relay), API gateway (app=api-gateway), Forge (app=forge, 5432), Cerebro (app=cerebro, 9200), DNS (k8s-app=kube-dns, 53)

### Saída Esperada (resumida; dois documentos YAML)
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sentinel-default-deny
  namespace: sentinel-prod
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: sentinel-allow-required-flows
  namespace: sentinel-prod
spec:
  podSelector:
    matchLabels:
      app: sentinel
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Permite eventos do Relay para os pods do Sentinel
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: relay-prod
          podSelector:
            matchLabels:
              app: relay
    # Permite chamadas do gateway de API da plataforma
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: edge
          podSelector:
            matchLabels:
              app: api-gateway
  egress:
    # Permite acesso ao warehouse do Forge
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: forge-prod
          podSelector:
            matchLabels:
              app: forge
      ports:
        - protocol: TCP
          port: 5432
    # Permite consultas de busca ao Cerebro
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: cerebro-prod
          podSelector:
            matchLabels:
              app: cerebro
      ports:
        - protocol: TCP
          port: 9200
    # Permite resolução DNS interna (UDP e TCP)
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

## Limitações
- Assume familiaridade com Kubernetes NetworkPolicy e conceitos de default-deny
- Requer que o mapa de serviços seja completo e correto (labels e ports)
- Gera duas políticas complementares porque NetworkPolicy é aditiva: uma política default-deny e uma allowlist
- Específico para o padrão de segurança da Aegis - pode não se aplicar a outras organizações
- Não aplica nem valida o manifesto no cluster; valide a compatibilidade das labels e o comportamento em staging antes de produção

## Técnica Utilizada
- Role Prompting: define o modelo como "engenheiro de segurança sênior"
- Precisão Técnica: exige uso exato de labels e ports fornecidos no mapa
- Constraint Specification: proíbe allow-all (- {}), exige comentários em todas as regras
- Default-Deny Pattern: ensina o padrão de bloquear tudo por padrão e liberar só o necessário

## Processo de Verificação
O artefato passou por três revisões:
- **v1**: A especificação pedia uma única política e permitia confundir `podSelector: {}` (seletor) com uma regra allow-all.
- **v2**: A revisão identificou que NetworkPolicies são aditivas; default-deny e allowlist passaram a ser documentos separados. O exemplo também foi corrigido para não usar `matchNames`.
- **v3**: A política foi refinada para usar `kubernetes.io/metadata.name` nos seletores de namespace, incluir DNS em TCP e UDP e exigir comentário por regra. O teste verifica os dois documentos e os fluxos definidos.

Esse histórico registra revisão do prompt e dos exemplos, não uma execução autenticada de modelo; valide a saída real com `promptfoo` e em staging antes de produção.
