provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
  region                  = "us-east-1"
}


resource "tls_private_key" "private-key" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}


resource "aws_key_pair" "deployer" {
  key_name   = "${terraform.workspace}.deployer-key"
  public_key = tls_private_key.private-key.public_key_openssh
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "web-traffic" {
  name        = "Allow_web_traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "Web-SG-Group"
    Environment = terraform.workspace
  }

}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = ["Allow_web_traffic"]
  #vpc_security_group_ids = [aws_security_group.web-traffic.id]
  provisioner "remote-exec" {
    connection {
      host = self.public_ip
      user = "ubuntu"
      type = "ssh"
      private_key = tls_private_key.private-key.private_key_pem
    }
    inline = [
      "sudo ufw allow 8080",
      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt update -qq",
      "sudo apt install software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install -y default-jre",
      "sudo apt install -y maven git ",
      "sudo apt install -y jenkins ansible ",
      "sudo systemctl start jenkins",

    ]
  }
  tags = {
    Name = "master-control-server"
    Terraform = "true"
  }

 
  provisioner "local-exec" {
    command = "terraform output private-key | sed '1d' | sed '28d' > ~/.ssh/endofclass.pem; chmod 600 ~/.ssh/endofclass.pem"
  }
}
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = ["Allow_web_traffic"]
  #vpc_security_group_ids = [aws_security_group.web-traffic.id]
  provisioner "remote-exec" {
    connection {
      host = self.public_ip
      user = "ubuntu"
      type = "ssh"
      private_key = tls_private_key.private-key.private_key_pem
    }
    inline = [
      "sudo apt update -qq",
      "sudo apt install software-properties-common",
      "sudo apt install -y default-jre",
      "sudo apt install -y maven git ",

    ]
  }
  tags = {
    Name = "web-server"
    Terraform = "true"
  }

 
  provisioner "local-exec" {
    command = "terraform output private-key | sed '1d' | sed '28d' > ~/.ssh/webserver.pem; chmod 600 ~/.ssh/webserver.pem"
  }
}
