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

output "security_group_id_rendezvous" {
    value = aws_security_group.rendezvous.id
}

output "route_table_id" {
    value = aws_default_route_table.antipode_mq.id
}