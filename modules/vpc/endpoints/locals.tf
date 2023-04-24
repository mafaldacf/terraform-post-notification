locals {
    # IMPORTANT REMINDER: 
    # must create vpcs with subnets!!
    # only then we can configure the necessary endpoint parameters 
    # (vpc_id, route_table_id, subnet_id, security_group_id)
    config = {
        eu-central-1 = {
            vpc_id              = "vpc-046ebde198e614a9f"
            
            # gateways (dynamo)
            route_table_id      = "rtb-04839768d7f68d9d4"

            # interfaces (sns or sqs)
            subnet_id           = "subnet-0a722afed0c224760"
            security_group_id   = "sg-06e89d1eec9546ab5"
        },
        us-east-1 = {
            vpc_id              = "vpc-0a5ac82ccd60ed313"
            
            # gateways (dynamo)
            route_table_id      = "rtb-0a611f6ea89a9985d"

            # interfaces (sns or sqs)
            subnet_id           = "subnet-0ec25eaeb81642e55"
            security_group_id   = "sg-0747aa4724f69efdd"
        }
    }
}