# Hybrid Cloud IAC Lab

Deze repo bevat een complete voorbeeldopdracht voor een hybride cloud deployment met Terraform, Azure, vSphere/ESXi, CloudInit, Ansible Galaxy, Docker Compose en GitHub Actions.

## Architectuur

- Azure VNet met subnetten voor workload en VPN Gateway
- Azure Linux VM met SSH key uit Terraform
- vSphere/ESXi Linux VM op basis van een template
- CloudInit op beide VM's voor users, SSH en basispackages
- Site-to-site connectie: Azure VPN Gateway + Local Network Gateway richting het ESXi/on-prem netwerk
- Ansible playbook met Galaxy role `geerlingguy.docker`
- Docker Compose applicatie met images vanaf Docker Hub
- GitHub Actions pipeline voor `terraform fmt`, `terraform validate` en Ansible syntax checks

## Mappen

```text
.
|-- .github/workflows/ci.yml
|-- ansible/
|-- app/
|-- docs/
|-- modules/
|   |-- azure_linux_vm/
|   |-- azure_network/
|   |-- azure_vpn/
|   `-- vsphere_vm/
|-- tests/
|-- main.tf
|-- providers.tf
|-- variables.tf
|-- outputs.tf
`-- terraform.tfvars.example
```

## Voorbereiding

1. Installeer Terraform, Ansible en de Azure CLI.
2. Login op Azure:

```powershell
az login
az account set --subscription "<subscription-id>"
```

3. Maak een `terraform.tfvars` op basis van `terraform.tfvars.example`.
4. Vul je Azure, vSphere en on-prem VPN gegevens in.
5. Installeer Ansible Galaxy rollen:

```powershell
ansible-galaxy install -r ansible/requirements.yml
```

### Windows en WSL

Op Windows draai je Terraform vanuit PowerShell. Open na installatie een nieuwe PowerShell zodat de PATH-wijziging geladen wordt:

```powershell
cd C:\Users\Student\Desktop\IAC
terraform version
terraform init
```

Ansible draai je vanuit Ubuntu/WSL:

```powershell
wsl
cd /mnt/c/Users/Student/Desktop/IAC
ansible-galaxy install -r ansible/requirements.yml
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

## Deployment

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

Toon de gegenereerde SSH keys:

```powershell
terraform output -raw ssh_public_key
terraform output -raw ssh_private_key_pem
```

Maak daarna een inventory op basis van de Terraform output:

```powershell
terraform output -json > terraform-output.json
```

Gebruik de publieke IP's in `ansible/inventory.ini` en draai:

```powershell
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

## Testen

Lokaal:

```powershell
terraform fmt -recursive -check
terraform validate
ansible-playbook -i ansible/inventory.ini.example ansible/playbook.yml --syntax-check
```

In GitHub Actions draait dezelfde basisvalidatie automatisch bij push en pull request.

## Demo in video

Zie [docs/video-script.md](docs/video-script.md) voor een script van maximaal 5 minuten.
