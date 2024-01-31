output "instance_ip" {
  value = module.ec2_spot_instance.public_ip
}

output "ssh_command" {
  value = "ssh -i ./setup/terraform/.ssh/cndt2023-handson-key.pem ubuntu@${module.ec2_spot_instance.public_ip}"
}
