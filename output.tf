output "server-ip" {
  value = "${aws_eip.ipaddress.public_ip}"
}

