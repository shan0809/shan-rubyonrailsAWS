data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#AWS Instances Creation starts here
resource "aws_instance" "rails-instance" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "t2.micro"

security_groups = [
    "${aws_security_group.allow_ssh.name}",
    "${aws_security_group.allow_outbound.name}"
  ]

  provisioner "remote-exec" {
    inline = [
      "command curl -sSL https://rvm.io/mpapis.asc | gpg --import -",
      "\\curl -sSL https://get.rvm.io | bash -s stable --rails",
    ]

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("~/.ssh/shan-siftery.pub")}"
    }
  }


  tags {
    Server = "rails"
    Enviornment = "Production"
    costcenter = "siftery"
  }
}



# Assign a static IP address to the instance
resource "aws_eip" "ipaddress" {
  instance    = "${aws_instance.rails-instance.id}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_outbound" {
  name        = "allow-all-outbound"
  description = "Allow all outbound traffic"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}