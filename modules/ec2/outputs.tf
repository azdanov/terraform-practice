output "app_eip" {
  value = aws_eip.practice_addr.*.public_ip
}

output "app_instance" {
  value = aws_instance.practice_web.id
}
