pipeline {
    agent any
    environment {
        // Địa chỉ của Vault Server đang chạy trên VM 118
        VAULT_ADDR = 'http://127.0.0.1:8200'
        // Cần khai báo Secret Text có ID là 'vault-root-token' trong Manage Credentials của Jenkins
        VAULT_TOKEN = credentials('vault-root-token') 
    }
    stages {
        stage('🔓 Bước 1: Mở két sắt Vault lấy Mật khẩu') {
            steps {
                script {
                    env.PVE_PASS = sh(script: 'vault kv get -field=api_password secret/proxmox', returnStdout: true).trim()
                }
            }
        }
        stage('📦 Bước 2: Packer - Đúc Template 9002') {
            steps {
                sh '''
                packer init ubuntu2204.pkr.hcl
                packer build -var "pve_password=${PVE_PASS}" ubuntu2204.pkr.hcl
                '''
            }
        }
        stage('🚀 Bước 3: Terraform - Cấp phát VM K3s mới') {
            steps {
                sh '''
                terraform init
                terraform apply -var="pve_password=${PVE_PASS}" -auto-approve
                '''
            }
        }
        stage('⚙️ Bước 4: Ansible - Cài đặt K3s') {
            steps {
                // Chờ máy ảo mới lên mạng, sau đó chạy Ansible Playbook
                sh 'sleep 45'
                // Sử dụng SSH Key để truy cập tự động vào máy mới (IP 192.168.2.110 là IP do Terraform cấp trong main.tf)
                sh 'ansible-playbook -i "192.168.2.110," k3s-install.yml -u ubuntu --private-key ~/.ssh/id_rsa --ssh-common-args="-o StrictHostKeyChecking=no"'
            }
        }
    }
}
