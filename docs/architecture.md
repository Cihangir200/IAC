# Architectuur

## Azure

Terraform maakt een resource group, VNet, workload subnet, GatewaySubnet, Network Security Group, public IP en Ubuntu VM.

De Azure VM gebruikt CloudInit voor:

- Linux user `iacadmin`
- SSH authorized key
- Python en basispackages voor Ansible

## ESXi/vSphere

Terraform kloont een bestaande Ubuntu cloud-init template naar vSphere/ESXi. De VM krijgt CloudInit via `guestinfo.userdata`.

Vereisten voor de template:

- Ubuntu 22.04 of vergelijkbaar
- `open-vm-tools`
- cloud-init met VMware guestinfo datasource
- DHCP of een netwerkconfiguratie die past bij je lab

## Hybride verbinding

Terraform maakt de Azure-kant van een site-to-site VPN:

- Azure VPN Gateway
- Local Network Gateway met het on-prem/ESXi netwerk
- IPsec connection met pre-shared key

De on-prem kant moet in je labomgeving bestaan op een router, firewall of NSX edge. Vul in `terraform.tfvars` het publieke IP van die endpoint en het on-prem CIDR in.

## Applicatie

Ansible installeert Docker met de Galaxy role `geerlingguy.docker` en start daarna `app/docker-compose.yml`.

De Compose file gebruikt images van Docker Hub:

- `nginx:1.27-alpine`
- `traefik/whoami:v1.10`

