# REMINDER:
# The output of the current module is crucial to the deployment modules that will be later used.
# To ease the process, these variables will be "outputed", captured by the main root file and 
# exported to json files in the "config" directory after doing "terraform apply". This way, 
# they can be stored in a persistent manner, avoiding losing them upon "terraform destroy".

output "vpc_id" {
    value = aws_vpc.antipode_mq.id
}

output "subnet_id" {
    value = aws_subnet.antipode_mq_a.id
}

output "subnet_ids" {
    value = [aws_subnet.antipode_mq_a.id, aws_subnet.antipode_mq_b.id]
}

output "security_group_id" {
    value = aws_default_security_group.antipode_mq.id
}

output "route_table_id" {
    value = aws_default_route_table.antipode_mq.id
}

output "rendezvous_security_group_id" {
    value = aws_security_group.rendezvous.id
}