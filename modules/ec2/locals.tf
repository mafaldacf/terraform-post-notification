locals {
    # IMPORTANT REMINDER: 
    # must create vpcs with subnets and generate new rsa pairs before creating EC2 instances!!
    # only then we can configure the necessary EC2 parameters 
    # (rsa_key_pair, subnet_id, sg_id)
    config = {
        "eu-central-1" = {
            # previously created subnet with subnet CIDR = 50.0.0.0/20
            ami                 = "ami-0783316fe04d26e86" 
            rsa_key_pair        = "rendezvous-eu" 
            subnet_id           = "subnet-0a722afed0c224760"
            sg_id               = "sg-05bd2b399593b86cf"
        }, 
        "us-east-1" = {
            # previously created subnet with CIDR = 51.0.0.0/20
            ami                 = "ami-08ccbaf0c4c036025" 
            rsa_key_pair        = "rendezvous-us"
            subnet_id           = "subnet-0ec25eaeb81642e55"
            sg_id               = "sg-00df9c3bcb92c8bfd"
        }
    }
}