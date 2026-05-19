# Architectuur

## Azure

Terraform beheert de Azure resource group, het VNet, workload subnet, Network Security Group, public IP, NIC en Ubuntu VM.

De Azure VM gebruikt Cloud-init voor:

- Linux admin user
- SSH authorized key
- basispackages voor Ansible

## ESXi

Terraform gebruikt de `josenk/esxi` provider om op standalone ESXi een VM te clonen vanaf de template `ubuntu-2204-cloudinit-template`.

Vereisten voor de template:

- Ubuntu Server
- DHCP op het VM-netwerk
- `openssh-server`
- `open-vm-tools`
- een Ansible-gebruiker met sudo-rechten

## Hybride Verbinding

De werkende hybride verbinding loopt via WireGuard:

- Azure VM: `10.50.0.1`
- ESXi VM: `10.50.0.2`
- UDP poort `51820` is geopend in de Azure NSG

De tunnel wordt door de eigen Ansible role `hybrid_vpn` uitgerold. Hiermee kan de Azure VM de ESXi VM bereiken via het tunneladres.

Er is ook een optionele Azure VPN Gateway module aanwezig voor een klassieke site-to-site VPN, maar die vereist een echte on-prem IPsec-router/firewall en staat standaard uit.

## Applicatie

Ansible gebruikt eigen roles:

- `docker`: installeert Docker Engine en `docker-compose-plugin` via de officiele Docker repository
- `app`: kopieert `app/docker-compose.yml`, rendert de webpagina en start de stack
- `hybrid_vpn`: configureert WireGuard tussen Azure en ESXi

De Compose file gebruikt images vanaf Docker Hub:

- `nginx:1.27-alpine`
- `traefik/whoami:v1.10`
