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
  #public_key = "${file("awslogin.pub")}"
  #public_key= "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaYWTS5h0aaAqZnpLhJFNX5yQ23h0wiUtBRDhKaBppn5J6dyoYL8KfKh3VMXuxGp/mfgyNr9Sbh8mAkrXSKJ4WqmtLsqiC6XooEr9QuYAsAyuo+OSpyHSRJDvm20ZlCy8tUPc6m7AAS6JbkW/tdmFbz2OT0zJUb0hMXfykcc/1aNVfFXemqKrbBTwI5HDZVd3LSQ0UWEGyQI+EGBY3Ua6ChyeEu2aNa2Dm9Cs3ZG25lfq+5v3mPC0c6wUZBBRRitvvUHEcK54qZ11EaWGrpRS5eeW3vBedv2MpSQYycKWhTtsuIlk3khJZ25ew/r0jmavwDlRqOuNHgype0osjyYCZT5CvzEmua4weemhIw8Yqy63IUjqjAUJT6pbWLfE1HVvXh38GqQQ2cOjUaphfQ8PLWo+ayCa+/mnhPJYqXG4BKeIs7WEFPYZw03+EcLbFljNobZCGk/+9kIFu+pxPeUkuC/IwZ2joGBisUd6jAaPhdkdEBU6pt7aa5Ix5XModMkIwUIg1tVS+AF1R5l1I7jAgTdezF5RjLnrSuR/bDzAhIp55iO1HNmsipKueioETBJDilOs2AO0X7xaMaK96956YAly4f3zhbsE0s4h1vmIZiwz7ZUYZrwVqMZNt4RDFnEBhgnQVGPcBZhA1N1KgjVZ5j1ZIyvIM/1bbcoEARZWeaw== tech@allesen.net"
  
}

resource "aws_instance" "rails-instance" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.instancetype}"
  key_name = "${aws_key_pair.mykeypair.key_name}"
  #user_data = "${file("install_package.sh")}"
  

security_groups = [
    "${aws_security_group.allow_ssh.name}",
   #"${aws_security_group.allow_outbound.name}"
  ]

  /*provisioner "remote-exec" {
    inline = [
      "command curl -sSL https://rvm.io/mpapis.asc | gpg --import -",
      "\\curl -sSL https://get.rvm.io | bash -s stable --rails",
    ]

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("~/.ssh/aws")}"
    }
  }
*/

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
