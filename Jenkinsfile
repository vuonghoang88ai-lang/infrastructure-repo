pipeline {
    agent any
    
    // Khai báo tham số đầu vào trên giao diện Jenkins
    parameters {
        booleanParam(name: 'RUN_PACKER', defaultValue: false, description: 'Tích vào đây nếu muốn Packer đúc lại Template 9002. Bỏ trống để Terraform dùng Template cũ đẻ luôn máy mới.')
    }
    
    environment {
        VAULT_ADDR = 'https://127.0.0.1:8200'
        VAULT_SKIP_VERIFY = 'true'
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
        
        // Bước này chỉ chạy NẾU bạn tích vào ô RUN_PACKER trên giao diện
        stage('📦 Bước 2: Packer - Đúc Template 9002') {
            when {
                expression { params.RUN_PACKER == true }
            }
            steps {
                sh '''
                packer init ubuntu2204.pkr.hcl
                packer build -var "pve_password=${PVE_PASS}" ubuntu2204.pkr.hcl
                '''
                sh "sshpass -p '${PVE_PASS}' ssh -o StrictHostKeyChecking=no root@192.168.2.15 'qm set 9002 --ide2 local-lvm:cloudinit'"
            }
        }
        
        stage('🚀 Bước 3: Terraform - Cấp phát VM K3s mới') {
            steps {
                sh 'terraform init -upgrade'
                sh 'terraform apply -var="pve_password=${PVE_PASS}" -auto-approve'
            }
        }
        
        stage('⚙️ Bước 4: Ansible - Cài đặt K3s') {
            steps {
                sh 'sleep 45'
                sh 'ansible-playbook -i "192.168.2.110," k3s-install.yml -u ubuntu --private-key ~/.ssh/id_rsa --ssh-common-args="-o StrictHostKeyChecking=no"'
            }
        }
    }
}
