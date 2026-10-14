terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

variable "pve_password" {
  type        = string
  description = "Mật khẩu root@pam của Proxmox (do Jenkins truyền vào từ Vault)"
}

variable "network_cidr" {
  default = "192.168.2.0/24"
}

variable "k3s_ip_start" {
  default = 110
}

provider "proxmox" {
  pm_api_url      = "https://192.168.2.15:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = var.pve_password
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "k3s_node" {
  count       = 1
  name        = "k3s-node-${count.index + 1}"
  target_node = "promox"
  clone       = "Ubuntu-2204-Golden" # Tên của máy ảo 9002 vừa được Packer tạo ra
  
  cores       = 4
  memory      = 4096
  
  agent       = 1
  os_type     = "cloud-init"
  
  # Nội suy IP tịnh tiến: 192.168.2.110, 192.168.2.111...
  ipconfig0   = "ip=${cidrhost(var.network_cidr, var.k3s_ip_start + count.index)}/24,gw=${cidrhost(var.network_cidr, 1)}"
  
  ciuser      = "ubuntu"

  # Bơm trực tiếp 2 ổ khóa vào máy ảo K3s qua Cloud-Init
  sshkeys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCakUWqhtC0U2XvzM7ObpWQ8ue8VNp9/nooazzfP722gwk6WsJ/dyGDqQ1jMs4isABvPhc+mCb7o0K6bxGstIJLz/llYd+gjEQtTheSPvNu7kWZUAkAEyGt9CokY9H+nLwPB07MPDlTLp/7BklhtuKWWjiU49u57hCfIi+kyToxnHOnrRFS0Mfnj8wTQAMSqWXAOo1teC85NDEEHmoeGILEPxh3gGtXgjpzbbAiaZVnmaxLK5ZrAthrRet6rutU3Jtx7D3fUXbZdDN7B/sF8Ie3l+7UJuAo3mGc7vqFM+BouX/q2K5rjvLoNsFrnB52pFoLN6oB76qx2+iyBQNNBbI4XTkFtI9ZAKBzVo4Y7wChyRdqsXA53ohGG7hCxCHLyYOQLLVL+uk/bq4Oco3l7EfAWFtDVKhaixIHVjzDjQiShYH2folKtN/xwX5c4ZEOW9TYvn6z1U0htjlkS+x13ZDH0gCehzIJWmxjSunThw64QtxrMK5jNgMch4I0bVP4LoU8F0r4ondJeD+NEedS4enbZl42vgjiyOWcCyAIaJFy2BWbPYXva3FMB8YuoH0ilcuZXKVMJCTwWEKCPILRumoT0cEPySU4MFFoiiy5GjSHSPhvYKCeyDmU6xv1OhDRH0ntg+159O/1I3ef1LU8B5QjIHEmSAr4Q97W+D7b8/quZQ== jenkins@cicd
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/Dwya71iSDkAlYlqgARn9HSifRc/eQUhIfKIN71qfA personal-key
EOF
}
