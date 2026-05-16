# Tests

Deze opdracht bevat testmomenten voor de deployment:

```powershell
terraform fmt -recursive -check
terraform init -backend=false
terraform validate
ansible-galaxy install -r ansible/requirements.yml
ansible-playbook -i ansible/inventory.ini.example ansible/playbook.yml --syntax-check
```

Na deployment:

```powershell
curl http://<azure-vm-public-ip>
curl http://<esxi-vm-private-ip>
ssh -i .\iac-lab.pem iacadmin@<azure-vm-public-ip> "docker ps"
ssh -i .\iac-lab.pem iacadmin@<esxi-vm-ip> "docker ps"
```

Voor de hybride connectie test je vanaf Azure naar ESXi:

```powershell
ssh -i .\iac-lab.pem iacadmin@<azure-vm-public-ip> "curl -I http://<esxi-vm-private-ip>"
```

