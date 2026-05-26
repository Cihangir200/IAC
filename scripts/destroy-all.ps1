param(
    [switch]$StartAzureVmFirst
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host $Message -ForegroundColor Green
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$ovfToolPath = "C:\Program Files\VMware\VMware OVF Tool"
if (Test-Path $ovfToolPath) {
    $env:Path = "$ovfToolPath;$env:Path"
}

Write-Host "Destroy start vanuit: $repoRoot" -ForegroundColor Green

if ($StartAzureVmFirst) {
    Write-Step "Azure VM starten indien nodig"
    try {
        az vm start --resource-group s1187594 --name mngmt --only-show-errors | Out-Null
    }
    catch {
        Write-Host "Azure VM bestaat niet of hoeft niet gestart te worden." -ForegroundColor Yellow
    }
}

Write-Step "Terraform validate"
terraform validate

Write-Step "Terraform destroy"
terraform destroy -auto-approve

Write-Host ""
Write-Host "Terraform resources zijn verwijderd." -ForegroundColor Green
