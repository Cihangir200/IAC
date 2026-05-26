# Hybrid Cloud IaC Lab

Deze repository bevat een hybride IaC labopstelling waarbij Azure gecombineerd wordt met een lokale ESXi omgeving. Terraform maakt de infrastructuur aan, Cloud-init doet de eerste configuratie en Ansible installeert Docker en deployt de applicatie.

## Architectuur

- Azure resource group, VNet, subnet, NSG, public IP, NIC en Ubuntu VM
- Standalone ESXi VM via de `josenk/esxi` Terraform provider en een Ubuntu template
- SSH public/private key authenticatie voor Azure
- Cloud-init userdata voor basisconfiguratie van VM's
- WireGuard tunnel tussen Azure en ESXi (`10.50.0.1` naar `10.50.0.2`)
- Docker Compose webapp met een image vanaf `docker.io`
- GitHub Actions workflow met validate/lint en deploy jobs

## Structuur

```text
.
|-- .github/workflows/ci.yml
|-- ansible/
|   |-- deploy.yml
|   |-- inventory.ini
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
|   `-- vsphere_vm/
|-- main.tf
|-- providers.tf
|-- variables.tf
|-- outputs.tf
`-- terraform.tfvars.example