# 🔐 Guia de Chaves SSH

## 📦 Chaves Incluídas no Projeto

Este projeto já vem com um par de chaves SSH pré-configurado no diretório `.ssh/`:

```
infra/
├── .ssh/
│   ├── id_rsa           # Chave privada (gitignored)
│   ├── id_rsa.pub       # Chave pública (gitignored)
│   └── README.md        # Documentação
```

## ✅ Vantagens

1. **Pronto para usar** - Não precisa configurar chaves
2. **Isolado** - Não interfere com suas chaves pessoais
3. **Específico do projeto** - Cada projeto tem suas próprias chaves
4. **Seguro** - Protegido pelo `.gitignore`

## 🚀 Uso Automático

As chaves são usadas automaticamente:

```bash
cd infra

# Deploy usa .ssh/id_rsa automaticamente
make deploy

# SSH também usa as chaves do projeto
make ssh
```

## 🔧 Configuração

### Usando Chaves do Projeto (Padrão)

Nenhuma configuração adicional necessária! As variáveis já estão configuradas:

```hcl
# terraform/variables.tf
ssh_public_key_path  = "../.ssh/id_rsa.pub"   # Relativo ao dir terraform/
ssh_private_key_path = "../.ssh/id_rsa"
```

### Usando Suas Chaves Pessoais (Opcional)

Se preferir usar suas chaves de `~/.ssh/`:

**1. Edite `terraform/terraform.tfvars`:**

```hcl
ssh_public_key_path  = "~/.ssh/id_rsa.pub"
ssh_private_key_path = "~/.ssh/id_rsa"
```

**2. Ou use variáveis de ambiente:**

```bash
export TF_VAR_ssh_public_key_path=~/.ssh/id_rsa.pub
export TF_VAR_ssh_private_key_path=~/.ssh/id_rsa
```

## 🔄 Regenerar Chaves

Se precisar gerar novas chaves:

```bash
cd infra/.ssh

# Backup das antigas (opcional)
mv id_rsa id_rsa.old
mv id_rsa.pub id_rsa.pub.old

# Gerar novas
ssh-keygen -t rsa -b 4096 -f id_rsa -N "" -C "cs-skin-go-deploy"

# Corrigir permissões
chmod 600 id_rsa
chmod 644 id_rsa.pub
```

## 🔐 Segurança

### ✅ O que está protegido

```
✓ .ssh/ está no .gitignore
✓ Chave privada nunca será commitada
✓ Chave pública nunca será commitada
✓ Permissões corretas (600 para privada, 644 para pública)
```

### ⚠️ Boas Práticas

1. **Nunca compartilhe a chave privada** (`id_rsa`)
2. **Rotacione as chaves periodicamente** (a cada 6-12 meses)
3. **Use chaves diferentes por projeto**
4. **Adicione passphrase** para maior segurança (opcional)

```bash
# Adicionar passphrase a chave existente
ssh-keygen -p -f .ssh/id_rsa
```

## 📝 Detalhes das Chaves

### Chave Atual

- **Tipo**: RSA 4096 bits
- **Fingerprint**: SHA256:lvCsb6HuoLaUnyDsE2Ei/tirMUNqw0WoV47IhD3vdW0
- **Comentário**: cs-skin-go-deploy
- **Permissões**: 600 (privada), 644 (pública)

### Ver Fingerprint

```bash
ssh-keygen -lf .ssh/id_rsa.pub
```

### Ver Chave Pública

```bash
cat .ssh/id_rsa.pub
```

## 🔍 Verificação

### Verificar se as chaves existem

```bash
ls -la infra/.ssh/
```

Deve mostrar:
```
-rw-------  1 user  staff  3434 Nov 14 10:30 id_rsa
-rw-r--r--  1 user  staff   750 Nov 14 10:30 id_rsa.pub
```

### Verificar permissões

```bash
stat -f "%A %N" infra/.ssh/id_rsa*
```

Deve mostrar:
```
600 infra/.ssh/id_rsa
644 infra/.ssh/id_rsa.pub
```

### Testar chave

```bash
# Após deploy, testar conexão
ssh -i infra/.ssh/id_rsa ubuntu@<IP_SERVIDOR> "echo 'Conexão OK'"
```

## 🆘 Troubleshooting

### Erro: Permission denied (publickey)

**Problema**: Chave não está sendo usada ou permissões incorretas

**Solução**:
```bash
# Verificar permissões
chmod 600 infra/.ssh/id_rsa
chmod 644 infra/.ssh/id_rsa.pub

# Testar com verbose
ssh -vvv -i infra/.ssh/id_rsa ubuntu@<IP>
```

### Erro: Bad permissions

**Problema**: Chave privada com permissões muito abertas

**Solução**:
```bash
chmod 600 infra/.ssh/id_rsa
```

### Erro: No such file or directory

**Problema**: Chaves não foram geradas

**Solução**:
```bash
cd infra/.ssh
ssh-keygen -t rsa -b 4096 -f id_rsa -N "" -C "cs-skin-go-deploy"
```

### Erro: Key verification failed

**Problema**: Chave não corresponde ao servidor

**Solução**:
```bash
# Remover entrada antiga do known_hosts
ssh-keygen -R <IP_SERVIDOR>

# Tentar novamente
ssh -i infra/.ssh/id_rsa ubuntu@<IP>
```

## 🔗 Integração com Tools

### SSH Agent

```bash
# Adicionar chave ao agent
ssh-add infra/.ssh/id_rsa

# Listar chaves no agent
ssh-add -l

# Remover chave do agent
ssh-add -d infra/.ssh/id_rsa
```

### SCP/Rsync

```bash
# Copiar arquivo para servidor
scp -i infra/.ssh/id_rsa arquivo.txt ubuntu@<IP>:/tmp/

# Rsync
rsync -avz -e "ssh -i infra/.ssh/id_rsa" ./dir ubuntu@<IP>:/path/
```

### Git (SSH URLs)

As chaves do projeto não são usadas pelo Git. Git usa `~/.ssh/id_rsa` por padrão.

## 📚 Recursos

- [SSH Key Best Practices](https://www.ssh.com/academy/ssh/keygen)
- [AWS EC2 Key Pairs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
- [Terraform AWS Key Pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)

## 🎯 Resumo

1. ✅ **Chaves já incluídas** - Prontas para usar
2. ✅ **Configuração automática** - Terraform/Ansible já configurados
3. ✅ **Seguras** - Protegidas pelo `.gitignore`
4. ✅ **Isoladas** - Não interferem com chaves pessoais
5. ✅ **Documentadas** - Este guia completo

**Não precisa fazer nada, apenas execute `make deploy`!** 🚀

---

Dúvidas? Consulte o [README principal](README.md)

