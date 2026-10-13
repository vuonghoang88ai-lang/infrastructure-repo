terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

variable "pve_password" {
  type = string
}

# QUY HOẠCH DẢI MẠNG (CIDR)
variable "network_cidr" {
  description = "Dải mạng LAN nội bộ"
  default     = "192.168.2.0/24"
}

# QUY HOẠCH CÁC POOL (KHOẢNG IP) CHO DỊCH VỤ K3S
variable "k3s_ip_start" {
  description = "Dải IP cho K3s Cluster bắt đầu từ số 110"
  default     = 110
}

provider "proxmox" {
  pm_api_url      = "https://192.168.2.15:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = var.pve_password
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "k3s_node" {
  count       = 1 # Sửa số này nếu muốn tạo ra 2, 3, 4 máy cùng lúc. IP sẽ tự động tịnh tiến.
  name        = "k3s-node-${count.index + 1}"
  target_node = "promox"
  clone       = "Ubuntu-2204-Golden"
  os_type     = "cloud-init"
  cores       = 4
  memory      = 4096
  
  # Cấp phát IP động thông qua toán học tính toán mạng của Terraform
  ipconfig0   = "ip=${cidrhost(var.network_cidr, var.k3s_ip_start + count.index)}/24,gw=${cidrhost(var.network_cidr, 1)}"
  ciuser      = "ubuntu"
  cipassword  = "ubuntu"
}
