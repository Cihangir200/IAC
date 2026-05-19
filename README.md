# Hybrid Cloud IaC Lab

Deze repository bevat een volledige hybride IaC-deployment voor Azure en standalone ESXi. Terraform maakt de infrastructuur, Cloud-init configureert de basis, Ansible installeert Docker en rolt de applicatie uit, en GitHub Actions verzorgt validatie en deployment.

## Architectuur

- Azure resource group, VNet, subnet, NSG, public IP, NIC en Ubuntu VM
- Standalone ESXi VM via de `josenk/esxi` Terraform provider en een Ubuntu template
- SSH public/private key authenticatie voor Azure
- Cloud-init userdata voor basisconfiguratie van VM's
- WireGuard tunnel tussen Azure en ESXi (`10.50.0.1` naar `10.50.0.2`)
- Docker Compose applicatie met images vanaf Docker Hub
- GitHub Actions workflow met validate/lint en deploy jobs

## Structuur

```text
.
|-- .github/workflows/ci.yml
|-- ansible/
|   |-- deploy.yml
|   |-- inventory.ini.example
|   `-- roles/
|       |-- app/
|       |-- docker/
|       `-- hybrid_vpn/
|-- app/docker-compose.yml
|-- docs/
|-- modules/
|   |-- azure_linux_vm/
|   |-- azure_network/
|   |-- azure_vpn/
|   `-- vsphere_vm/
|-- main.tf
|-- providers.tf
|-- variables.tf
|-- outputs.tf
`-- terraform.tfvars.example
```

## Secrets

Zet geen secrets in Git. Gebruik lokaal `terraform.tfvars` en in GitHub Actions repository secrets.

Benodigde GitHub Secrets voor de deploy job:

```text
AZURE_CREDENTIALS
AZURE_SUBSCRIPTION_ID
AZURE_VM_USER
ESXI_HOST
ESXI_USER
ESXI_PASSWORD
ESXI_GUEST_USER
ESXI_GUEST_PASSWORD
ONPREM_VPN_PUBLIC_IP
VPN_SHARED_KEY
SSH_PRIVATE_KEY
```

De deploy job is bedoeld voor een self-hosted runner die jouw ESXi-netwerk kan bereiken en waarop Terraform, Azure CLI, Ansible, Python en VMware OVF Tool beschikbaar zijn.

## Lokale Deployment

```powershell
cd C:\Users\Student\Desktop\IAC
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
terraform fmt -recursive -check
terraform validate
```

```bash
ansible-playbook -i ansible/inventory.ini.example ansible/deploy.yml --syntax-check
```

Werkende applicatie:

```bash
curl http://20.93.128.239
ssh -i ~/.ssh/iac-lab.pem Student@20.93.128.239 "curl http://10.50.0.2"
```

WireGuard tunneltest:

```bash
ssh -i ~/.ssh/iac-lab.pem Student@20.93.128.239 "ping -c 4 10.50.0.2"
```

## Demo

Laat in de video zien:

- GitHub repository en laatste workflow run
- Terraform validate/plan/output
- Azure VM en ESXi VM
- SSH key gebruik in GitHub Actions en lokale demo
- Ansible run met `failed=0`
- Docker containers op beide VM's
- Webapp via Azure public IP en via WireGuard naar ESXi
