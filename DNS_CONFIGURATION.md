# 🌐 Configuração de DNS

Guia para configurar os domínios da aplicação CS Skin GO.

## 🎯 Domínios Configurados

- **Frontend**: `ia.daniloaparecido.com.br`
- **Backend/API**: `api-ia.daniloaparecido.com.br`

## 📋 Configuração DNS Necessária

Após fazer o deploy, você precisará configurar os seguintes registros DNS:

### 1. Obter IP Público

```bash
cd infra
make deploy

# Ou se já deployou
cd terraform
terraform output instance_public_ip
```

**Exemplo de saída:**
```
instance_public_ip = "54.123.45.67"
```

### 2. Configurar Registros DNS

No painel do seu provedor de DNS (ex: Registro.br, Cloudflare, Route53), crie:

#### Registro A - Frontend

```
Tipo: A
Nome/Host: ia
Domínio: daniloaparecido.com.br
Valor/Destino: <IP_PUBLICO_DA_EC2>
TTL: 3600 (1 hora)
```

**FQDN resultante:** `ia.daniloaparecido.com.br`

#### Registro A - Backend

```
Tipo: A
Nome/Host: api-ia
Domínio: daniloaparecido.com.br
Valor/Destino: <IP_PUBLICO_DA_EC2>
TTL: 3600 (1 hora)
```

**FQDN resultante:** `api-ia.daniloaparecido.com.br`

#### WWW (Opcional)

```
Tipo: CNAME
Nome/Host: www.ia
Destino: ia.daniloaparecido.com.br
TTL: 3600

Tipo: CNAME
Nome/Host: www.api-ia
Destino: api-ia.daniloaparecido.com.br
TTL: 3600
```

## 🔧 Exemplo de Configuração

### Registro.br (exemplo)

```
# Frontend
ia          IN  A     54.123.45.67

# Backend
api-ia      IN  A     54.123.45.67

# WWW (opcional)
www.ia      IN  CNAME ia.daniloaparecido.com.br.
www.api-ia  IN  CNAME api-ia.daniloaparecido.com.br.
```

### Cloudflare (exemplo)

| Tipo | Nome | Conteúdo | Proxy | TTL |
|------|------|----------|-------|-----|
| A | ia | 54.123.45.67 | ❌ Desligado | Auto |
| A | api-ia | 54.123.45.67 | ❌ Desligado | Auto |

> **⚠️ IMPORTANTE:** Desabilite o proxy do Cloudflare inicialmente para testar.

### AWS Route 53 (exemplo)

```bash
# Criar hosted zone (se não existir)
aws route53 create-hosted-zone --name daniloaparecido.com.br

# Criar registro A para frontend
aws route53 change-resource-record-sets --hosted-zone-id <ZONE_ID> --change-batch '{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "ia.daniloaparecido.com.br",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{"Value": "<IP_PUBLICO>"}]
    }
  }]
}'

# Criar registro A para backend
aws route53 change-resource-record-sets --hosted-zone-id <ZONE_ID> --change-batch '{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "api-ia.daniloaparecido.com.br",
      "Type": "A",
      "TTL": 300,
      "ResourceRecords": [{"Value": "<IP_PUBLICO>"}]
    }
  }]
}'
```

## ⏱️ Propagação DNS

- **Mínimo**: 5-30 minutos
- **Médio**: 1-4 horas
- **Máximo**: 24-48 horas

### Verificar Propagação

```bash
# Verificar frontend
dig ia.daniloaparecido.com.br
nslookup ia.daniloaparecido.com.br

# Verificar backend
dig api-ia.daniloaparecido.com.br
nslookup api-ia.daniloaparecido.com.br

# Verificar globalmente
# https://www.whatsmydns.net/#A/ia.daniloaparecido.com.br
# https://www.whatsmydns.net/#A/api-ia.daniloaparecido.com.br
```

## 🧪 Testar Configuração

### Antes da Propagação (via IP)

