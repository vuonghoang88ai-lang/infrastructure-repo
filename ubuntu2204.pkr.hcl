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
  
  clone_vm    = "ubuntu-2204-cloudinit" # Tên của Base Template (VM 9000)
  vm_id       = 9002
  vm_name     = "Ubuntu-2204-Golden"

  os_type      = "cloud-init"
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout  = "20m"
}

build {
  sources = ["source.proxmox-clone.ubuntu"]
  
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y qemu-guest-agent curl git tailscale",
      "sudo systemctl enable qemu-guest-agent",
      
      # Nhúng khóa SSH của Jenkins vào Template để tự động hóa Ansible
      "mkdir -p /home/ubuntu/.ssh",
      "echo 'DÁN_NỘI_DUNG_FILE_ID_RSA.PUB_CỦA_JENKINS_VÀO_ĐÂY' >> /home/ubuntu/.ssh/authorized_keys",
      "chmod 600 /home/ubuntu/.ssh/authorized_keys",
      "chown -R ubuntu:ubuntu /home/ubuntu/.ssh"
    ]
  }
}
