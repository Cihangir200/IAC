# --- SSH / gebruiker ---
ssh_username = "iac"
public_key   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+flonYiLiVSeVlCSBNUG0XysCzVD3s004Ahe5o8XO6"

# --- ESXi resources ---
disk_store = "datastore1"     # pas aan als je datastore anders heet
network    = "VM Network"     # pas aan als je portgroup anders heet
memory_mb  = 2048
num_cpus   = 1

# --- Ubuntu 24.04 cloud image met cloud-init ---
# Als je ESXi geen internet heeft, download dit OVA-bestand en zet het lokaal in je datastore.
ovf_source = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.ova"
# of lokaal: ovf_source = "/vmfs/volumes/datastore1/ubuntu-24.04-server-cloudimg-amd64.ova"
