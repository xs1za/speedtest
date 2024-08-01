provider "aws" {
  region = "eu-south-2"
  access_key = var.access_key
  secret_key = var.secret_key
  }

data "aws_ami" "latest_ubuntu" { //Динамически получаем ami последней версии ubuntu
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "speedtest" {
  ami = data.aws_ami.latest_ubuntu.id //вставляем динамический ami
  instance_type = "t3.nano"
  vpc_security_group_ids = [aws_security_group.allow_iperf.id]
  user_data = file("bashscript.sh")
  tags = {
    "Name" = "speedtest"
  }
}

resource "aws_security_group" "allow_iperf" {
  name        = "allow_iperf"
  description = "Allow iperf speedtest inbound traffic"
  # vpc_id      = aws_vpc.main.id

  ingress {
    description      = "iperf"
    from_port        = 5201
    to_port          = 5201
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "icmp"
    from_port        = 8 // ICMP Type Numbers: Echo Request
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}