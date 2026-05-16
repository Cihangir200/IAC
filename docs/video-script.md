# Video script, maximaal 5 minuten

## 0:00 - 0:30 Intro

Laat de opdracht en repo zien. Noem dat de oplossing Terraform, CloudInit, Ansible Galaxy, Docker Compose, GitHub Actions, Azure en ESXi gebruikt.

## 0:30 - 1:15 Terraform structuur

Laat `main.tf`, `modules/azure_network`, `modules/azure_vpn`, `modules/azure_linux_vm` en `modules/vsphere_vm` zien.

Wijs aan:

- Azure VM
- vSphere/ESXi VM
- VPN Gateway en Local Network Gateway
- `tls_private_key` voor SSH

## 1:15 - 1:45 CloudInit en SSH

Laat de twee `cloud-init.yml.tftpl` bestanden zien. Toon dat de public key in `ssh_authorized_keys` komt.

Laat daarna zien:

```powershell
terraform output -raw ssh_public_key
terraform output -raw ssh_private_key_pem
```

## 1:45 - 2:30 CI en tests

Open `.github/workflows/ci.yml`. Laat zien dat er getest wordt voor deployment:

- `terraform fmt`
- `terraform validate`
- Ansible Galaxy install
- Ansible syntax check

## 2:30 - 3:30 Deployment en Ansible

Laat de commando's zien:

```powershell
terraform plan -out tfplan
terraform apply tfplan
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

Laat `ansible/requirements.yml` zien voor de Galaxy role en `app/docker-compose.yml` voor Docker Hub images.

## 3:30 - 4:30 Werkende applicatie

Open de webapp op de Azure VM en ESXi VM. Laat op de VM zien:

```powershell
docker ps
docker compose ps
```

Test de hybride connectie:

```powershell
ssh -i .\iac-lab.pem iacadmin@<azure-vm-public-ip> "curl -I http://<esxi-vm-private-ip>"
```

## 4:30 - 5:00 Best practices

Laat zien:

- `.gitignore` zonder secrets
- `terraform.tfvars.example`
- modules in plaats van alles in een bestand
- sensitive variables voor wachtwoorden en VPN key
- documentatie in `README.md` en `docs/architecture.md`

