output "bastion_public_ip" {
  value = module.aws_compute.bastion_public_ip
}

output "vm_private_ips" {
  value = module.aws_compute.vm_private_ips
}

output "bastion_sg_id" {
  value = module.aws_compute.bastion_security_group_id
}