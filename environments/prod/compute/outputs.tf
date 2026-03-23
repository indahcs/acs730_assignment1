output "vm_private_ips" {
    value = module.aws_compute.vm_private_ips
}

output "vm_sg_ids" {
    value = module.aws_compute.vm_security_group_id
}