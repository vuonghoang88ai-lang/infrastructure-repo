packer {
required_plugins {
proxmox = {
version = ">= 1.1.3"
source  = "github.com/hashicorp/proxmox"
}
}
}

variable "pve_password" {
type    = string
default = "" # Sẽ được Jenkins tiêm vào từ Vault lúc chạy
}

source "proxmox-clone" "ubuntu" {
proxmox_url = "https://192.168.2.15:8006/api2/json"
username    = "root@pam"
password    = var.pve_password
node        = "promox"

insecure_skip_tls_verify = true
clone_vm    = "ubuntu-2204-cloudinit" # Tên của Base Template (VM 9000)
vm_id       = 9002
vm_name     = "Ubuntu-2204-Golden"

#Tắt hoàn toàn việc kiểm tra SSH để tránh lỗi treo do mất khóa Cloud-Init

communicator = "none"
}

build {
sources = ["source.proxmox-clone.ubuntu"]
}
