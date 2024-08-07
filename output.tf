
output "public_ips" {
    value = aws_instance.example.public_ip
}
output "domain_adress" {
  value = aws_route53_record.root.name
}