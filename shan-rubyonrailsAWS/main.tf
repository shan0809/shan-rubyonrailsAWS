
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


# Define SSH key pair for our instances
resource "aws_key_pair" "mykeypair" {
  key_name= "awslogin"
  public_key="${file("aws.pub")}"
}

# Define webserver inside the public subnet
resource "aws_instance" "rails-instance" {
   ami = "${data.aws_ami.ubuntu.id}"
   instance_type = "${var.instancetype}"
   key_name = "${aws_key_pair.mykeypair.key_name}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World  - This is created for Siftery demo" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags {
    Server = "rails"
    Enviornment = "Production"
    costcenter = "siftery"
  }
}
resource "aws_eip" "ipaddress" {
  instance    = "${aws_instance.rails-instance.id}"
}
