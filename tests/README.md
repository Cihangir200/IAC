# Tests

Deze opdracht bevat testmomenten voor de deployment:

```powershell
terraform fmt -recursive -check
terraform init -backend=false
terraform validate
ansible-galaxy install -r ansible/requirements.yml
ansible-playbook -i ansible/inventory.ini.example ansible/deploy.yml --syntax-check
```

Na deployment:

```powershell
curl http://<azure-vm-public-ip>
ssh -i ~/.ssh/iac-lab.pem <azure-user>@<azure-vm-public-ip> "curl http://10.50.0.2"
ssh -i .\iac-lab.pem iacadmin@<azure-vm-public-ip> "docker ps"
ssh -i .\iac-lab.pem iacadmin@<esxi-vm-ip> "docker ps"
```

Voor de hybride connectie test je vanaf Azure naar ESXi:

```powershell
ssh -i ~/.ssh/iac-lab.pem <azure-user>@<azure-vm-public-ip> "ping -c 4 10.50.0.2"
```
