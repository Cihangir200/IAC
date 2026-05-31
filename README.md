# Hybrid Cloud IaC Lab

Deze repository bevat een hybride Infrastructure as Code labopstelling waarbij Azure wordt gecombineerd met een lokale ESXi omgeving. Terraform maakt de infrastructuur aan, Cloud-init doet de basisconfiguratie van de VM's en Ansible installeert WireGuard, Docker en de webapp.

## Inhoudsopgave

- [Architectuur](#architectuur)
- [Structuur](#structuur)
- [Belangrijke Onderdelen](#belangrijke-onderdelen)
  - [Terraform](#terraform)
  - [Ansible](#ansible)
  - [Docker Compose](#docker-compose)
- [Secrets](#secrets)
- [Lokale Deployment](#lokale-deployment)
- [Handmatige Terraform Stappen](#handmatige-terraform-stappen)
- [Ansible](#ansible-1)
- [Testen](#testen)

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
|   `-- workflows/
|       `-- ci.yml
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
|   |-- deploy.ps1
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

## Belangrijke Onderdelen

### Terraform

De Terraform code staat in de map `terraform/`.

- `terraform/main.tf` roept de modules aan.
- `terraform/providers.tf` configureert Azure en ESXi providers.
- `terraform/variables.tf` bevat alle invoervariabelen.
- `terraform/outputs.tf` geeft onder andere de Azure public IP, ESXi IP en SSH key output terug.
- `terraform/modules/azure_network/` maakt het Azure netwerk.
- `terraform/modules/azure_linux_vm/` maakt de Azure VM.
- `terraform/modules/vsphere_vm/` maakt de ESXi VM.

### Ansible

De Ansible code staat in de map `ansible/`.

- `ansible/deploy.yml` is het hoofdplaybook.
- `ansible/roles/hybrid_vpn/` configureert WireGuard.
- `ansible/roles/docker/` installeert Docker Engine en de Docker Compose plugin.
- `ansible/roles/app/` kopieert de Compose file, rendert de webpagina en start de applicatie.

### Docker Compose

De applicatie staat in `app/docker-compose.yml`.

De webapp gebruikt een Docker image vanaf Docker Hub:

```yaml
image: docker.io/library/nginx:1.27-alpine
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

Deze bestanden worden genegeerd door `.gitignore`:

```text
terraform/terraform.tfvars
terraform/*.tfstate
*.pem
ansible/generated/
```

## Lokale Deployment

De volledige deployment kan met een script worden uitgevoerd:

```powershell
cd C:\Users\Student\Desktop\IAC
.\scripts\deploy.ps1
```

Het script doet automatisch:

- Terraform validate, plan en apply
- Terraform outputs ophalen
- SSH private key klaarzetten in WSL
- wachten tot SSH bereikbaar is
- Ansible inventory genereren
- Ansible playbook uitvoeren
- WireGuard ping en webapp controleren

Resources verwijderen:

```powershell
cd C:\Users\Student\Desktop\IAC
.\scripts\destroy-all.ps1 -StartAzureVmFirst
```

## Handmatige Terraform Stappen

```powershell
cd C:\Users\Student\Desktop\IAC\terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out tfplan
terraform apply tfplan
terraform output
```

## Ansible

Voor syntax checks kan de voorbeeld-inventory gebruikt worden:

```powershell
wsl ansible-playbook -i ansible/inventory.ini.example ansible/deploy.yml --syntax-check
```

Voor een echte deployment gebruikt het script de automatisch gegenereerde inventory:

```bash
cd /mnt/c/Users/Student/Desktop/IAC
ansible-playbook -i ansible/generated/deployment_inventory.ini ansible/deploy.yml
```

`ansible/inventory.ini` bevat placeholders en is bedoeld als voorbeeld/uitleg. De echte IP-adressen worden uit Terraform outputs gehaald.

## Testen

Terraform:

```powershell
terraform -chdir=terraform fmt -recursive -check
terraform -chdir=terraform validate
```

Ansible:

```powershell
wsl ansible-playbook -i ansible/inventory.ini.example ansible/deploy.yml --syntax-check
```

Na deployment:

```powershell
terraform -chdir=terraform output -raw azure_vm_public_ip
wsl bash -lc "ssh -i ~/.ssh/iac-lab.pem Student@<azure-public-ip> 'docker ps'"
wsl bash -lc "ssh -i ~/.ssh/iac-lab.pem Student@<azure-public-ip> 'ping -c 4 10.50.0.2'"
```
