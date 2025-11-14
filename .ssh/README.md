# 🔐 Chaves SSH para Deploy

Este diretório contém as chaves SSH usadas para acessar os servidores.

## ⚠️ IMPORTANTE

**NUNCA commite as chaves privadas no Git!**

As chaves estão protegidas pelo `.gitignore` e não serão versionadas.

## 🔑 Chaves Geradas

- `id_rsa` - Chave privada (NÃO compartilhe!)
- `id_rsa.pub` - Chave pública (pode compartilhar)

## 🔄 Regenerar Chaves

Se precisar gerar novas chaves:

```bash
cd infra/.ssh
rm -f id_rsa id_rsa.pub
ssh-keygen -t rsa -b 4096 -f id_rsa -N "" -C "cs-skin-go-deploy"
```

## 🚀 Uso

As chaves são usadas automaticamente pelo Terraform e Ansible:

```bash
cd infra
make deploy  # Usa as chaves deste diretório
```

## 📝 Configuração Manual

Se preferir usar suas chaves pessoais do `~/.ssh/`, edite `terraform/terraform.tfvars`:

```hcl
ssh_public_key_path  = "~/.ssh/id_rsa.pub"
ssh_private_key_path = "~/.ssh/id_rsa"
```

## 🔒 Permissões

As chaves privadas devem ter permissões restritas:

```bash
chmod 600 id_rsa
chmod 644 id_rsa.pub
```

## 🆘 Troubleshooting

### Permissão negada ao conectar via SSH

```bash
# Verificar permissões
ls -la

# Corrigir permissões
chmod 600 id_rsa
chmod 644 id_rsa.pub
```

### Chave não encontrada

```bash
# Verificar se as chaves existem
ls -la

# Se não existirem, gerar
ssh-keygen -t rsa -b 4096 -f id_rsa -N "" -C "cs-skin-go-deploy"
```

## 📌 Notas

- **Fingerprint**: SHA256:lvCsb6HuoLaUnyDsE2Ei/tirMUNqw0WoV47IhD3vdW0
- **Tipo**: RSA 4096 bits
- **Comentário**: cs-skin-go-deploy
- **Uso**: Deploy automatizado AWS

## 🔐 Segurança

1. **Mantenha a chave privada segura**
2. **Não compartilhe em canais inseguros**
3. **Use SSH Agent para gerenciar chaves**
4. **Rotacione as chaves periodicamente**
5. **Use senhas fortes se adicionar passphrase**

---

**Estas chaves são específicas para este projeto e não devem ser usadas em outros lugares.**

