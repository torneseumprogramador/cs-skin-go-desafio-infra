# 🌐 Guia Rápido - Setup de Domínios

## 📋 Resumo

Sua aplicação CS Skin GO está configurada para usar domínios customizados:

- **Frontend**: `ia.daniloaparecido.com.br`
- **Backend/API**: `api-ia.daniloaparecido.com.br`

## 🚀 Passo a Passo Completo

### 1. Deploy da Infraestrutura

```bash
cd infra

# Verificar configuração
cat terraform/terraform.tfvars.example

# Setup e deploy
make setup
make deploy
```

**Anote o IP público** que aparecerá no output!

### 2. Configurar DNS

No painel do seu provedor de DNS (Registro.br, Cloudflare, etc):

#### Registro A - Frontend
```
Nome: ia
Tipo: A
Valor: <IP_PUBLICO_DA_EC2>
TTL: 3600
```

#### Registro A - Backend
```
Nome: api-ia
Tipo: A
Valor: <IP_PUBLICO_DA_EC2>
TTL: 3600
```

### 3. Aguardar Propagação DNS (30min - 2h)

```bash
# Verificar propagação
dig ia.daniloaparecido.com.br
dig api-ia.daniloaparecido.com.br

# Ou use: https://www.whatsmydns.net/
```

### 4. Testar Aplicação

```bash
# Frontend
curl -I http://ia.daniloaparecido.com.br

# Backend
curl http://api-ia.daniloaparecido.com.br/cases

# Navegador
open http://ia.daniloaparecido.com.br
```

### 5. Configurar HTTPS (Opcional mas Recomendado)

```bash
# SSH no servidor
make ssh

# Executar script de SSL
curl -sSL https://raw.githubusercontent.com/torneseumprogramador/cs-skin-go-desafio-infra/main/scripts/setup-ssl.sh | sudo bash

# OU manualmente
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx \
  -d ia.daniloaparecido.com.br \
  -d api-ia.daniloaparecido.com.br \
  --email admin@daniloaparecido.com.br
```

### 6. Atualizar Frontend (se necessário)

Se o frontend já estava compilado com URLs antigas:

```bash
# Rebuild e restart
make rebuild
```

## ✅ Verificação Final

```bash
# Testar frontend
curl -I https://ia.daniloaparecido.com.br
# Deve retornar: 200 OK

# Testar backend
curl https://api-ia.daniloaparecido.com.br/cases
# Deve retornar: JSON com cases

# Testar CORS
curl -H "Origin: https://ia.daniloaparecido.com.br" \
     -I https://api-ia.daniloaparecido.com.br/cases
# Deve ter header: Access-Control-Allow-Origin
```

## 🔧 Arquitetura Nginx

```
┌─────────────────────────────────────────────────────┐
│           Nginx (porta 80/443)                      │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ia.daniloaparecido.com.br                         │
│         ↓                                           │
│    Frontend (localhost:3000)                        │
│                                                     │
│  api-ia.daniloaparecido.com.br                     │
│         ↓                                           │
│    Backend (localhost:3001)                         │
│                                                     │
│  <IP_PUBLICO> (fallback)                           │
│         ↓                                           │
│    Redirect → ia.daniloaparecido.com.br            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## 📝 Configuração Atual

### Terraform Variables

```hcl
frontend_domain = "ia.daniloaparecido.com.br"
backend_domain  = "api-ia.daniloaparecido.com.br"
```

### Nginx Servers

**Frontend Server:**
- Domain: `ia.daniloaparecido.com.br`
- Proxy: `localhost:3000` (Next.js)
- Features: Static cache, Next.js optimization

**Backend Server:**
- Domain: `api-ia.daniloaparecido.com.br`
- Proxy: `localhost:3001/api` (NestJS)
- Features: CORS, Rate limiting, Health checks

**Fallback Server:**
- Default: Qualquer outro acesso
- Action: Redirect para frontend domain

### CORS Configurado

- Backend aceita requests de: `http://ia.daniloaparecido.com.br`
- Frontend faz requests para: `http://api-ia.daniloaparecido.com.br`

## 🔐 Segurança HTTPS

Após configurar SSL, suas URLs serão:

- **Frontend**: `https://ia.daniloaparecido.com.br`
- **Backend**: `https://api-ia.daniloaparecido.com.br`

O Nginx redirecionará automaticamente HTTP → HTTPS.

## 🆘 Troubleshooting

### DNS não resolve

```bash
# Limpar cache DNS
sudo dscacheutil -flushcache  # macOS

# Testar com DNS público
dig @8.8.8.8 ia.daniloaparecido.com.br

# Verificar propagação
https://www.whatsmydns.net/#A/ia.daniloaparecido.com.br
```

### CORS Error

```bash
# Verificar se backend está configurado corretamente
curl -H "Origin: http://ia.daniloaparecido.com.br" \
     -I http://api-ia.daniloaparecido.com.br/cases

# Deve ter header:
# Access-Control-Allow-Origin: http://ia.daniloaparecido.com.br
```

### Frontend não conecta no Backend

1. Verificar variável de ambiente:
   ```bash
   make ssh
   docker compose exec frontend env | grep API_URL
   # Deve mostrar: NEXT_PUBLIC_API_URL=http://api-ia.daniloaparecido.com.br
   ```

2. Se estiver errado, rebuild:
   ```bash
   make rebuild
   ```

### SSL não funciona

```bash
# Verificar certificados
sudo certbot certificates

# Testar renovação
sudo certbot renew --dry-run

# Ver logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log
```

## 📊 Comandos Úteis

```bash
# Ver configuração DNS necessária
make info

# Ver IP público
cd terraform && terraform output instance_public_ip

# Ver URLs configuradas
cd terraform && terraform output frontend_url
cd terraform && terraform output backend_url

# Testar conectividade
make test-connection

# Ver logs
make logs-nginx
```

## 📚 Documentação Completa

- [DNS Configuration](DNS_CONFIGURATION.md) - Guia detalhado de DNS
- [README](README.md) - Documentação principal
- [QUICK_START](QUICK_START.md) - Início rápido

## 🎯 Checklist de Deploy com Domínios

- [ ] Deploy realizado (`make deploy`)
- [ ] IP público anotado
- [ ] Registros DNS criados (A records)
- [ ] Aguardado propagação (30min - 2h)
- [ ] DNS testado (`dig`, `nslookup`)
- [ ] Frontend acessível via domínio
- [ ] Backend acessível via domínio
- [ ] CORS funcionando
- [ ] SSL configurado (opcional)
- [ ] Redirect HTTP → HTTPS (se SSL)
- [ ] Aplicação totalmente funcional

## 🎉 Resultado Final

Após completar todos os passos, você terá:

✅ Frontend acessível em: `https://ia.daniloaparecido.com.br`  
✅ Backend acessível em: `https://api-ia.daniloaparecido.com.br`  
✅ SSL/HTTPS configurado e renovação automática  
✅ CORS configurado corretamente  
✅ Domínios customizados profissionais  
✅ Infraestrutura pronta para produção  

---

**Dúvidas?** Consulte [DNS_CONFIGURATION.md](DNS_CONFIGURATION.md) para mais detalhes.

