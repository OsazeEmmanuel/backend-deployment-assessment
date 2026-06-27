output "vpc_id" {
  value = aws_vpc.startuptech_vpc.id
}

output "alb_dns_name" {
  value = aws_lb.startuptech_alb.dns_name
}

output "bastion_public_ip" {
  value = aws_eip.bastion_eip.public_ip
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}


