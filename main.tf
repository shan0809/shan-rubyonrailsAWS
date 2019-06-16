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

  owners = ["099720109477"] 
}

#AWS Instances Creation starts here

resource "aws_key_pair" "mykeypair" {
  key_name= "awslogin"
  public_key="${file("aws.pub")}"
}

resource "aws_instance" "rails-instance" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.instancetype}"
  key_name = "${aws_key_pair.mykeypair.key_name}"

security_groups = [
    "${aws_security_group.allow_ssh.name}",
   ]


user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
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

#NSG for SSH Authentication
resource "aws_security_group" "allow_ssh" {
  name        = "${var.sgname}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
