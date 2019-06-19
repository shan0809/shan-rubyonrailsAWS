output "curl-ip" {
  value = "${aws_eip.ipaddress.public_ip}:8080"
}

