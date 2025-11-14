# ✅ Checklist de Deploy CS Skin GO

Use este checklist para garantir que tudo está configurado corretamente antes do deploy.

## 📋 Pré-Deploy

### 1. Ambiente Local

- [ ] Terraform instalado (`terraform version`)
- [ ] Ansible instalado (`ansible --version`)
- [ ] AWS CLI instalado e configurado (`aws configure`)
- [ ] Par de chaves SSH criado (`~/.ssh/id_rsa` e `~/.ssh/id_rsa.pub`)
- [ ] Git configurado (se usar repositórios remotos)

### 2. AWS

- [ ] Conta AWS criada e ativa
- [ ] Access Key ID e Secret Access Key obtidos
- [ ] AWS CLI configurado com credenciais
- [ ] Região definida (padrão: us-east-1)
- [ ] Free Tier verificado (se aplicável)

### 3. Configurações

- [ ] `terraform/terraform.tfvars` criado (copiar de `.example`)
- [ ] JWT_SECRET alterado (mínimo 32 caracteres)
- [ ] MySQL passwords alterados
- [ ] SSH CIDR restrito ao seu IP (`curl ifconfig.me`)
- [ ] Domínio configurado (opcional)

### 4. Código da Aplicação

- [ ] Backend compilando sem erros (`cd back-end-api && npm run build`)
- [ ] Frontend compilando sem erros (`cd front-end && pnpm build`)
- [ ] Variáveis de ambiente revisadas
- [ ] Dockerfile do backend testado
- [ ] Dockerfile do frontend testado

## 🚀 Durante o Deploy

### 5. Terraform

- [ ] `terraform init` executado com sucesso
- [ ] `terraform validate` passou
- [ ] `terraform plan` revisado
- [ ] `terraform apply` executado
- [ ] Outputs anotados (IP público, URLs)
- [ ] EC2 instance criada e rodando
- [ ] Elastic IP associado

### 6. Ansible

- [ ] Inventário gerado automaticamente
- [ ] Conectividade testada (`ansible all -m ping`)
- [ ] Playbook executado sem erros
- [ ] Todas as tasks completadas com sucesso
- [ ] Containers rodando (`docker ps`)

### 7. Aplicação

- [ ] MySQL container saudável
- [ ] Backend container saudável
- [ ] Frontend container saudável
- [ ] Migrações executadas
- [ ] Seeds executados (se necessário)
- [ ] Nginx rodando e configurado

## 🧪 Pós-Deploy (Testes)

### 8. Conectividade

- [ ] SSH funcionando (`ssh ubuntu@<IP>`)
- [ ] Frontend acessível (`http://<IP>/`)
- [ ] Backend API acessível (`http://<IP>/api`)
- [ ] Health checks respondendo

### 9. Funcionalidades

- [ ] Página inicial carrega
- [ ] Login funciona
- [ ] Registro funciona
- [ ] API retorna dados
- [ ] Banco de dados conectado
- [ ] Assets estáticos carregam

### 10. Performance

- [ ] Tempo de resposta aceitável (< 2s)
- [ ] Nginx proxy funcionando
- [ ] Cache de assets funcionando
- [ ] Rate limiting ativo

### 11. Logs

- [ ] Logs do Nginx acessíveis
- [ ] Logs do Docker acessíveis
- [ ] Nenhum erro crítico nos logs
- [ ] Health checks passando

## 🔒 Segurança

### 12. Configurações de Segurança

- [ ] SSH restrito a IPs específicos
- [ ] Senhas fortes configuradas
- [ ] JWT secret único e forte
- [ ] Security headers no Nginx
- [ ] CORS configurado corretamente
- [ ] Rate limiting testado

### 13. AWS Security

- [ ] Security Group revisado
- [ ] IAM roles configurados (se necessário)
- [ ] EBS volume encriptado
- [ ] CloudTrail habilitado (recomendado)

## 📊 Monitoramento

### 14. Setup de Monitoramento

- [ ] Logs sendo gerados
- [ ] CloudWatch configurado (opcional)
- [ ] Alertas configurados (opcional)
- [ ] Backup strategy definida
- [ ] Disaster recovery plan documentado

## 💰 Custos

### 15. Gestão de Custos

- [ ] Budget alert configurado na AWS
- [ ] Free tier verificado
- [ ] Custo mensal estimado revisado (~$10/mês)
- [ ] Billing dashboard verificado

## 📝 Documentação

### 16. Documentação Atualizada

- [ ] README.md revisado
- [ ] URLs anotadas
- [ ] Credenciais salvas em local seguro
- [ ] Runbook de troubleshooting preparado
- [ ] Contatos de emergência definidos

## 🔄 Manutenção

### 17. Procedimentos de Manutenção

- [ ] Processo de update documentado
- [ ] Backup manual testado
- [ ] Restore testado
- [ ] Rollback procedure documentado
- [ ] Disaster recovery testado

## ✨ Opcional (Melhorias Futuras)

### 18. Enhancements

- [ ] Domínio próprio configurado
- [ ] HTTPS/SSL configurado (Let's Encrypt)
- [ ] CI/CD pipeline configurado
- [ ] Monitoramento avançado (Grafana/Prometheus)
- [ ] Auto-scaling configurado
- [ ] CDN configurado (CloudFront)
- [ ] Database backups automáticos
- [ ] Multi-AZ deployment
- [ ] Load Balancer

## 🎯 Sign-off

### Deploy realizado por:
- **Nome:** ______________________________
- **Data:** ______________________________
- **Hora:** ______________________________

### URLs do Ambiente:
- **Frontend:** ______________________________
- **Backend:** ______________________________
- **IP Público:** ______________________________

### Observações:
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## 📞 Suporte

Em caso de problemas:
1. ✅ Consultar [README.md](README.md)
2. ✅ Verificar [Troubleshooting](README.md#troubleshooting)
3. ✅ Revisar logs
4. ✅ Executar testes básicos

## 🎉 Parabéns!

Se todos os itens estão marcados, seu deploy foi um sucesso! 🚀

