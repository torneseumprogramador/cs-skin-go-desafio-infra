#!/bin/bash

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
print_header() {
    echo -e "\n${RED}========================================${NC}"
    echo -e "${RED}$1${NC}"
    echo -e "${RED}========================================${NC}\n"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Main
main() {
    clear
    print_header "⚠️  DESTRUIR INFRAESTRUTURA ⚠️"
    
    echo -e "${RED}ATENÇÃO: Esta ação vai:${NC}"
    echo "  • Deletar a instância EC2"
    echo "  • Remover o Elastic IP"
    echo "  • Deletar todos os volumes"
    echo "  • Remover todos os dados"
    echo ""
    echo -e "${RED}Esta ação é IRREVERSÍVEL!${NC}"
    echo ""
    
    read -p "Digite 'DESTROY' em maiúsculas para confirmar: " confirm
    
    if [ "$confirm" != "DESTROY" ]; then
        print_warning "Operação cancelada."
        exit 0
    fi
    
    echo ""
    read -p "Tem certeza ABSOLUTA? (yes/no): " confirm2
    
    if [ "$confirm2" != "yes" ]; then
        print_warning "Operação cancelada."
        exit 0
    fi
    
    # Verificar se está no diretório correto
    if [ ! -d "terraform" ]; then
        print_error "Execute este script do diretório infra/"
        exit 1
    fi
    
    cd terraform
    
    print_warning "Destruindo infraestrutura..."
    terraform destroy
    
    print_success "Infraestrutura destruída!"
    
    cd ..
}

# Executar
main "$@"