```bash
# Frontend
curl -I http://<IP_PUBLICO>

# Backend
curl -I http://<IP_PUBLICO>/api/cases
```

### Após Propagação (via Domínio)

```bash
# Frontend
curl -I http://ia.daniloaparecido.com.br

# Backend
curl -I http://api-ia.daniloaparecido.com.br/cases

# Ou no navegador
open http://ia.daniloaparecido.com.br
open http://api-ia.daniloaparecido.com.br/cases
```

## 🔒 Configurar HTTPS (SSL)

### Opção 1: Certbot (Let's Encrypt) - Grátis

```bash
# SSH no servidor
make ssh

# Instalar Certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Obter certificados
sudo certbot --nginx \
  -d ia.daniloaparecido.com.br \
  -d www.ia.daniloaparecido.com.br \
  -d api-ia.daniloaparecido.com.br \
  -d www.api-ia.daniloaparecido.com.br \
  --non-interactive \
  --agree-tos \
  --email seu@email.com \
  --redirect

# Renovação automática (cron já é configurado automaticamente)
sudo certbot renew --dry-run
```

### Opção 2: Cloudflare SSL

1. Habilite o proxy no Cloudflare (nuvem laranja)
2. Em SSL/TLS → Overview → Escolha "Full (strict)"
3. O SSL será configurado automaticamente

### Opção 3: AWS Certificate Manager (ACM)

```bash
# Requisitar certificado
aws acm request-certificate \
  --domain-name ia.daniloaparecido.com.br \
  --subject-alternative-names api-ia.daniloaparecido.com.br \
  --validation-method DNS

# Adicionar registros de validação no DNS
# Depois adicionar ALB/CloudFront (requer arquitetura mais complexa)
```

## 🎯 Verificação Final

### Checklist

- [ ] Deploy realizado com sucesso
- [ ] IP público anotado
- [ ] Registros DNS criados (A records)
- [ ] Aguardado propagação DNS
- [ ] Teste via `dig` ou `nslookup` bem-sucedido
- [ ] Frontend acessível via `http://ia.daniloaparecido.com.br`
- [ ] Backend acessível via `http://api-ia.daniloaparecido.com.br`
- [ ] CORS configurado corretamente
- [ ] SSL configurado (opcional mas recomendado)

### Comando de Verificação Completa

```bash
cd infra

# Ver configuração DNS necessária
make info

# Ou via Terraform
cd terraform
terraform output dns_configuration
```

## 🔧 Troubleshooting

### DNS não resolve

```bash
# Limpar cache DNS local
sudo dscacheutil -flushcache  # macOS
sudo systemd-resolve --flush-caches  # Linux
ipconfig /flushdns  # Windows

# Testar com DNS específico
dig @8.8.8.8 ia.daniloaparecido.com.br
dig @1.1.1.1 api-ia.daniloaparecido.com.br
```

### CORS Error

1. Verifique que o backend está configurado para aceitar o domínio do frontend
2. O Nginx já está configurado com headers CORS
3. Se necessário, ajuste em `ansible/roles/nginx/templates/nginx.conf.j2`

### SSL não funciona

```bash
# Verificar certificados
sudo certbot certificates

# Renovar manualmente
sudo certbot renew

# Ver logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log
```

### WWW não redireciona

O Nginx já está configurado para redirecionar www para não-www automaticamente.

## 📚 Recursos

- [DNS Propagation Checker](https://www.whatsmydns.net/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Certbot](https://certbot.eff.org/)
- [Cloudflare DNS](https://www.cloudflare.com/dns/)
- [AWS Route 53](https://aws.amazon.com/route53/)

## 🎉 URLs Finais

Após tudo configurado:

- **Frontend**: https://ia.daniloaparecido.com.br
- **Backend**: https://api-ia.daniloaparecido.com.br
- **API Docs**: https://api-ia.daniloaparecido.com.br/docs (se Swagger habilitado)

---

**Dúvidas?** Consulte o [README principal](README.md)

