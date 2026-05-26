# Hybrid Cloud IaC Lab

Deze repository bevat een hybride IaC labopstelling waarbij Azure gecombineerd wordt met een lokale ESXi omgeving. Terraform maakt de infrastructuur aan, Cloud-init doet de basisconfiguratie en Ansible installeert WireGuard, Docker en de webapp.

## Architectuur

- Azure resource group, VNet, subnet, NSG, public IP, NIC en Ubuntu VM
- Standalone ESXi VM via de `josenk/esxi` Terraform provider
- Cloud-init voor SSH setup en basispackages
- WireGuard tunnel tussen Azure en ESXi (`10.50.0.1` naar `10.50.0.2`)
- Docker Compose webapp met een image vanaf `docker.io`
- GitHub Actions workflow voor validate/lint en deployment

## Structuur

```text
.
|-- .github/
|   `-- workflows/ci.yml
|-- ansible/
|   |-- deploy.yml
|   |-- inventory.ini
|   |-- inventory.ini.example
|   |-- group_vars/
|   `-- roles/
|       |-- app/
|       |-- docker/
|       `-- hybrid_vpn/
|-- app/
|   `-- docker-compose.yml
|-- docs/
|-- scripts/
|   |-- film-deploy.ps1
|   `-- destroy-all.ps1
`-- terraform/
    |-- main.tf
    |-- providers.tf
    |-- variables.tf
    |-- outputs.tf
    |-- terraform.tfvars.example
    `-- modules/
        |-- azure_linux_vm/
        |-- azure_network/
        `-- vsphere_vm/
```

## Secrets

Zet geen secrets in Git. Gebruik lokaal `terraform/terraform.tfvars` en in GitHub Actions repository secrets.

Benodigde GitHub Secrets:

```text
AZURE_CREDENTIALS
AZURE_SUBSCRIPTION_ID
AZURE_VM_USER
ESXI_HOST
ESXI_USER
ESXI_PASSWORD
ESXI_GUEST_USER
ESXI_GUEST_PASSWORD
```

## Lokale Deployment

Voor de demonstratie kan de volledige deployment met een script worden uitgevoerd:

```powershell
cd C:\Users\Student\Desktop\IAC
.\scripts\film-deploy.ps1
```

Resources verwijderen:

```powershell
cd C:\Users\Student\Desktop\IAC
.\scripts\destroy-all.ps1 -StartAzureVmFirst
```

Handmatige Terraform-stappen:

```powershell
cd C:\Users\Student\Desktop\IAC\terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out tfplan
terraform apply tfplan
terraform output
```

Ansible vanuit WSL:

```bash
cd /mnt/c/Users/Student/Desktop/IAC
ansible-galaxy collection install -r ansible/requirements.yml
ansible-playbook -i ansible/inventory.ini ansible/deploy.yml
```

## Testen

```powershell
terraform -chdir=terraform fmt -recursive -check
terraform -chdir=terraform validate
wsl ansible-playbook -i ansible/inventory.ini.example ansible/deploy.yml --syntax-check
```

Na deployment:

```powershell
terraform -chdir=terraform output -raw azure_vm_public_ip
wsl bash -lc "ssh -i ~/.ssh/iac-lab.pem Student@<azure-public-ip> 'docker ps'"
wsl bash -lc "ssh -i ~/.ssh/iac-lab.pem Student@<azure-public-ip> 'ping -c 4 10.50.0.2'"
```

## Demo

Laat in de video zien:

- GitHub repository en workflow run
- Terraform code in `terraform/`
- Cloud-init templates in de Terraform modules
- Ansible playbook en eigen roles
- Docker Compose image vanaf `docker.io`
- Webapp op Azure en ESXi
- WireGuard ping tussen Azure en ESXi
- `.gitignore`, `terraform.tfvars.example` en GitHub Secrets
