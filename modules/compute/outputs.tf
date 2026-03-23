output "bastion_public_ip" {
    value   = var.deploy_bastion ? aws_instance.bastion[0].public_ip : null
}

output "vm_private_ips" {
    value = aws_instance.vm[*].private_ip
}

output "vm_instance_ids" {
    value = aws_instance.vm[*].id
}

output "bastion_security_group_id" {
  value = var.deploy_bastion ? aws_security_group.bastion_sg[0].id : null
}

output "vm_security_group_id" {
    value = aws_security_group.vm_sg.id
}