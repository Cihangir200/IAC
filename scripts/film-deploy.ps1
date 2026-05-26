param(
    [string]$AzureUser = "Student",
    [string]$AzureResourceGroup = "s1187594",
    [string]$AzureVmName = "mngmt",
    [string]$EsxiGuestUser = "student",
    [string]$EsxiGuestPassword = "",
    [string]$SshKeyInWsl = "~/.ssh/iac-lab.pem"
)

$ErrorActionPreference = "Stop"

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Benodigd commando ontbreekt: $Name"
    }
}

function Invoke-Wsl {
    param([string]$Command)

    wsl bash -lc $Command
    if ($LASTEXITCODE -ne 0) {
        throw "WSL command failed with exit code ${LASTEXITCODE}: $Command"
    }
}

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host $Message -ForegroundColor Green
}

function ConvertTo-WslPath {
    param([string]$WindowsPath)

    $fullPath = [System.IO.Path]::GetFullPath($WindowsPath)
    $drive = $fullPath.Substring(0, 1).ToLowerInvariant()
    $path = $fullPath.Substring(2).Replace('\', '/')
    return "/mnt/$drive$path"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoRootWsl = ConvertTo-WslPath $repoRoot
$generatedDir = Join-Path $repoRoot "ansible\generated"
$generatedDirWsl = "$repoRootWsl/ansible/generated"
$localKeyPath = Join-Path $repoRoot "iac-lab.pem"
$localKeyPathWsl = "$repoRootWsl/iac-lab.pem"
$sudoScriptPath = Join-Path $generatedDir "set-sudo.sh"
$sudoScriptPathWsl = "$generatedDirWsl/set-sudo.sh"
$inventoryPath = Join-Path $generatedDir "deployment_inventory.ini"
$inventoryPathWsl = "$generatedDirWsl/deployment_inventory.ini"
$rootAuthorizedKeysPath = Join-Path $generatedDir "root_authorized_keys"
$rootAuthorizedKeysPathWsl = "$generatedDirWsl/root_authorized_keys"

Set-Location $repoRoot

$ovfToolPath = "C:\Program Files\VMware\VMware OVF Tool"
if (Test-Path $ovfToolPath) {
    $env:Path = "$ovfToolPath;$env:Path"
}

if ([string]::IsNullOrWhiteSpace($EsxiGuestPassword)) {
    $EsxiGuestPassword = $env:TF_VAR_admin_password
}

if ([string]::IsNullOrWhiteSpace($EsxiGuestPassword) -and (Test-Path ".\terraform.tfvars")) {
    $tfvarsPassword = Select-String -Path ".\terraform.tfvars" -Pattern '^\s*admin_password\s*=\s*"([^"]+)"' | Select-Object -First 1
    if ($tfvarsPassword) {
        $EsxiGuestPassword = $tfvarsPassword.Matches[0].Groups[1].Value
    }
}

if ([string]::IsNullOrWhiteSpace($EsxiGuestPassword)) {
    throw "ESXi guest password ontbreekt. Zet TF_VAR_admin_password of admin_password in terraform.tfvars."
}

$env:TF_VAR_admin_password = $EsxiGuestPassword

Require-Command terraform
Require-Command wsl
Require-Command az

Write-Host "Deployment start vanuit: $repoRoot" -ForegroundColor Green

Write-Step "Stap 1: Terraform validate"
terraform validate

Write-Step "Stap 2: Terraform plan"
terraform plan -out tfplan

Write-Step "Stap 3: Terraform apply"
terraform apply "tfplan"

Write-Step "Stap 4: Terraform outputs ophalen"
$azureIp = terraform output -raw azure_vm_public_ip
$esxiIp = terraform output -raw vsphere_vm_private_ip
$sshPublicKey = terraform output -raw ssh_public_key
Write-Host "Azure public IP: $azureIp"
Write-Host "ESXi VM IP:     $esxiIp"

New-Item -ItemType Directory -Force -Path $generatedDir | Out-Null

Write-Step "Stap 5: SSH private key klaarzetten in WSL"
$privateKey = terraform output -json ssh_private_key_pem | ConvertFrom-Json
[System.IO.File]::WriteAllText($localKeyPath, $privateKey, [System.Text.Encoding]::ASCII)
Invoke-Wsl "mkdir -p ~/.ssh"
Invoke-Wsl "tr -d '\r' < '$localKeyPathWsl' > $SshKeyInWsl"
Invoke-Wsl "chmod 600 $SshKeyInWsl"

Write-Step "Stap 6: Azure VM starten indien nodig"
az vm start --resource-group $AzureResourceGroup --name $AzureVmName --only-show-errors | Out-Null

Write-Step "Stap 7: Wachten tot SSH beschikbaar is"
Write-Host "Azure SSH controleren: $azureIp"
Invoke-Wsl "for i in {1..60}; do nc -z '$azureIp' 22 && echo 'Azure SSH is bereikbaar.' && exit 0; echo 'Wachten op Azure SSH...'; sleep 5; done; exit 1"

Write-Host "ESXi SSH controleren: $esxiIp"
Invoke-Wsl "for i in {1..60}; do nc -z '$esxiIp' 22 && echo 'ESXi SSH is bereikbaar.' && exit 0; echo 'Wachten op ESXi SSH...'; sleep 5; done; exit 1"

Write-Step "Stap 8: Sudo op ESXi controleren"
[System.IO.File]::WriteAllText($rootAuthorizedKeysPath, "$sshPublicKey`n", [System.Text.Encoding]::ASCII)
@"
#!/usr/bin/env bash
set -euo pipefail

ESXI_IP='$esxiIp'
ESXI_USER='$EsxiGuestUser'
ESXI_PASSWORD='$EsxiGuestPassword'
ROOT_AUTHORIZED_KEYS='$rootAuthorizedKeysPathWsl'

command -v sshpass >/dev/null || (sudo apt-get update && sudo apt-get install -y sshpass)

sshpass -p "`$ESXI_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "`$ESXI_USER@`$ESXI_IP" \
  "command -v cloud-init >/dev/null && timeout 300 cloud-init status --wait || true"

sudo_ready=0
for i in {1..60}; do
  if sshpass -p "`$ESXI_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "`$ESXI_USER@`$ESXI_IP" "sudo -n true"; then
    sudo_ready=1
    break
  fi

  if sshpass -p "`$ESXI_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "`$ESXI_USER@`$ESXI_IP" "printf '%s\n' '`$ESXI_PASSWORD' | sudo -S -p '' true"; then
    sudo_ready=1
    break
  fi

  echo "Wachten tot sudo beschikbaar is..."
  sleep 5
done

if [ "`$sudo_ready" != "1" ]; then
  echo "Sudo is niet beschikbaar voor gebruiker `$ESXI_USER op `$ESXI_IP." >&2
  exit 1
fi

sshpass -p "`$ESXI_PASSWORD" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "`$ROOT_AUTHORIZED_KEYS" "`$ESXI_USER@`$ESXI_IP:/tmp/iac-root-authorized-keys"

sshpass -p "`$ESXI_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "`$ESXI_USER@`$ESXI_IP" \
  "printf '%s\n' '`$ESXI_PASSWORD' | sudo -S -p '' sh -c 'mkdir -p /root/.ssh /etc/ssh/sshd_config.d && install -o root -g root -m 600 /tmp/iac-root-authorized-keys /root/.ssh/authorized_keys && printf \"%s\n\" \"PermitRootLogin prohibit-password\" \"PubkeyAuthentication yes\" > /etc/ssh/sshd_config.d/99-iac-root-login.conf && rm -f /tmp/iac-root-authorized-keys && (systemctl restart ssh || systemctl restart sshd)'"

ssh -i $SshKeyInWsl -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@`$ESXI_IP" "whoami" | grep -q '^root`$'
echo "Root SSH-key login op ESXi is klaar voor Ansible."
"@ | Set-Content -Path $sudoScriptPath -Encoding ASCII
Invoke-Wsl "chmod +x '$sudoScriptPathWsl'"
Invoke-Wsl "'$sudoScriptPathWsl'"

Write-Step "Stap 9: Ansible inventory genereren"
@"
[hybrid]
azure ansible_host=$azureIp ansible_user=$AzureUser ansible_ssh_private_key_file=$SshKeyInWsl ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' wireguard_address=10.50.0.1 wireguard_listen_port=51820
esxi ansible_host=$esxiIp ansible_user=root ansible_ssh_private_key_file=$SshKeyInWsl ansible_become=false ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' wireguard_address=10.50.0.2
"@ | Set-Content -Path $inventoryPath -Encoding ASCII

Write-Step "Stap 10: Ansible deployment uitvoeren"
Invoke-Wsl "cd '$repoRootWsl' && ansible-playbook -i '$inventoryPathWsl' ansible/deploy.yml"

Write-Step "Stap 11: Deployment controleren"
Invoke-Wsl "for i in {1..12}; do ssh -i $SshKeyInWsl -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null '$AzureUser@$azureIp' 'ping -c 4 10.50.0.2' && exit 0; echo 'Wachten op WireGuard tunnel...'; sleep 5; done; exit 1"
Invoke-Wsl "curl -s 'http://$azureIp' | grep -E 'IAC Hybrid Lab|Host|azure'"
Invoke-Wsl "curl -s 'http://$esxiIp' | grep -E 'IAC Hybrid Lab|Host|esxi'"

Write-Host ""
Write-Host "Deployment voltooid." -ForegroundColor Green
Write-Host "Azure app: http://$azureIp"
Write-Host "ESXi app:  http://$esxiIp"
