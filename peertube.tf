variable "awsprops" {
  type          = map(string)
  default = {
    region              = "us-west-1"
    vpc                 = "vpc-bc399ada"
    ami                 = "ami-0f91bc0c77f3dea4c"  // Rocky Linux 8.4 Official 20210715
    itype               = "t2.micro"
    publicip            = true
    keyname             = "peertube"
    secgroupname        = "peertube-sg"
  }
}

provider "aws" {
  region        = "us-west-1"
  access_key    = "YOUR_ACCESS_KEY_HERE"
  secret_key    = "YOUR_SECRET_KEY_HERE"
}

resource "aws_security_group" "peertube-sg" {
  name          = lookup(var.awsprops, "secgroupname")
  description   = lookup(var.awsprops, "secgroupname")
  vpc_id        = lookup(var.awsprops, "vpc")

  // To Allow Inbound SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Inbound Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks         = ["0.0.0.0/0"]
  }

  // To Allow Inbound Port 443 Transport
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks         = ["0.0.0.0/0"]
  }

  // To Allow ALL Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "myInstance" {
  ami           = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  key_name      = lookup(var.awsprops, "keyname")
  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  dnf update -y
                  # Install NodeJS version 12
                  dnf module install -y nodejs:12
                  # Install yarn
                  npm install --global yarn
                  # Install ffmpeg
                  dnf install -y epel-release
                  dnf --enablerepo=powertools install -y SDL2 SDL2-devel
                  dnf install -y --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
                  dnf install -y ffmpeg

                  #yum -y install nginx postgresql postgresql-server postgresql-contrib openssl gcc-c++ make wget redis git devtoolset-7
                  #scl enable devtoolset-7 bash
                  #PGSETUP_INITDB_OPTIONS='--auth-host=md5' postgresql-setup --initdb --unit postgresql
                  #systemctl enable --now redis
                  #systemctl enable --now postgresql
                  #systemctl start mariadb
                  #systemctl enable mariadb
                  #firewall-cmd --permanent --add-service=http
                  #firewall-cmd --reload

                  EOF

  vpc_security_group_ids = [
    aws_security_group.peertube-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name        = "peertube"
    OS          = "Rocky"
  }

  depends_on = [ aws_security_group.peertube-sg ]
}

output "DNS" {
  value = aws_instance.myInstance.public_dns
}

output "IP" {
  value = aws_instance.myInstance.public_ip
}
