#!/bin/bash

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FRONTEND_DOMAIN="ia.daniloaparecido.com.br"
BACKEND_DOMAIN="api-ia.daniloaparecido.com.br"
EMAIL="admin@daniloaparecido.com.br"

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_header "🔒 Setup SSL/HTTPS com Let's Encrypt"

# Verificar se está rodando no servidor
if [ ! -f /etc/nginx/nginx.conf ]; then
    print_error "Este script deve ser executado NO SERVIDOR AWS!"
    echo ""
    echo "Execute:"
    echo "  cd infra"
    echo "  make ssh"
    echo "  # No servidor:"
    echo "  curl -sSL https://raw.githubusercontent.com/torneseumprogramador/cs-skin-go-desafio-infra/main/scripts/setup-ssl.sh | sudo bash"
    exit 1
fi

# Verificar se os domínios resolvem
print_warning "Verificando DNS..."

if ! host $FRONTEND_DOMAIN > /dev/null 2>&1; then
    print_error "Domínio $FRONTEND_DOMAIN não resolve!"
    print_warning "Configure o DNS antes de continuar."
    exit 1
fi

if ! host $BACKEND_DOMAIN > /dev/null 2>&1; then
    print_error "Domínio $BACKEND_DOMAIN não resolve!"
    print_warning "Configure o DNS antes de continuar."
    exit 1
fi

print_success "DNS configurado corretamente!"

# Instalar Certbot
print_warning "Instalando Certbot..."
apt update
apt install -y certbot python3-certbot-nginx

print_success "Certbot instalado!"

# Obter certificados
print_warning "Obtendo certificados SSL..."
print_warning "Isso pode levar alguns minutos..."

certbot --nginx \
  -d $FRONTEND_DOMAIN \
  -d www.$FRONTEND_DOMAIN \
  -d $BACKEND_DOMAIN \
  -d www.$BACKEND_DOMAIN \
  --non-interactive \
  --agree-tos \
  --email $EMAIL \
  --redirect \
  --hsts \
  --staple-ocsp

if [ $? -eq 0 ]; then
    print_success "Certificados SSL instalados com sucesso!"
else
    print_error "Erro ao instalar certificados SSL"
    exit 1
fi

# Configurar renovação automática
print_warning "Configurando renovação automática..."

# Testar renovação
certbot renew --dry-run

if [ $? -eq 0 ]; then
    print_success "Renovação automática configurada!"
else
    print_warning "Renovação automática pode ter problemas. Verifique manualmente."
fi

# Restart Nginx
print_warning "Reiniciando Nginx..."
systemctl restart nginx

print_success "Nginx reiniciado!"

# Verificar status
print_warning "Verificando certificados..."
certbot certificates

print_header "✅ SSL/HTTPS Configurado com Sucesso!"

echo -e "${GREEN}Suas URLs agora são:${NC}"
echo -e "  ${BLUE}Frontend:${NC}  https://$FRONTEND_DOMAIN"
echo -e "  ${BLUE}Backend:${NC}   https://$BACKEND_DOMAIN"
echo ""
echo -e "${YELLOW}Renovação automática:${NC} Configurada (via cron)"
echo -e "${YELLOW}Próxima renovação:${NC}   $(certbot certificates | grep 'Expiry Date' | head -1 | cut -d: -f2-)"
echo ""
echo -e "${BLUE}========================================${NC}\n"

# Mostrar informações
print_warning "Informações importantes:"
echo "1. Os certificados são renovados automaticamente"
echo "2. Você receberá emails de aviso antes da expiração"
echo "3. Para forçar renovação: sudo certbot renew"
echo "4. Para ver status: sudo certbot certificates"
echo ""

print_success "Setup completo!"

