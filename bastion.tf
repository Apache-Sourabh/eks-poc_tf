resource "aws_instance" "bastion" {
  depends_on = [aws_eks_cluster.mongo-eks-cluster]
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  associate_public_ip_address = true
  key_name = "aws_kp"
  ami = "ami-0cff7528ff583bf9a"
  subnet_id = aws_subnet.sub-1.id
  user_data = <<EOF
  #!/bin/bash
cat << EOTF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOTF
sudo yum install -y kubectl-1.23.0
cat << EOTFF | sudo tee ~/.bashrc
alias k='kubectl'
alias kg='kubectl get'
alias kgpo='kubectl get pod'
EOTFF
source ~/.bashrc
curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2
chmod 700 get_helm.sh
./get_helm.sh
  EOF
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
   tags = {
    Name = "bastion-vm"
  }
}
