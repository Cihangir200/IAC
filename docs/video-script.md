# Video Script, Maximaal 5 Minuten

## 0:00 - 0:30 Intro

Laat de opdracht en GitHub repo zien. Noem dat de oplossing Terraform, Cloud-init, Ansible, Docker Compose, GitHub Actions, Azure en ESXi gebruikt.

## 0:30 - 1:15 Terraform

Laat `terraform/main.tf`, `terraform/modules/azure_linux_vm`, `terraform/modules/azure_network` en `terraform/modules/vsphere_vm` zien.

Wijs aan:

- Azure VM en netwerkresources
- ESXi VM via standalone ESXi provider
- SSH key output
- Cloud-init templates

## 1:15 - 2:00 GitHub Actions

Open `.github/workflows/ci.yml`.

Laat zien:

- `validate_and_lint`
- `terraform fmt`
- `terraform validate`
- `yamllint`
- Ansible syntax check
- deploy job met Terraform SSH key output

## 2:00 - 3:15 Ansible En Docker

Laat `ansible/deploy.yml` en de eigen roles zien:

- `roles/docker`
- `roles/app`
- `roles/hybrid_vpn`

Run of toon:

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy.yml
```

Wijs op:

```text
azure returns 200 via Docker Compose
esxi returns 200 via Docker Compose
failed=0
```

## 3:15 - 4:15 Hybride Connectie

Test vanaf Azure naar ESXi via WireGuard:

```bash
ssh -i ~/.ssh/iac-lab.pem Student@<azure-public-ip> "ping -c 4 10.50.0.2"
ssh -i ~/.ssh/iac-lab.pem Student@<azure-public-ip> "curl http://10.50.0.2"
```

Laat ook de Azure webapp zien:

```bash
curl http://<azure-public-ip>
```

## 4:15 - 5:00 Best Practices

Laat zien:

- `.gitignore` zonder secrets/state/keys
- `terraform/terraform.tfvars.example`
- geen wachtwoorden in GitHub
- modules en variabelen
- README en documentatie
